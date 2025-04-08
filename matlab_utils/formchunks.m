function [chunks, chunks_nooverlap] = formchunks(nt, wn, dn)
    
    chunks = [1,wn] + (0:dn:(nt-wn))';
    if(isempty(chunks)), chunks = [1,nt]; end
    if(chunks(end,2) ~= nt)
    chunks(end+1,:) = [nt-wn, nt];
    end
    nchunks = size(chunks,1);
    
    if(nargout > 1)
        chunks_nooverlap = ([-floor(dn/2), ceil(dn/2)-1]) + (round(wn/2):dn:nt)';
        chunks_nooverlap = chunks_nooverlap(1:nchunks,:);
        chunks_nooverlap(1,1) = 1;
        chunks_nooverlap(end,2) = nt;
    end
end

