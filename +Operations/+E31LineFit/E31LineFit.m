classdef E31LineFit < Operation
    %E31LINEFIT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DataType = 'E31File';
        
        RawData; 
        
    end
    
    methods
        function plot(this, data)
            this.plot_e31(data);
        end
        function calc(this)
        end
    end
    
    methods(Static)
        h    = plot_e31(data);
        data = calc_e31(rawdata);
        export(data, filename);
    end
    
end

