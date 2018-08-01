classdef DataFile < handle
    %DATAFILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Type
        Info
        Data
        
        FileName
        FileTitle
        Folder
        AbsPath
        RelPath
    end
    
    properties(SetAccess = private)
        
    end
    
    methods
        function this = DataFile(file, type, rootdir)
            if nargin < 2
                types = FileTypes.Store('all');
                type = types.classify(file);
            end
            if nargin < 3
                rootdir = '';
            end
            
            abspath = Auxilary.file2str(file);
            [folder, filetitle, ext] = fileparts(abspath);
            filename = [filetitle ext];

            this.FileName = filename;
            this.FileTitle = filetitle;
            this.Folder = folder;
            this.AbsPath = abspath;
            this.RelPath = strrep(this.AbsPath, [rootdir filesep], '');
            
            this.Type = type;
            this.Info = type.identify(abspath);
        end
        
        function Load(this)
            this.Data = this.Type.readfile(this);
        end
    end
end

