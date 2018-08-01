function result = plot_s1p_multifit(info, result)
    dataname = FileTypes.SampleInfo.genRangeName(info);
    plot_fitresult(result, dataname);
    watchoff;
    
    axes('Position', [0.12 0.01 0.79 0.06]);
    ht1 = text(1, 0.8, ['Calculated: ' char(result.timestamp)]);
    ht2 = text(1, 0.5, strjoin(result.scenario.curves, ', '));
    ht3 = text(1, 0.2, strjoin(result.scenario.fitpar, ', '));
    set([ht1 ht2 ht3], 'HorizontalAlignment', 'right');
    
    if ~isfield(result.parasitics, 'td')
        result.parasitics.td = NaN;
    end
    
    c0str = sprintf(' C_0 = %.2fpF,', result.parasitics.C0*1e12);
    tdstr = sprintf(' tan(\\delta) = %.2f%%,', result.parasitics.td*100);
    rcstr = sprintf(' R_c = %.1f\\Omega,', result.parasitics.Rc);
    lcstr = sprintf(' L_c = %.2fnF,', result.parasitics.Lc*1e9);
    %rpstr = sprintf(' R_p = %.1e\\Omega', result.parasitics.Rp/1e6);
    ht4 = text(0, 0.15, ['Parasitics:' c0str tdstr rcstr lcstr]);
    ht4.Interpreter = 'tex';
    axis off;
end

function plot_fitresult(result, samplename)

    fitdata = result.fitdata.fitdata;
    if ~isfield(fitdata, 'Zclean')
        Zmeas = fitdata.Zmeas;
    else
        Zmeas = fitdata.Zclean;
    end
    f = fitdata.f; fGHz = f/1e9;

    Zfit = fitdata.Zfit;
    absz = abs(Zfit);
    
    subplot(4,4,[1 2 5 6]); title 'HBAR Fit'
    %xlim([1.5 3.5]); %ylim([20 120]);
    ylim([min(absz) max(absz)].*[0.5 2]);
    xscale log; yscale log;
    
    plot(fGHz, abs(Zmeas));
    plot(fGHz, absz);
    
    %% Print results on separate axes.
    subplot(4,4,[3 4 7 8]); title 'results';
    set(gca, 'XTick', [], 'YTick', []);
    %HBAR_print('plain', fitpar, fit.final); 
    ltext1 = HBAR_print('blocklatex', fitdata.names, fitdata.final); 
    label([0.25 0.4], ltext1);
    label([0.2 0.9], samplename, 'Arial16', 'Interpreter', 'none');
    ylim(round([min(absz) max(absz)].*[0.5 1.5], -1));
    
    %% Plot Parameters
    fitcurves = fitdata.curves;
    curves = {'ripples:keff' 'ripples:C0' 'ripples:Cm' 'ripples:dfr'...
        'env:abs:avg'  'env:ph:avg' 'env:im:avg' 'renv:abs:u/l'};
    [Mmeas, F] = HBAR_postprocess(f, Zmeas, curves, 300, 'noExtrap');
    [Mfit]     = HBAR_postprocess(f, Zfit, curves, 300, 'noExtrap');
    n = min(length(curves), 8);
    for k = 1:n
        subplot(4,4,k+8);
        HBAR_curveplot(F, hampel(Mmeas(:,k)), curves{k});
        HBAR_curveplot(F, hampel(Mfit(:,k)),  curves{k});
        axis tight; ylim(ylim + diff(ylim).*[-1 1]/10);
        if strcmpi(curves{k}, 'ripples:dfr')
            ylim([5.75 5.85]);
        end
        if ismember(curves{k}, fitcurves)
            set(gca, 'LineWidth', 1.5);
        end
    end
end