function result = calc_DK(info, data)
    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    data = data(i);
    
    f0  = round(logspace(3, 5, 21),-1);
    m   = length(f0);
    n   = length(data);

    C_local = uval(NaN(m,n));
    D_local = uval(NaN(m,n));
    c_local = uval(NaN(m,n));
    c_fit = uval(NaN(m,1));
    delta = uval(NaN(m,1));
    grad = uval(NaN(m,1));
    
    abspos = [info.Position];
    refpos = round(mean([abspos]),1);
    relpos = abspos - refpos;
    elsize = [info.ElSize];
    radius = elsize/2;
    elarea = (radius*1e-3).^2*pi;
    thickn = get_thickness(info(1));
    
    for i = 1:m
        for k = 1:n
            this = data(k);
            C_local(i,k) = average_neighborhood(f0(i), this.f, this.Cp, 1.05);
            D_local(i,k) = average_neighborhood(f0(i), this.f, this.D, 1.25);
        end
    end
    
    for i = 1:m
        c_local(i,:) = C_local(i,:)./elarea*1e12;
        [c,d,s] = delta_fit(radius, relpos, c_local(i,:));
        c_fit(i,1) = c;
        delta(i,1) = d; 
        grad(i,1) = s; 
    end
    
    for k = 1:n
    	[d,g,r] = loss_fit(f0, C_local(:,k), D_local(:,k));
        D0_fit(k) = d;
        Gp_fit(k) = g;
        Rs_fit(k) = r;
        
        p = polyfit(log10(data(k).f), data(k).Cp, 2);
        Cpfit = polyval(p, log10(data(k).f));
        Cp_slope(k,:) = ( p(2) + 2*p(1)*log10(data(k).f) ) ./Cpfit;
    end
    
    mgrad = mean(grad);
    mdelta = mean(delta);
    
    c_grad = repmat(relpos,m,1)*mgrad;
    c_delta = 1 + 2*mdelta./repmat(radius,m,1);    
    c_corr = (c_local - c_grad)./c_delta;    
    c_corr = mean(c_corr,2);
    
    c_avg = mean(c_local,2);
    D_avg = mean(D_local,2);
    s_avg = mean(Cp_slope,2);
    
    epsr_fit = compute_eps(c_fit*1e-6, info(1).Config);
    epsr_avg = compute_eps(c_avg*1e-6, info(1).Config);
    epsr_corr = compute_eps(c_corr*1e-6, info(1).Config);
    
    result.f = f0;                  % Frequency points where evaluated
    result.ElSizes = elsize;        % Electrode diameter in um (e)
    result.ElAreas = elarea;        % Electrode area in mm^2 (e)
    result.Thick   = thickn;        % Piezo film thickness (s)
    result.Clocal  = C_local;       % Abs capacitance (f)
    result.clocal  = c_local;       % Areal capacitance (f)
    result.Dlocal  = D_local;       % Loss factor (f)
    result.Cslope = s_avg(:);       % Relative slope of Cp per decade (f)
    result.cAvg   = c_avg(:);       % Average areal capacitance (f)
    result.cFit   = c_fit(:);       % Fit of areal capacitance (f)
    result.cCorr  = c_corr(:);      % Areal cap corrected (f)
    result.Davg   = D_avg(:);       % Average loss factor (f)
    result.deltaR = delta(:);       % Electrode radius error from fit (f)
    result.grad  = grad(:);         % Local gradient of areal cap (f)
    result.relpos = relpos;         % Relative position of electrode (e)
    result.epsAvg = epsr_avg;       % DK from average capacitance (f) 
    result.epsFit = epsr_fit;       % DK from capacitance fit (f)
    result.epsCorr = epsr_corr;     % DK from corrected capacitance (f)
    % legend: (f) function of frequency [column]
    %         (e) function of electrode [row]
    
    result.Dmin = min(D_avg);
    
    i = (f0 == 10000);
    result.eps10k = epsr_fit(i);
    result.D10k   = D_avg(i);
    result.c10k   = c_fit(i);
    result.s10k   = s_avg(i);
    
    i = (f0 == 19950);
    result.eps20k = epsr_fit(i);
    result.D20k   = D_avg(i);
    result.c20k   = c_fit(i);
    result.s20k   = s_avg(i);
    
    i = (f0 == 39810);
    result.eps40k = epsr_fit(i);
    result.D40k   = D_avg(i);
    result.c40k   = c_fit(i);
    result.s40k   = s_avg(i);
