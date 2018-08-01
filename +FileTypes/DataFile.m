classdef DataFile <  handle
    %DATATYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID = '';
        AltID = '';
        Name = '';
        Description = '';
        
        Extension = '';
        RegexFilter = '';
        WildcardFilter = '';
        
        ReadFcn % = @(~)struct([]);
        IdentFcn % = @(~)struct([]);
    end
 
    methods
        function this = DataFile(name)
            if nargin > 0
                this.Name = name;
            end
            this.ReadFcn = @(~)struct([]);
            this.IdentFcn = @FileTypes.ident_default;
        end
        function yes = check(this, filename)
            if isempty(this.RegexFilter)
                yes = false;
            else
                [~, filename, ext] = fileparts(filename);
                filename = [filename ext];
                index = regexpi(filename, this.RegexFilter);
                yes = (index == 1);
            end
        end
    end
    
    methods
        function data = readfile(this, file)
            filename = file.AbsPath;
            data = this.ReadFcn(char(filename));
        end
        function info = identify(this, file)
            info = FileTypes.SampleInfo;
            filename = Auxilary.file2str(file);
            info = this.IdentFcn(char(filename));
        end
    end
    
end

