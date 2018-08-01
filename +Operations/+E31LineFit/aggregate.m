function aggregate(info, results)

    [~, i] = sort([info.Position]);
    results = results(i);
    info    = info(i);
    
    e31_matlab = -[results.e31_matlab]';
    e31_error = [results.e31_error];
    position =  [info.Position];
    
    wafers = unique({info.WaferID});
    wafers = strjoin(wafers, '-');
    wafers = strrep(wafers, '_', '\_');

    legend off;
    
    line = errorbar(position, e31_matlab, e31_error, 'o');
    line.DisplayName = wafers;
    xlabel 'Position [mm]';

    fillmarkers;
    line.MarkerSize = 8;
    title 'Piezoelectric Coefficient e_{31} [C/m^2]';
    
    legend show; legend Location Best;
    hl = legend;
    hl.Interpreter = 'latex';
    
end
