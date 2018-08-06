function table2clip(tdata, options)
    [n,m] = size(tdata);
    
    cdata = table2cell(tdata);
    ctext = cellfun(@(c)sprintf('%g',c), cdata, 'UniformOutput', false);
    
    tab = sprintf('\t');
    
    for k = 1:n
        lines{k} = strjoin(ctext(k,:), tab);
    end
    block = strjoin(lines, newline);
    
    if ismember('withheaders', options)
        header = strjoin(tdata.Properties.VariableNames, tab);
        block = strjoin({header block}, newline);
    end

    clipboard('copy', block);
end

