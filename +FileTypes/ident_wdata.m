function info = ident_wdata(file)

    [~, filetitle] = fileparts(file);
    info = FileTypes.SampleInfo;
    
    wafer = '(?<wafer>[A-Z]+_(box)?(\d+|[A-Z])_(Si|Mo|Pt)?_?\w+)';
    comment = '(?<comment>.*)';
      
    expr = sprintf('%s_?%s?', wafer, comment);     
    match = regexpi(filetitle, expr, 'names');
    
    info.FileName  = filename;
    info.WaferID   = strrep(upper(match.wafer), 'PT', 'Pt');
    
    if isfield(match, 'comment')
        info.Comment = match.comment;
    end
end

