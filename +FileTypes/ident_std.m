function info = ident_std(file)

    [~, filetitle] = fileparts(file);
    info = FileTypes.SampleInfo;
    
    filetitle = regexprep(filetitle, '-freq$', '');
    
    wafer = '(?<wafer>[A-Z]+_(box)?(\d+|[A-Z])_(Si|Mo|Pt)?_?\d+)';
    psample = '(?<sample>(\d\d)[LRC])';
    ssample = '(?<sample>[CS]\d\d|\d\dS)';
    qsample = '(?<sample>(Q[NS][WE][tb]\d))';
    rsample = '(?<sample>(Q1BL_[RL]\d\d?))';
    usample = '(?<sample>(Q[NS][WE]_R\d))';
    eltrode = '(?<eltrode>\d{3,4}(mu|um|u))';
    mindex  = '(?<mindex>m\d\d?)';
    comment = '(?<comment>.*)';
    
    pexpr = sprintf('%s_%s_?%s?_?%s?_?%s?', wafer, psample, eltrode, mindex, comment);    
    sexpr = sprintf('%s_%s_?%s?_?%s?_?%s?', wafer, ssample, eltrode, mindex, comment);    
    qexpr = sprintf('%s_%s_?%s?_?%s?', wafer, qsample, mindex, comment);     
    rexpr = sprintf('%s_%s_?%s?_?%s?', wafer, rsample, mindex, comment); 
    uexpr = sprintf('%s_%s_%s_?%s?_?%s?', wafer, usample, eltrode, mindex, comment);    

    pmatch = regexpi(filetitle, pexpr, 'names');
    smatch = regexpi(filetitle, sexpr, 'names');
    qmatch = regexpi(filetitle, qexpr, 'names');
    rmatch = regexpi(filetitle, rexpr, 'names');
    umatch = regexpi(filetitle, uexpr, 'names');
    
    if ~isempty(pmatch)
        match = pmatch;
        
        index1 = str2double(regexprep(pmatch.sample, '\D', ''));
        default_positions = [7 10 13 16 19 22 25 28 31 34 37 40 43 46 ...
                            49 52 55 58 61 64 67 70 73 76 79 82 85 88];
                        
        index2 = strncmpi(match.eltrode, {'600' '700' '800' '900' '1000' '1100'}, 3);
        
        info.Mask = 'Photo';
        info.Params = 'ASN_8in_Photo';
        info.Position = default_positions(index1+1);
        info.SampleIndex = index1;
        
        if any(index2)
            relative = [-0.7 -0.7 0.7 -0.7 0.7 0.7];
            info.Position = info.Position + relative(index2);
        end
        
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
        
    elseif ~isempty(rmatch)
        match  = rmatch;
        side    = rmatch.sample(6); % R or L
        electrode = rmatch.sample(7:end);
        index1 = strcmp(side, {'R' 'L'});
        index2 = str2double(electrode);
        radial = [48.9 49.4 50.1 50.9 51.9 53.1 54.3 55.8 57.3 58.9;  ...
                  73.8 74.1 74.6 75.1 75.8 76.6 77.5 78.5 79.6 80.8];
        info.Position = radial(index1, index2);
        info.Mask = 'Shadow';
        info.Params = 'ASN_8in_Shadow';
        info.SampleIndex = 10*index1 + index2;
        
    elseif ~isempty(umatch)
        match  = umatch;
        quadrant = umatch.sample(1:3);
        row = umatch.sample(5:6);
        electrode = umatch.eltrode(1:3);
        index1 = strcmp(quadrant, {'QSE' 'QNE' 'QSW' 'QNW'});
        index2 = strcmp(electrode, {'400' '500' '600' '700' '800' '900'});
        index3 = strcmp(row, {'R1' 'R2' 'R3' 'R4'});
        
        index1 = find(index1,1);
        index2 = find(index2,1);
        index3 = find(index3,1);
        
        %           400u 500u 600u 700u 800u 900u      % Row1   
        r(:,:,1) = [27.2 28.4 29.5 30.8 32.0 33.3; ... % QSE 
                    55.8 56.4 57.0 57.6 58.3 59.0; ... % QNE 
                    21.7 21.0 20.5 20.1 19.7 19.6; ... % QSW 
                    53.4 53.1 52.9 52.7 52.6 52.5];    % QNW 

        %           400u 500u 600u 700u 800u 900u  ... % Row2  
        r(:,:,2) = [28.7 29.8 30.9 32.1 33.3 34.5; ... % QSE 
                    57.7 58.3 58.8 59.5 60.1 60.8; ... % QNE 
                    23.5 22.9 22.4 22.0 21.7 21.6; ... % QSW 
                    55.3 55.1 54.9 54.7 54.6 54.5];    % QNW 

        %           400u 500u 600u 700u 800u 900u  ... % Row3  
        r(:,:,3) = [31.0 32.0 33.1 34.2 35.3 36.5; ... % QSE 
                    60.6 61.1 61.6 62.2 62.9 63.5; ... % QNE 
                    26.3 25.7 25.3 24.9 24.7 24.5; ... % QSW 
                    58.3 58.0 57.8 57.7 57.6 57.5];    % QNW 

        %           400u 500u 600u 700u 800u 900u  ... % Row4  
        r(:,:,4) = [32.6 33.6 34.6 35.6 36.7 37.8; ... % QSE 
                    62.5 63.0 63.5 64.1 64.7 65.3; ... % QNE 
                    28.2 27.7 27.2 26.9 26.7 26.5; ... % QSW 
                    60.3 60.0 59.8 59.7 59.6 59.5];    % QNW         
        
        info.Position = r(index1, index2, index3);
        info.Mask = 'Shadow';
        info.Params = 'ASN_8in_Shadow';
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

% Sample Positions on Old Photomask Layout
% R1  400u 500u 600u 700u 800u 900u
% QSE 27.2 28.4 29.5 30.8 32.0 33.3
% QNE 55.8 56.4 57.0 57.6 58.3 59.0
% QSW 21.7 21.0 20.5 20.1 19.7 19.6
% QNW 53.4 53.1 52.9 52.7 52.6 52.5
%                          
% R2  400u 500u 600u 700u 800u 900u
% QSE 28.7 29.8 30.9 32.1 33.3 34.5
% QNE 57.7 58.3 58.8 59.5 60.1 60.8
% QSW 23.5 22.9 22.4 22.0 21.7 21.6
% QNW 55.3 55.1 54.9 54.7 54.6 54.5
%                       
% R3  400u 500u 600u 700u 800u 900u
% QSE 31.0 32.0 33.1 34.2 35.3 36.5
% QNE 60.6 61.1 61.6 62.2 62.9 63.5
% QSW 26.3 25.7 25.3 24.9 24.7 24.5
% QNW 58.3 58.0 57.8 57.7 57.6 57.5
% 
% R4  400u 500u 600u 700u 800u 900u
% QSE 32.6 33.6 34.6 35.6 36.7 37.8
% QNE 62.5 63.0 63.5 64.1 64.7 65.3
% QSW 28.2 27.7 27.2 26.9 26.7 26.5
% QNW 60.3 60.0 59.8 59.7 59.6 59.5