end

function epsPiezo = compute_eps(cap, config)
    if isempty(config)
        error 'Config Data needed for this operation.';
    end
    epsilon0 = 8.854e-12;
    tPiezo   = getConfigValue(config, 'tPL');
    tSeed    = getConfigValue(config, 'tPS');
    epsSeed  = getConfigValue(config, 'epsPS');
    
    if isnan(tSeed.Value)
        epsPiezo = cap*tPiezo/epsilon0;
    else
        epsPiezo = tPiezo./(1./cap - tSeed/epsSeed)/epsilon0;
    end
end

function value = getConfigValue(config, name)
    value = HBAR_parameters(config, name);
    ubound = HBAR_parameters(config.ubound, name);
    lbound = HBAR_parameters(config.lbound, name);
    
    if isnumeric(value)
        value = uval(value, [lbound ubound]);
        if ubound == lbound 
            switch name
                case 'epsPS', value = uval(value, 0.2);
                case 'tPL', value = uval(value, 50e-9);
                case 'tPS', value = uval(value, 20e-3);
            end
        end
    end
end

function [C0, delta, grad, func] = delta_fit(R, x, C)
    function c = model(coeffs, r)
        c0 = coeffs(1); % reference areal capacity
        d = coeffs(2); % delta_R (absolute error in electrode radius)
        s = coeffs(3); % slope of position-dependent gradient
        c = c0*(1 + 2*d./r + d^2./r.^2) + s*x;
    end

    initial = [min(double(C)) 1 1];
    opts = statset('nlinfit');
    opts.RobustWgtFun = 'bisquare';
    [final,res,~,covar] = nlinfit(R, double(C), @model, initial, opts);
    %[final,res,~,Covar] = nlinfit(R, double(C), @model, initial);
    interv = nlparci(final,res,'covar',covar,'alpha',0.5);
    
    C0    = uval(final(1), interv(1,:), 'interval');
    delta = uval(final(2), interv(2,:), 'interval');
    grad  = uval(final(3), interv(3,:), 'interval');
    func  = @(r)model(final,r);
end

function [D0, Gp, Rs] = loss_fit(f, C, D)
    D = double(D);
    C = double(C);
    
    function Deff = Deff_model(f, C, D0, Gp, Rs)
        w = 2*pi*f(:);
        Deff = D0 + Gp./(w.*C) + w*Rs.*C;
    end
    
    initial = [1e-3 1e-9 1];
    modelfcn = @(c,f)Deff_model(f, C, c(1), c(2), c(3));
    [final,res, ~, covar  ] = nlinfit(f, D, modelfcn, initial);
    interv = nlparci(final,res,'covar',covar,'alpha',0.5);

    D0    = uval(final(1), interv(1,:), 'interval');
    Gp    = uval(final(2), interv(2,:), 'interval');
    Rs    = uval(final(3), interv(3,:), 'interval');
end

function y_avg = average_neighborhood(f0, f, y, range_factor)
    fmin = f0/range_factor;
    fmax = f0*range_factor;
    i = f >= fmin & f <= fmax;
    y_avg = uval(median(y(i)), iqr(y(i)));
end

function t = get_thickness(sampledata)
    if ~isempty(sampledata.Config)
        layers = sampledata.Config.layers;
        player = structFind(layers, 'type', 'PL');
        t = player.thickness;
    else
        error 'Config Data needed for this operation.';
    end
end
