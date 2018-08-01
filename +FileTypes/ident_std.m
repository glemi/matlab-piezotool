function info = ident_std(file)

    [~, filetitle] = fileparts(file);
    info = FileTypes.SampleInfo;
    
    filetitle = regexprep(filetitle, '-freq$', '');
    
    wafer = '(?<wafer>[A-Z]+_(box)?(\d+|[A-Z])_(Si|Mo|Pt)?_?\d+)';
    psample = '(?<sample>(\d\d)[LRC])';
    ssample = '(?<sample>[CS]\d\d|\d\dS)';
    qsample = '(?<sample>(Q[NS][WE][tb]\d))';
    eltrode = '(?<eltrode>\d{3,4}(mu|um|u))';
    mindex  = '(?<mindex>m\d\d?)';
    comment = '(?<comment>.*)';
    
    pexpr = sprintf('%s_%s_?%s?_?%s?_?%s?', wafer, psample, eltrode, mindex, comment);    
    sexpr = sprintf('%s_%s_?%s?_?%s?_?%s?', wafer, ssample, eltrode, mindex, comment);    
    qexpr = sprintf('%s_%s_?%s?_?%s?', wafer, qsample, mindex, comment);     

    pmatch = regexpi(filetitle, pexpr, 'names');
    smatch = regexpi(filetitle, sexpr, 'names');
    qmatch = regexpi(filetitle, qexpr, 'names');
    
    if ~isempty(pmatch)
        match = pmatch;
        
        index = str2double(regexprep(pmatch.sample, '\D', ''));
        default_positions = [7 10 13 16 19 22 25 28 31 34 37 40 43 46 ...
                            49 52 55 58 61 64 67 70 73 76 79 82 85 88];
        info.Mask = 'Photo';
        info.Params = 'ASN_8in_Photo';
        info.Position = default_positions(index+1);
        info.SampleIndex = index;
        
    elseif ~isempty(qmatch)
        match  = qmatch;
        quadrant = qmatch.sample(1:3);
        electrode = qmatch.sample(4:5);
        index1 = strcmp(quadrant, {'QSW' 'QSE' 'QNW' 'QNE'});
        index2 = strcmp(electrode, {'b1' 'b2' 'b3' 'b4' 't1' 't2' 't3' 't4'});
        radial = [19.9 19.1 18.6 18.2 24.5 23.9 23.4 23.1;  ...
                  26.9 28.4 30.0 31.6 30.5 31.8 33.2 34.7;  ...
                  51.7 51.4 51.2 51.1 56.6 56.4 56.2 56.1;  ...
                  54.8 55.5 56.4 57.2 59.5 60.2 60.9 61.7];
        info.Position = radial(index1, index2);
        info.Mask = 'Photo_old';
        info.Params = 'ASN_8in_Photo';
        info.SampleIndex = 10*index1 + index2;
        
    elseif ~isempty(smatch)
        match = smatch;
        index = str2double(regexprep(smatch.sample, '\D', ''));
        default_positions = [9 12 15 18 21 24 27 30 33 ... 
                            36 39 42 45 48 51 54 57 60];
        
        info.Mask = 'Shadow';
        info.Params = 'ASN_8in_Shadow';
        info.Position = default_positions(index);
        info.SampleIndex = index;
        
    else
        %throw('warning', 'FilnamePatternNotRecognized', filename);
        return;
    end
    
    info.WaferID   = strrep(upper(match.wafer), 'PT', 'Pt');
    info.SampleID  = match.sample;
    
    if isfield(match, 'eltrode')
        info.Electrode = match.eltrode;
        info.ElSize = str2double(regexprep(match.eltrode, '\D', ''));
    end
    if isfield(match, 'mindex')
        info.MIndex = str2double(regexprep(match.mindex, '\D', ''));
    end
    if isfield(match, 'comment')
        info.Comment = match.comment;
    end
end

