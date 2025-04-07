function Wxy = ...
    estimateFiltersTimeResolved(Mg, Mr, wn, dn, chunks, varargin)

    if(mod(wn,2) == 0), wn = wn+1; end
    
    [nx, ny] = size(Mg, [1,2]); 
    nchunks = size(chunks,1);

    Wxy = NaN([nx*ny, wn, nchunks]);
    Mg = reshape(Mg, [nx*ny, size(Mg,3)]);
    Mr = reshape(Mr, [nx*ny, size(Mr,3)]);

    for i_s = 1:(nx*ny)
%     parfor i_s = 1:(nx*ny)
        
        mg_raw = Mg(i_s, :);
        mr_raw = Mr(i_s, :);
        ws = nan([wn,nchunks]);

        for i_ch = 1:nchunks
            
            mg_in = mg_raw(chunks(i_ch,1):chunks(i_ch,2))';
            mr_in = mr_raw(chunks(i_ch,1):chunks(i_ch,2))';

            if(all(mg_in == 0) || all(mr_in == 0)), continue; end    
            
            ws(:, i_ch) = estimateFilterReg(mg_in, mr_in, wn, dn); 
        end
        Wxy(i_s,:,:) = ws;
    end
    
    Wxy = reshape(Wxy, [nx,ny,wn,nchunks]);
end
%%