classdef FileStash < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RootDir = '';
        Files = DataFile.empty
    end
    
    properties(Access = private)
        TypeStore
    end
    
    methods
        function this = FileStash(rootdir)
            this.RootDir = rootdir;
            this.TypeStore = FileTypes.Store('all');
        end
        
        function add(this, files)
            n0 = length(this.Files);
            n = length(files);
            for k = 1:n
                file = files(k);
                type = this.TypeStore.classify(file);
                this.Files(n0+k) = DataFile(file, type, this.RootDir);
            end
            [~, i] = unique({this.Files.AbsPath});
            this.Files = this.Files(i);
        end
        function remove(this, indices)
            this.Files(indices) = [];
        end
        function clear(this)
            this.Files = DataFile.empty;
        end
    end
end

