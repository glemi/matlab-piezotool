classdef FileBrowser < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RootDir = '';
        TypeStore = FileTypes.Store;
    end
    
    methods
        function this = FileBrowser(rootdir, types)
            this.RootDir = rootdir;
            this.TypeStore = FileTypes.Store.all;
            if nargin > 1
                this.TypeStore = types;
            end
        end
        
        function files = getFiles(this, path)
           files = dir(path);
           i = ~[files.isdir];
           files = files(i);
           
           i = this.TypeStore.filter(files);
           
           files = files(i);
           [files.folder] = deal(path);
        end
        
        function folders = getSubfolders(this, path)
            files = dir(path);
            i = [files.isdir];
            i = i & ~strcmp({files.name}, '.');
            i = i & ~strcmp({files.name}, '..');
            
            folders = files(i);
            [folders.folder] = deal(path);
        end
    end
end

