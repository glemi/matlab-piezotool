function results = calc_s1p_multifit(sample, data)

    scenario.name = 'mag-phase_kt2+C0+Q';
    scenario.title = 'direct Z magnitude-phase mean & envelope fit';
    scenario.fitpar = {'kt2' 'C0' 'cPiezo' 'cTopEl' 'tPiezo' 'tBotEl' 'tTopEl' 'QSubst' 'tdPiezo'};
    %scenario.errors = [ 2e-2 1e-12  10e9    40e-9   20e-9    60e-9   500];
    scenario.errors = [ 10e-2 2e-12  100e9  100e9 40e-9  20e-9   40e-9   500 0.5];
    %scenario.curves = {'fenv:abs:upper' 'fenv:abs:lower' 'env:ph:upper' 'env:ph:lower'};
    scenario.curves = {'fenv:abs:avg' 'renv:abs:u/l' 'env:ph:avg'};
    %scenario.curves = {'env:re:avg' 'renv:abs:u/l' 'env:im:avg'};
    %scenario.curves = {'ripples:C0' 'ripples:Cm'};
    %scenario.curves = {'env:abs:avg' 'renv:abs:u/l'};

    variables = {'td' 'Rc' 'Lc'}; 
    
    f = data.f;
    Zmeas = squeeze(data.z(1,1,:));
    
    [Zclean, prefit] = HBAR_removeparasitics_v4(f, Zmeas, variables);
    
    config = sample.Config;
    config = HBAR_parameters(config, {'tdPiezo', prefit.td, 'QSubst', 800});
        
    if isempty(sample.Config)
        id = 'multifit:missing_config';
        msg = ['No configuration data available for this sample. Check' ...
                'if sampledata file is loaded and config file is present' ...
                'in the parameters directory for this wafer.'];
        error(id, msg);    
    end
    
    Hfit = HBAR_Fit(config);
    Hfit.FitOptions.MaxIterations = 10;
    Hfit.FitOptions.FiniteDifferenceStepSize = 0.01;
    Hfit.FitOptions.Display = 'off';
    Hfit.FitParams = scenario.fitpar;
    Hfit.ParamErrs = scenario.errors;
    Hfit.Curves = scenario.curves;
    Hfit.execute(f, Zclean);
    
    results.vnadata = data;
    results.fitdata = Hfit;
    results.prefit = prefit;
    results.Zclean = Zclean;
    results.scenario = scenario;
    results.timestamp = datetime('now');
    results.parasitics = prefit;
end
