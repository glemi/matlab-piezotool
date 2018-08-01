function aggr_s1p_multifit(info, results)

    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    results = results(i);
    
    fitdata  = [results.fitdata];
   
    labels = {info.SampleID};
    labels = regexprep(labels, '(\d\d?)[LCR]', '$1');
    labels = regexprep(labels, 'Q([SN])[WE]([tb]\d)', '$2');
    
    runstats(fitdata, labels);
    titlestr = FileTypes.SampleInfo.genRangeName(info);
    ht = suptitle(titlestr);
    ht.Position(2) = ht.Position(2) - 0.05;
    ht.Interpreter = 'none';
end

function [filenames, order] = sortfiles(info)
    filenames = {info.FileName};
    x = filenames;
    
    x = regexprep(x, 'QSE', 'A');
    x = regexprep(x, 'QSW', 'B');
    x = regexprep(x, 'QNE', 'C');
    x = regexprep(x, 'QNW', 'D');
    
    [~, order] = sort(x);
    filenames = filenames(order);
end

function runstats(data, labels)
    order  = {'kt2', 'C0', 'ePiezo', ...
              'cPiezo', 'epsPiezo', 'QSubst', ...
              'tTopEl', 'tPiezo', 'tBotEl'};
          
    fitpars = data(1).FitParams;
    dispars = union(data(1).FitParams, {'kt2', 'C0', 'ePiezo', 'epsPiezo'});
    dispars = templateorder(unique(dispars), order);
    
    initl = real(HBAR_parameters([data.InitialProcConfig], dispars));
    final = real(HBAR_parameters([data.FinalProcConfig], dispars));
    
    rows = 3;
    cols = 3;
    
    n = length(data);
    pos = 1:n;
    
    m = min(length(dispars),9);
    for k = 1:m
        ax = subplot(rows,cols,k);
        try; statplot(pos, initl(:,k), final(:,k), dispars{k}, labels, k==3); end; %#ok
        if ismember(dispars{k}, fitpars)
            ax.LineWidth = 1.5;
        end
    end
end

function statplot(x, y0, y, param, labels, legendOn)
    %opt legendOn boolean false;
    ax = gca;
    
    if strncmpi(param, 'eps', 3) && mean(y) < 1
        eps0 =  8.854187817e-12;
        y = y/eps0;
        y0 = y0/eps0;
    end
    
    avg  = median(real(y));
    xrange = [x(1) x(end)];
    
    plot(x, y, 'o-', 'MarkerSize', 7); % fit result
    plot(xrange, [avg avg]); % average
    if ~isempty(y0) % initial guess
        plot(x, y0, 'k--', 'LineWidth', 1);
    end
    
    yrange = getyrange(y0, avg, y);
    
    getexponent = @(y)floor(log10(mean(y))) - mod(floor(log10(mean(y))), 3);
    ax.YLim = yrange;
    ax.XLim = xrange;
    ax.XTick = x; 
    ax.XTickLabel = labels;
    ax.XAxis.FontSize = 8;
    ax.YAxis.Exponent = getexponent(yrange);
    fillmarkers;

    stravg = HBAR_print('latex', param, avg);
    title([stravg{:} ' (median)'], 'Interpreter', 'latex');
    
    if legendOn
        legend('Fit Result', 'Average', 'Initial Guess');
        legend location best;
    end
end

function [clower, cupper] = cicompute(fitdata, config)
    names = fitdata.FitParams;
    resid = fitdata.FitOutput.residual;
    jacob = fitdata.FitOutput.jacobian;
    ci = nlparci(fitdata.final, resid, 'jacobian', jacob);
    
    clower = HBAR_parameters(config, names, ci(:,1)); 
    cupper = HBAR_parameters(config, names, ci(:,2));
end

function yrange = getyrange(y0, yavg, y)
    dy0 = mean(abs(y-y0));
    dy1 = mean(abs(y-yavg));
    dy  = max(dy0, dy1);
    y0  = yavg;
    if dy == 0
        dy = y0*0.075;
    end
    yrange = [y0-2*dy y0+2*dy];
end