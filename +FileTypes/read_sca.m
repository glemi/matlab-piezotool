function data = read_sca(filename, title)
    
    fileID = fopen(filename,'r');
    
    line = fgetl(fileID);
    
    headers = strsplit(strtrim(line));
    nCols = length(headers);
        
    if nCols == 3
        format = '%f %f %f';
    elseif nCols == 4
        format = '%f %f %f %f';
    end
    array = textscan(fileID, format, 'ReturnOnError', true);
    
    fclose(fileID);
    
    data.filename = filename;
    if nargin >= 2
        data.title = title;
    end
    
    data.Freq = array{1};
    data.d33 = array{2};
    data.Phase = array{3};
    
    if nCols == 4
        data.Vout = array{4};
    end
end