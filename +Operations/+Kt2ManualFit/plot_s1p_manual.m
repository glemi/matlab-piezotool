function plot_s1p_manual(info, data)
    if isempty(info.Config)
        id = 'multifit:missing_config';
        msg = ['No configuration data available for this sample. Check ' ...
                'if sampledata file is loaded and config file is present ' ...
                'in the parameters directory for this wafer.'];
        error(id, msg);    
    end
    
    hfig = gcf;%clf;
    
    f = data.f;
    Zmeas = squeeze(data.z(1,1,:));
    [Zclean, prefit] =  HBAR_removeparasitics_v4(f, Zmeas, {'td' 'Rc' 'Lc'});
    config = info.Config;
    config = HBAR_parameters(config, {'tdPiezo', prefit.td, 'C0', prefit.C0, 'QSubst', 800});
    
    mplot(f, Zclean, true, hfig);
    
    hbarui = HBAR_paramui(config);
    hbarui.params =  {'kt2' 'C0' 'cPiezo' 'tPiezo' 'cTopEl' 'cBotEl' 'tTopEl' 'tBotEl' 'tSubst' 'QSi' 'QPiezo' 'tdPiezo'};
    hbarui.Callback = @(c)callback(hbarui, c, hfig);
    hbarui.frequency = f;
    hbarui.start();
end

function mplot(f, Z, keep, hfig)
    opt keep logical false;
    persistent hlines;
    
    curves = {'env:abs:upper' 'env:abs:lower' 'env:ph:upper' 'env:ph:lower' 'ripples:keff' 'ripples:Cm' 'ripples:diff(fr)' 'renv:abs:u/l' 'ripples:C0' 'ripples:Qm'};
    %curves = {'direct:abs' 'direct:ph'};
    if keep
        [M, F] = HBAR_postprocess(f, Z, curves, 100, 'noSkip', 'noExtrap');
    else
        [M, F] = HBAR_postprocess(f, Z, curves, 100);
    end
        
    figure(hfig);
    try delete(hlines); end;
    if keep
        h = HBAR_Mplot(F, M, curves, '-');
        delete(h(1:4)); 
        ax = subplot(4,2,1); ax.ColorOrderIndex = ax.ColorOrderIndex -2;
        %ax = subplot(2,1,1);
        plot(f/1e9, abs(Z));
        
        ax = subplot(4,2,2); ax.ColorOrderIndex = ax.ColorOrderIndex -2;
       % ax = subplot(2,1,2);
        plot(f/1e9, angle(Z)*180/pi);
    else
        hlines = HBAR_Mplot(F, M, curves, 'k-');
    end
end

function callback(hbarui, config, hfig)
    params = hbarui.params;
    HBAR_print('plain', params, config);
    
    f = hbarui.frequency;
    [Z, hbar] = HBAR_v4(f, config);
    mplot(f, Z, false, hfig);
    
    names = {'kt2', 'C0'};
    values = [hbar.kt2 hbar.C0];
    latex = HBAR_print('blocklatex', names, values);
    latexfigure('hbarvalues', latex);
    figure(hbarui.figure);
end
