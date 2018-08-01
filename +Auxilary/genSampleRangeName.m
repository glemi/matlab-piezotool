function [range, wrange, srange] = genSampleRangeName(files)
    if isempty(files)
        range = '';
        return;
    end

    if iscellstr(files)
        filenames = files;
    elseif isstruct(files)
        filenames = {files.filetitle};
    end 
    
    n = length(filenames);
    
    wafer  = '[A-Z]+_(box)?(\d+|[A-Z])_(Si|Mo|Pt)?_?\d+';
    sample = '(\d\d)[LRC]|[CS]\d\d|\d\dS|Q[NS][WE][tb]\d';
    expr = sprintf('(?<wafer>%s)_(?<sample>%s)', wafer, sample);   
    match = regexp(filenames, expr, 'names');
    match = [match{:}];
    
    wafers  = {match.wafer};
    samples = {match.sample};
    
    if length(wafers) == n && length(samples) == n
        wrange = strjoin(unique(wafers),'/');
        srange = [samples{1} '-' samples{end}];
        range = [wrange ' ' srange];
    elseif ~isempty(regexpi(files(1).extension, '\.mat$')) 
        range = 'wafers';
    else
        %filenames = sort(filenames);
        first = filenames{1};
        last  = filenames{end};

        n = min(length(first), length(last));
        i = (first(1:n) == last(1:n));

        m = find(~i, 1);

        if first(m-1) == '_'
            wrange = first(1:m-2);
        else
            wrange = first(1:m-1);
        end
        
        srange = sprintf('%s-%s', first(m:end), last(m:end));

        range = [wrange ' ' srange];
    end
end