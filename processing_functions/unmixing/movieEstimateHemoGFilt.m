function [fullpath_out, fullpathWxy_out, fullpathW0_out]  = ...
    movieEstimateHemoGFilt(fullpath_sig, fullpath_ref, varargin)
    
    [basepath_ref, ~, ~] = fileparts(fullpath_ref);

    options = defaultOptions(basepath_ref);
    if(~isempty(varargin))
        options = getOptions(options, varargin);
    end
    %%

    [fullpath_out, fullpathWxy_out, fullpathW0_out, do_skip] = ...
        setupOutput(fullpath_sig, fullpath_ref, options);
    if(do_skip), return; end
    [~,filename_out,~] = fileparts(fullpath_out);
    %%
    
    disp("movieEstimateHemoGFilt: loading movies")
        
    % To avoid extra data in the ram, movies are loaded from hard drive
    % when passed to processing functions 
    specs_r = rw.h5readMovieSpecs(fullpath_ref);
    sz = rw.h5getDatasetSize(fullpath_ref, '/mov');
    mr = rw.h5getMeanTrace(fullpath_ref);
    %%
    
    if(isempty(options.fref))
        % find first hemodynamic peak
        options.fref = findFref(mr, specs_r, options.fref_lims, ...
            options.fref_minpeakwidth, options.fref_minpeakprominance);
    end
    
    if(isempty(options.naverage))
        options.naverage = round(options.average_mm/specs_r.getPixSize()/2)*2+1;
    end

    options_estimate = struct(...
        'fref', options.fref/specs_r.getFps(), 'max_amp_rel',  options.max_amp_rel, ...
        'flim_max', options.flim_max/specs_r.getFps(), ...
        'max_phase', options.max_phase, 'max_delay', options.max_delay*specs_r.getFps() );

    wn = round(specs_r.getFps()*options.dt);
    dn = round(wn*(1-options.overlap));
    %%

   	Mr_filt0 = 0;

    if( options.naverage > 1 )
        
        disp("movieEstimateHemoGFilt: estimating filter for averaged R trace")

        if(all(sz(1:2) < options.naverage))
            Mr_in = reshape(repelem(mr, prod(sz(1:2))), sz);
        else
            Mr_in = rw.h5readMovie(fullpath_ref); 
            
            % NaNs on the ref edges due to registration. Imputing (imputeNaNS) or 
            % nan-tolerant smoothing (smooth2a/mm.movieSmooth) takes forever
            Mr_in(isnan(Mr_in)) = 0; 
            Mr_in = smooth3(Mr_in, 'box', [options.naverage, options.naverage,1]);
        end
        
        W0 = estimateFilters( rw.h5readMovie(fullpath_sig),  Mr_in, ...
            wn, dn,  options_estimate);

        Mr_filt0 = applyFilters(Mr_in, W0); %convn(Mr_in, W0, 'same');
        clear('Mr_in');
    end
    %%

    disp("movieEstimateHemoGFilt: estimating filter for each pixel")

    Wxy = estimateFilters(...
        rw.h5readMovie(fullpath_sig) - Mr_filt0, rw.h5readMovie(fullpath_ref), ...
        wn, dn,  options_estimate);   

    Mr_filt = applyFilters(rw.h5readMovie(fullpath_ref), Wxy) + Mr_filt0;
    
    % to avoid NaN propagation from the ref channel edges
    Mr_filt(isnan(Mr_filt) & ~isnan(Mr_filt0)) = Mr_filt0(isnan(Mr_filt) & ~isnan(Mr_filt0));
    %%
    
    disp("movieEstimateHemoGFilt: saving")

    specs_out = copy(specs_r);
    specs_out.AddToHistory(functionCallStruct({'fullpath_sig', 'fullpath_ref', 'options'}));

    if(options.save_filtered), rw.h5saveMovie(fullpath_out, Mr_filt, specs_r);
    else, fullpath_out = []; end
        
    rw.h5saveMovie(fullpathWxy_out, Wxy, specs_out);

    if(options.naverage > 1), rw.h5saveMovie(fullpathW0_out, W0, specs_out);
    else, fullpathW0_out = []; end   
    %%
    
    disp("movieEstimateHemoGFilt: saving plots and videos")
    
    if(options.naverage > 1), Wplot = W0; else, Wplot = Wxy; end
    
    savePlots(rw.h5readMovie(fullpath_sig), rw.h5readMovie(fullpath_ref), ...
        Mr_filt, Wplot, specs_r, filename_out, options);
end
%%

function options = defaultOptions(basepath)
    
    options.dt = 2; % (s) time window for single filter estimation
    options.overlap = 0.75; %(rel) time windows overlap 
    
    options.outdir = basepath;
    options.diagnosticdir = fullfile(basepath, 'diagnostic', 'hemoFilt');
    options.illustrdir = fullfile(basepath, 'illustrations');
    
    options.fref = []; %Hz,
    options.fref_lims = [1.5, 20]; %Hz
    options.fref_minpeakwidth = 0.3;
    options.fref_minpeakprominance = 0.9;

    options.max_amp_rel = 1.2;
    options.flim_max = 20; %Hz

    options.max_phase = pi;
    options.max_delay = Inf;
    
    options.naverage = [];
    options.average_mm = 1;

    options.save_filtered = true;
    
    options.skip = true;
end
%%

