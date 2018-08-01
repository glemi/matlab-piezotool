% function params = read_pars(filename)
% Read parameter file.
function params = read_pars(filename)
    
    params = struct;    
    index = 0;
    
    fileID = fopen(filename,'r');
    
    while ~feof(fileID)
        [type, tokens] = readline(fileID);
        
        switch type
            case 'header'
                index = index + 1;
                pname = tokens{1};
                param = param_struct;
                param.Name = pname;
            case 'param'
                item = tokens{1};
                switch item
                    case 'Symbol', param.Symbol = strtrim(char(tokens{2}));
                    case 'Unit',   param.Unit   = strtrim(char(tokens{2}));
                    case 'Value',  param.Value  = str2double(tokens{2});
                    case 'Delta',  param.Delta  = str2double(tokens{2});
                end
            case 'blank'
                if index > 0
                    params.(pname) = param;
                    %params(index) = param;
                end
        end 
    end 
    
    fclose(fileID);
end

function param = param_struct()
    param = struct;
    param.Name = '';
    param.Symbol = '';
    param.Unit = '';
    param.Value = [];
    param.Delta = [];
end


function [type, tokens] = readline(fileID)
    line = fgetl(fileID);
    %fprintf('%s\n', line);

    if isempty(line)
        type = 'blank';
        tokens = {};
        return;
    end

    expr{1} = '\[(\w+)\]';
    expr{2} = '(\w+):(.*)';
    types{1} = 'header';
    types{2} = 'param';

    n = length(expr);
    for k = 1:n
        tokens = regexp(line, expr{k}, 'tokens');
        if ~isempty(tokens)
            type = types{k};
            tokens = tokens{:};
            return;
        end
    end

    type = 'unknown';
    tokens = {};
end