classdef Cache
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CacheDir
    end
    
    methods
        function this = Cache(dirpath)
            this.CacheDir = dirpath;
        end
        
        function yes = checkAvailable(this, datafile)
            cachefile = this.getCacheFilePath(datafile);
            yes = logical(exist(cachefile, 'file'));
        end
        function result = loadCachedResult(this, datafile)
            if this.cacheFileAvailable
                cachefile = this.getCacheFilePath(datafile);
                contents = load(cachefile);
                result = contents.result;
            else
                error 'No Cached Data Available';
            end 
        end
        function cachefile = getCacheFilePath(this, datafile)
            cachedir = this.CacheDir;
            if ~exist(cachedir, 'dir')
                mkdir(cachedir);
            end

            cachedir = fullfile(cachedir, datafile.Type.AltID);
            if ~exist(cachedir, 'dir')
                mkdir(cachedir);
            end
            
            cachefile = strrep(datafile.RelPath, '\', '__');
            cachefile = [cachefile '.mat'];
            cachefile = fullfile(cachedir, cachefile);
        end
    end
    
end

