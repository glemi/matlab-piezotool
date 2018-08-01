function [data] = read_dql(filename, title)
    % http://cp.literature.agilent.com/litweb/pdf/ads2004a/cktsim/ck04a12.html
    % http://cp.literature.agilent.com/litweb/pdf/ads2004a/cktsim/ck04a8.html

    % Prepare data structure
    data.header = containers.Map;
    data.params = struct;
    
    % Format string for each line of text:
    %formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';
    formatSpec = '%f,%f,';
    
    % Open the text file.
    fileID = fopen(filename,'r');

    %% Header
    
    line = fgetl(fileID);
    if ~strcmp(line, ';RAW4.00')
        raiseErr('unsupported', line);
    end
    
    title_expr = '(\w+)';
    blank_expr = '';
    param_expr = '(.+)=(.*)';
    phead_expr = '\[(\w+)\]';
    thead_expr = '(\s*[a-zA-Z]+,)+';
    trow_expr = '(\s*[\d\.]+,)+';
    
    function ok = test_line(expr)
        iLine = iLine + 1;
        line = fgetl(fileID);
        match = regexp(line, expr, 'tokens');
        ok = ~isempty(match);
        if ok 
            match = match{:};
        end
    end

    match = {};
    groupname = '';
    groupindex = 1;

    cont = true;
    iLine = 1;
    
    while cont    
        if test_line(phead_expr)
            groupname = match{1};
            if isfield(data, 'params') && isfield (data.params, groupname)
                groupindex = length(data.params.(groupname)) + 1;
            else
                groupindex = 1;
            end
            
        elseif test_line(param_expr)
            name = match{1};
            value = match{2};
            
            if ~isempty(groupname)
                data.params.(groupname)(groupindex).(name) = value;
            else
                data.params(name) = value;
            end
            
        end
            
        if strcmp(groupname, 'Data')
            break;
        end
    end
    
    if test_line(thead_expr)
        tableheader = match{:};
        nHeaderLines = iLine;
        
        [names, vnames] = headeritems(tableheader);
        
        n = length(vnames);
        for k = 1:n
            vname = vnames{k};
            name = names{k};
            data.(vname).name = name;
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

function [names, vnames] = headeritems(headerline)
    items = strsplit(headerline, ',');
    names = strtrim(items(1:end-1));
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