function outlines(countors, x_lim, y_lim, varargin)
    if(nargin < 2) xlim = []; end
    if(nargin < 3) ylim = []; end    

    tf = ishold;
    
    for i_r = 1:size(countors, 3)
        countors(countors(:,1,i_r) < x_lim(1), 1, i_r) = NaN;
        countors(countors(:,1,i_r) > x_lim(2), 1, i_r) = NaN;
        countors(countors(:,2,i_r) < y_lim(1), 1, i_r) = NaN;
        countors(countors(:,2,i_r) > y_lim(2), 1, i_r) = NaN;
        % plot(countors(:,1,i_r), countors(:,2,i_r), varargin{:}); hold on;
    end

    for i_r = 1:size(countors, 3)
        plot(countors(:,1,i_r), countors(:,2,i_r), varargin{:}); hold on;
    end
    if(~tf) hold off; end
end

