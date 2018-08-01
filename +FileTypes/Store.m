classdef Store < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Types
    end
    
    methods
        function this = Store(list)
            if nargin < 1
                this.Types = FileTypes.DataFile.empty; 
                return;
            end
            if ischar(list) && strcmp(list, 'all')
                this = FileTypes.Store.all;
            end
        end
        function add(this, type)
            n = length(this.Types);
            this.Types(n+1) = type;
        end
        function tf = filter(this, files)
            n = length(files);
            m = length(this.Types);
            tf = false(1,n);

            for k = 1:n
                for j = 1:m
                    if this.Types(j).check(files(k).name)
                        tf(k) = true;
                        break;
                    end
                end 
            end 
        end
        function types = classify(this, files)
            
            files = Auxilary.file2str(files);
            files = cellstr(files);
            n = length(files);
            m = length(this.Types);
            
            for k = 1:n
                for j = 1:m
                    if this.Types(j).check(files{k})
                        types(k) = this.Types(j);
                        return;
                    end
                    types(k) = FileTypes.DataFile;
                end 
            end

            if length(types) == 1
                types = types(:);
            end
        end
    end
    
    methods(Static)
        function store = all()
            store = FileTypes.def;
        end
    end
end

