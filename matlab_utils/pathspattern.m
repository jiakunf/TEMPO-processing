function names_out = pathspattern(basefolder_search, pattern, relative)

    if(nargin < 3), relative = false; end
    files = dir(fullfile(basefolder_search, pattern));
    names_out = string(fullfile({files.folder}, {files.name}));
    
    if(relative)
        names_out = erase(names_out, basefolder_search);
    end
end