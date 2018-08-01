function [data] = read_aix(filename, title)
    % http://cp.literature.agilent.com/litweb/pdf/ads2004a/cktsim/ck04a12.html
    % http://cp.literature.agilent.com/litweb/pdf/ads2004a/cktsim/ck04a8.html

    % Prepare data structure
    data.header = containers.Map;
    data.params = containers.Map;
    
    % Format string for each line of text:
    %formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';
    formatSpec = '%f%f%f%f%f%f%f';
    
    % Open the text file.
    fileID = fopen(filename,'r');

    %% Header
    
    line = fgetl(fileID);
    if ~strcmp(line, 'e31Result')
        raiseErr('unsupported', line);
    end
    
    function ok = test_line(expr)
        iLine = iLine + 1;
        line = fgetl(fileID);
        match = regexp(line, expr, 'tokens');
        ok = ~isempty(match);
        if ok 
            match = match{:};
        end
    end
    
    cont = true;
    iLine = 1;
    while cont
        title_expr = '(\w+)';
        blank_expr = '';
        param_expr = '(.*):(.*)';
        thead_expr = '(\w+(\s\w+)*\s\[.*\]\s)+';
        trow_expr = '(-?\d\.\d+[eE][+-]\d+\s)+';
        
        match = {};
        
        if test_line(param_expr)
            name = match{1};
            value = match{2};
            
            data.params(name) = value;
            if strcmpi(name, 'Measurement Status')
                break;
            end
        end
    end
    
    if test_line(thead_expr)
        tableheader = match{:};
        nHeaderLines = iLine;
        
        [names, vnames, units] = headeritems(tableheader);
        
        n = length(vnames);
        for k = 1:n
            vname = vnames{k};
            name = names{k};
            unit = units{k};
            data.(vname).name = name;
            data.(vname).unit = unit;
            data.(vname).column = k;
        end
    else
        raiseErr('unsupported', line);
    end
    
    
    
    %% filename
    [~, name, ext] = fileparts(filename);
    data.filename = [name ext];
    data.fullpath = filename;
    
    %% title
    if nargin >= 2
        data.title = title;
    end
    
    %% Read columns of data according to format string.
    frewind(fileID);
    dataArray = textscan(fileID, formatSpec, Inf, 'HeaderLines', nHeaderLines, 'ReturnOnError', true);

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    %% Allocate imported array to column variable names
    
    for k = 1:n
        vname = vnames{k};
        data.(vname).values = dataArray{k};
    end

end

function [names, vnames, units] = headeritems(headerline)
    items = strsplit(strtrim(headerline), ']');
    items(end) = [];
    n = length(items);
    
    cells = cellfun(@(str)strsplit(str, '['), items, 'uniformoutput', false);
    cells = reshape(strtrim([cells{:}]'), 2, n);
    names = cells(1, :);
    units = cells(2, :);
    
    vnames = genvarname(names);
end

function [names, units] = headersplit(tableheader)
    items = strsplit(strtrim(tableheader), ']');
    items(end) = [];
    n = length(items);
    
    cells = cellfun(@(str)strsplit(str, '['), items, 'uniformoutput', false);
    strtrim([cells{:}]')
    cells = reshape(strtrim([cells{:}]'), 2, n);
    names = cells(1, :);
    units = cells(2, :);
end


function raiseErr(type, line)

    switch type
        case 'unsupported'
            excp = MException('read_aix:unsupported', ['File type not supported: ' line]);
    end
   
    excp.throwAsCaller;
    
end