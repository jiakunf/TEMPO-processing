function [X_trials, window_stim, intervals_stim] = signalTrials(X, ttl, varargin)
    %%
    
    options = defaultOptions();
    if(~isempty(varargin))
        options = getOptions(options, varargin);
    end
    %%
    %signalTrials
    if(~all(unique(ttl) == [0,1]'))
        error(": ttl_signal should be possible to binarize");
    end
    
    ttl = logical(ttl);
    
    array1d = false;
    if(ndims(X)==2 && size(X,2)==1) array1d = true; end
    
    if(array1d) X=X'; end
    
    sz_in = size(X);
    ndims_in = ndims(X);
    %%
    
    X = reshape(X, [prod(size(X,1:(ndims_in-1))), size(X,ndims_in)]);
    %%
    
    intervals = ttlGetIntervals(ttl, options.min_stim_length);
    
    sti = round(median(intervals{2}(:,3)));
    % iti = round(median(intervals{1}(:,3))*options.iti_scale);
    iti = round(sti*options.iti_scale);
    
    window_stim = [repelem(0, iti), ...
                   repelem(1, sti),...
                   repelem(0, iti)];
    window_length = length(window_stim);
    
    X_trials = zeros([size(intervals{2},1)-2*options.drop, size(X,1), window_length]);
    % ttl_trials = zeros([size(intervals{2},1)-2*options.drop, size(X,1), window_length]);
    
    intervals_stim = intervals{2}((options.drop+1):(size(intervals{2},1)-options.drop),:);
    
    % for i_s = (1+options.drop):(size(intervals{2}, 1)-options.drop) 
    dropL = 0;
    dropR = 0;
    for i_s = 1:(size(intervals{2}, 1)) 
        f_start = intervals{2}(i_s,2)-iti+...
                 (intervals{2}(i_s,3)-sti)*options.align_to_end;
        f_end = (f_start+window_length-1);

        if(f_start < 1) 
            dropL = dropL+1; 
            continue;
        end
        if(f_end > size(X,2)) 
            dropR = dropR+1; 
            continue;
        end       

        X_trials(i_s,:,:) = X(:,f_start:f_end); %X_trials(i_s-options.drop,:,:) 
    end 
    %%

    X_trials = X_trials((dropL+1):(end-dropR),:,:);
    
    X_trials = reshape(X_trials, ...
        [size(X_trials,1),sz_in(1:(ndims_in-1)),size(X_trials,3)]);
    
    if(array1d) X_trials = squeeze(X_trials); end

end
%%

function options = defaultOptions()

    options.iti_scale = 1.5;
    options.align_to_end = false;
    options.drop = 1;
    options.min_stim_length = 0;
end
