function Wxy = estimateFilters(Mg, Mr, wn, dn)

    if(mod(wn,2)==0), wn = wn+1; end
    
    [nx, ny] = size(Mg,[1,2]); 

    % parfor works better without nested loops...
    Wxy = NaN([nx*ny, wn]);
    Mg = reshape(Mg, [nx*ny, size(Mg,3)]);
    Mr = reshape(Mr, [nx*ny, size(Mr,3)]);

    % for i_s = 1:(nx*ny)
    parfor i_s = 1:(nx*ny)

        if(all(Mg(i_s,:) == 0) || all(Mr(i_s,:) == 0)) 
            Wxy(i_s, :) = nan(size(Wxy(i_s, :) )); 
            continue; 
        end    

        Wxy(i_s, :) = estimateFilterReg(Mg(i_s,:)', Mr(i_s,:)', wn, dn); 
%         Wxy(i_s, :) = limitFilter(Wxy(i_s, :)', options);
    end
    
    Wxy = reshape(Wxy, [nx,ny,wn]);
end
%%
