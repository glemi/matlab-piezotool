function data = read_comsol(filename)
    params = struct;    
    index = 0;
    
    fileID = fopen(filename,'r');
    
    xheader = '';
    yheader = '';
    
    while ~feof(fileID)
        [type, tokens] = readline(fileID);
        
        switch type
            case 'param'
                pname = tokens{1};
                pvalue = tokens{2};
                params.(pname) = pvalue;
            case 'header'
                xheader = tokens{1};
                yheader = tokens{2};
                break;
            case 'data' 
                % should never get here
            case 'blank' 
                % should never get here
        end 
    end 
    
    data.params = params;
    
    format = '%f %f';
    array = textscan(fileID, format, 'ReturnOnError', true);
    
    fclose(fileID);
    
    
    column1 = array{1};
    column2 = array{2};
    
    [chunks, indices] = slicedata(column1);
    
    n = length(chunks);
    for k = 1:n
        istart = indices(k)+1;
        istop = indices(k+1);
        
        xdata = chunks{k}; 
        ydata = column2(istart:istop);
        
        dataset = struct;
        dataset.(xheader) = xdata;
        dataset.(yheader) = ydata;
        dataset.name = sprintf('El%.0f', xdata(end));
        
        data.datasets(k) = dataset;
    end
    
    [~, name, ext] = fileparts(filename);
    data.filename = [name ext];
    data.fullpath = filename;
end

function [chunks, indices] = slicedata(data)
    indices = find(diff(data) < 0 & data(2:end) == 0);
    indices = [0; indices; length(data)];
    
    n = length(indices)-1;
    for k = 1:n
        istart = indices(k)+1;
        istop = indices(k+1);
        chunks{k} = data(istart:istop);
    end
end


function [type, tokens] = readline(fileID)
    line = fgetl(fileID);
    %fprintf('%s\n', line);

    if isempty(line)
        type = 'blank';
        tokens = {};
        return;
    end

    expr{1} = '^% (\w+):\s+(.+)$';
    expr{2} = '^% (\w+)\s+(\w+)$';
    expr{3} = '(\d+(\.\d+)?\s\d+(\.\d+)?)';
    types{1} = 'param';
    types{2} = 'header';
    types{3} = 'data';

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