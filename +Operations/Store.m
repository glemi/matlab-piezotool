classdef Store < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Operations
    end
    
    methods
        function this = Store()
            this.update();
        end
        function update(this)
            this.Operations = Operations.Operation.empty;
            Operations.def(this);
        end
        function add(this, operation)
            n = length(this.Operations);
            this.Operations(n+1) = operation;
        end
        function ops = getByFileType(this, filetype)
            types = {this.Operations.FileType};
            i = strcmp(filetype, types);            
            ops = this.Operations(i);
        end
        function op = getByName(this, opname)
            names = {this.Operations.Name};
            i = strcmp(opname, names);
            if ~any(i)
                op = Operations.Operation.empty; %#ok
            else
                op = this.Operations(i);
            end
        end
    end
    
    methods(Static)
        function store = all()
            store = FileTypes.def;
        end
    end
end

