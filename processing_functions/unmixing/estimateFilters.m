function Wxy = estimateFilters(Mg, Mr, wn, dn, varargin)

    if(mod(wn,2)), wn = wn+1; end
    
    options = defaultOptions();
    if(~isempty(varargin))
        options = getOptions(options, varargin);
    end
    
    [nx, ny] = size(Mg,[1,2]); 

    % parfor works better without nested loops...
    Wxy = NaN([nx*ny, wn]);
    Mg = reshape(Mg, [nx*ny, size(Mg,3)]);
    Mr = reshape(Mr, [nx*ny, size(Mr,3)]);

    parfor i_s = 1:(nx*ny)

        if(all(Mg(i_s,:) == 0) || all(Mr(i_s,:) == 0)) 
            Wxy(i_s, :) = nan(size(Wxy(i_s, :) )); 
            continue; 
        end    

        Wxy(i_s, :) = estimateFilterReg(Mg(i_s,:)', Mr(i_s,:)', ...
            wn, dn, options); 
    end
    
    Wxy = reshape(Wxy, [nx,ny,wn]);
end
%%

function options = defaultOptions()

    options.fref = [];
    options.max_amp_rel = 1.2; % relative to regression at fref
    options.flim_max = 1;

    options.max_phase = pi;
    options.max_delay = Inf; % normalized: max_delay(s)*fps(Hz)
end