classdef Result
    %RESULT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        KeyFigures % Value / Error / etc (struct or object)
        SourceFiles
        DateMeasured
        DateComputed 
        OpsInfo % Version of the code
        Data % any additional data, as a struct... 
    end
    
    methods
        function obj = Result(inputArg1,inputArg2)
            %RESULT Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