function [fullpath_out, fullpathWxy_out, fullpathW0_out, do_skip] = ...
    setupOutput(fullpath_sig, fullpath_ref, options)

    [basepath_ref, filename_ref, ext, ~, ch_ref, ~] = filenameParts(fullpath_ref);
    [~, ~, ~, ~, ch_sig, ~] = filenameParts(fullpath_sig);
   
    postfix_new = "_hemoFilt"+"To"+ch_sig + ...
        "dt"+string(round(options.dt,1)) + "av"+num2str(options.average_mm)+ ...
        "ma" + string(options.max_amp_rel) + "md" + string(round(options.max_delay*1e3));
    
    if (~isfolder(options.outdir)), mkdir(options.outdir); end
    if (~isfolder(options.illustrdir)), mkdir(options.illustrdir); end 
    if (~isfolder(options.diagnosticdir)), mkdir(options.diagnosticdir); end  

    filename_out = filename_ref + postfix_new;
    fullpath_out = fullfile(options.outdir, filename_out + ext);
    fullpathWxy_out = fullfile(options.diagnosticdir, filename_out + "_Wxy" + ext);
    fullpathW0_out = fullfile(options.diagnosticdir, filename_out + "_W0" + ext);
    do_skip = false;    

    if (isfile(fullpath_out))
        if(options.skip)
            disp("movieEstimateHemoGFilt: Output file exists. Skipping:" + fullpath_out);
            do_skip = true;
            return;
        else
            warning("movieEstimateHemoGFilt: Output file exists. Deleting:" + fullpath_out);
            delete(fullpath_out);
        end     
    end
    
    if (isfile(fullpathWxy_out) && ~options.save_filtered)
        if(options.skip)
            disp("movieEstimateHemoGFilt: Output file exists. Skipping:" + fullpathWxy_out);
            do_skip = true;
            return;
        else
            warning("movieEstimateHemoGFilt: Output file exists. Deleting:" + fullpathWxy_out);
        end     
    end

    if(isfile(fullpathWxy_out)), delete(fullpathWxy_out); end
    if(isfile(fullpathW0_out)), delete(fullpathW0_out); end
end

%%
function fref = findFref(mr, specs_r, fref_lims, fref_minpeakwidth, fref_minpeakprominance)
    % find firs hemodynamic peak
    z = pmtm(mr, 0.5*length(mr)/specs_r.getFps()/2); 
    fs = linspace(0,1,(length(z)-1))*specs_r.getFps()/2;
    touse = (fs>fref_lims(1) & fs<fref_lims(2));

    [pks,locs,w,p] = findpeaks(log(z(touse)), fs(touse),...
        'MinPeakWidth', fref_minpeakwidth, ...
        'MinPeakProminence', fref_minpeakprominance, ...
        'SortStr', 'descend');
    fref = locs(1);
end

%%
function savePlots(Mg, Mr, Mr_filt, Wxy, specs, filename_out, options)
    
    fig_time = plt.getFigureByName("movieEstimateHemoGFilt: Spatially-averaged traces");
    
    Mg(isnan(Mr_filt)) = NaN;
    Mr(isnan(Mr_filt)) = NaN;
    
    mg =  squeeze(mean(Mg,[1,2],'omitnan'));
    mr =  squeeze(mean(Mr,[1,2],'omitnan'));
    mr_filt = squeeze(mean(Mr_filt,[1,2],'omitnan'));
    mg_nohemo  = squeeze(mean(Mg-Mr_filt, [1,2],'omitnan'));
    
    plt.tracesComparison([mg, mr*(mr\mg), mr_filt, mg-mr*(mr\mg), mg_nohemo], ...
        'labels',["ch1", "ch2", "hemo_toch1", "umx regression", "umx filter"] + " (mean)",...
        'fps', specs.getFps(), 'fw', 0.5, ...
        'nomean', false, 'spacebysd', 3, 'f0', specs.getFrequencyRange(1));
    
    saveas(fig_time, fullfile(options.diagnosticdir, filename_out + "_meantraces" + ".png"))
    saveas(fig_time, fullfile(options.diagnosticdir, filename_out + "_meantraces" + ".fig"))
    
    %%
    
    fig_filt= plt.getFigureByName("movieEstimateHemoGFilt: Spatially-averaged filter");
    
    nan_mask = ones(size(Wxy, [1,2]));
    if(~isempty(specs.getMask())), nan_mask(specs.getMask() == 0) = NaN; end
    w =  squeeze(mean(Wxy.*nan_mask, [1,2], 'omitnan'));

    zw = fft(w);
    fs = linspace(0,specs.getFps, length(zw));
    [~,ind_f0] = min(abs(fs-options.fref));

    v0 = zeros(size(w)); v0(length(v0)/2+1) = abs(zw(ind_f0));
    v1 = zeros(size(w)); v1(length(v1)/2+1) = options.max_amp_rel*abs(zw(ind_f0));

    plt.tracesComparison([w/abs(zw(ind_f0)), v0/abs(zw(ind_f0)), v1/abs(zw(ind_f0))], ...
        'labels', ["Filter (rel to reg @fref)", "reg @fref", "amp_limit ("+string(options.max_amp_rel)+")"],...
        'fps', specs.getFps(), 'fw', .2, 't0', -(length(w))/2/specs.getFps())   
    ax1 = subplot(2,1,1); delete(ax1.Children(1));delete(ax1.Children(1));
    ax2 = subplot(2,1,2);
    hold on;
    xline(options.fref, '--');
    xline(options.flim_max, '-.');    
    l = legend(ax2); legend_new = l.String; 
    legend_new{end-1} = 'reference freq'; legend_new{end} = 'amp limit end freq';
    legend(legend_new);
    hold off;
    
    saveas(fig_filt, fullfile(options.diagnosticdir, filename_out + "_filter" + ".png"))
    saveas(fig_filt, fullfile(options.diagnosticdir, filename_out + "_filter" + ".fig"))
end
%%