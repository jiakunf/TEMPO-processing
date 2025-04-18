function axes_all = signalSpectrogram(st, ts, fs, varargin)

    options = defaultOptions();
    if(~isempty(varargin))
        options = getOptions(options, varargin);
    end   

    %%  
    
    if(isempty(options.trace_ts)) 
        options.trace_ts = interp1(ts, linspace(0,1,length(ts)), linspace(0,1,length(options.trace))); 
    end
    if(isempty(options.spectra_fs)) 
        options.spectra_fs = interp1(fs, linspace(0,1,length(fs)), linspace(0,1,length(options.spectra_fs))); 
    end
              
    %%

    if(isnan(options.flims_plot(1))) options.flims_plot(1) = min(fs); end
    if(isnan(options.flims_plot(2))) options.flims_plot(2) = max(fs); end
    
    frange_plot = find(fs >= options.flims_plot(1), 1): ...
                  find(fs <= options.flims_plot(2), 1, 'last');
    %%
    
    if(options.fillnan)
        for i_f = 1:size(st,1)
            st(i_f,:) = interp1(ts(~isnan(st(i_f,:))), st(i_f,~isnan(st(i_f,:))), ts);
        end
    end
    %%
    
    ax_spectrogram = options.ax_spectrogram; ax_trace = []; ax_spectra = [];
    
    nv = 4; nh = 6;
    sp_num = reshape((1:nv*nh), nh, nv)';
    if(isempty(options.trace) && isempty(options.spectra) && isempty(ax_spectrogram))
        ax_spectrogram = subplot(1,1,1);
    elseif(~isempty(options.trace) && isempty(options.spectra) && isempty(ax_trace))
        ax_spectrogram = subplot(nv, nh, reshape(sp_num(1:(end-1), 1:end), 1, []) ); 
        ax_trace = subplot(nv, nh, reshape(sp_num(end, 1:end), 1, []) );   
    elseif(isempty(options.trace) && ~isempty(options.spectra) && isempty(ax_spectra))
        ax_spectrogram = subplot(nv, nh, reshape(sp_num(:, 2:end), 1, []) ); 
        ax_spectra = subplot(nv, nh, reshape(sp_num(:, 1), 1, []) );          
    elseif(~isempty(options.trace) && ~isempty(options.spectra) && isempty(ax_trace) && isempty(ax_spectra))
        ax_spectrogram = subplot(nv, nh, reshape(sp_num(1:(end-1), 2:end), 1, []) );
        ax_trace = subplot(nv, nh, reshape(sp_num(end, 2:end), 1, []));
        ax_spectra = subplot(nv, nh, reshape(sp_num(1:(end-1), 1), 1, []));
    end

    axes_all = [ax_spectrogram, ax_trace, ax_spectra];
    %%

    axes(ax_spectrogram)
    
    im = imagesc(ts, fs, st); 
    set(im, 'AlphaData', ~isnan(st));
    
    grid on;
    set(gca,'GridColor',[1 1 1]) 
    set(gca,'YDir','normal')
%     set(gca,'xticklabel',[], 'yticklabel', [])
    
    xlim(minmax(ts'));
    ylim(options.flims_plot);

    caxis([quantile(st(fs >= options.flims_plot(1) & fs <= options.flims_plot(2),:), options.q(1), 'all'), ...
           quantile(st(fs >= options.flims_plot(1) & fs <= options.flims_plot(2),:), options.q(2), 'all')])
    
    set(gca,'ColorScale', options.colorscale)
    colormap('jet');
    
    originalSize = get(ax_spectrogram, 'Position');
    cb = colorbar;
    set(ax_spectrogram, 'Position', originalSize);
    
    title(options.title, 'Interpreter', 'none', 'FontSize', 8);
        
    xlabel("s"); ylabel("Hz");

    %%
        
    if(~isempty(options.trace))
%         drawnow;
%         cb.Position(1) = ax_spectrogram.Position(1) + ax_spectrogram.Position(3) + 0.01;
%         cb.Position(1) = ax_spectrogram.Position(1) + ax_spectrogram.Position(3) + 0.01;        
    
        set(ax_spectrogram,'xticklabel',[])
        set(ax_spectrogram,'xlabel',[])
        axes(ax_trace)
        
        plot(options.trace_ts, options.trace); 
        xlabel("s"); ylabel('signal');
        grid on;
        
        xlim(minmax(ts'));
        
        linkaxes([ax_spectrogram ax_trace],'x')
    end
    %%
    
    if(~isempty(options.spectra))
        
%         set(ax_spectrogram,'yticklabel',[])
        set(ax_spectrogram,'ylabel',[])
        axes(ax_spectra)
        
        plot(options.spectra_fs, options.spectra); 
        
        
        xlim(options.flims_plot);
        
        xlabel("Hz"); ylabel('spectra');
        grid on;
        
%         linkaxes([ax_spectrogram ax_spectra],'y') % How to link y1 to x2?
        
        set(gca,'xaxisLocation','top');
        set(gca,'yaxisLocation','right');
        camroll(90);
        set(gca, 'YScale', options.colorscale)
        
    end
    %%
    
end

function options = defaultOptions()
   
    options.flims_plot = [NaN,NaN]; %frequency limits to plot
    
    options.fillnan = false;
    
    options.q = [0.5, 1]; %quantiles for caxis limits
    options.title = "Spectrogram";
    options.colorscale = "Log";
    
    options.trace = [];
    options.trace_ts = [];
    options.spectra = [];
    options.spectra_fs = [];

    options.ax_spectrogram = [];
end


