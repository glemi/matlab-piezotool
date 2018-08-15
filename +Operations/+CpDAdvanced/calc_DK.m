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
    slope = uval(NaN(m,1));
    
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
            D_local(i,k) = average_neighborhood(f0(i), this.f, this.D, 1.05);
        end
    end
    
    for i = 1:m
        c_local(i,:) = C_local(i,:)./elarea*1e12;
        [c,d,s] = delta_fit(radius, relpos, c_local(i,:));
        c_fit(i,1) = c;
        delta(i,1) = d; 
        slope(i,1) = s; 
    end
    
    for k = 1:n
    	[d,g,r] = loss_fit(f0, C_local(:,k), D_local(:,k));
        D0_fit(k) = d;
        Gp_fit(k) = g;
        Rs_fit(k) = r;
    end
    
    mslope = mean(slope);
    mdelta = mean(delta);
    
    c_slope = repmat(relpos,m,1)*mslope;
    c_delta = 1 + 2*mdelta./repmat(radius,m,1);    
    c_corr = (c_local - c_slope)/c_delta;    
    c_corr = mean(c_corr,2);
    
    c_avg = mean(c_local,2);
    D_avg = mean(D_local,2);
    
    epsr_fit = compute_eps(c_fit*1e-6, info(1).Config);
    epsr_avg = compute_eps(c_avg*1e-6, info(1).Config);
    epsr_corr = compute_eps(c_corr*1e-6, info(1).Config);
    
    result.f = f0;
    result.ElSizes = elsize;
    result.ElAreas = elarea;
    result.Thick   = thickn;
    result.Clocal  = C_local;
    result.clocal  = c_local;
    result.Dlocal  = D_local;
    result.cAvg   = c_avg(:);
    result.cFit   = c_fit(:);
    result.cCorr  = c_corr(:);
    result.Davg   = D_avg(:);
    result.deltaR = delta(:);
    result.slope  = slope(:);
    result.relpos = relpos;
    result.epsAvg = epsr_avg;
    result.epsFit = epsr_fit;
    result.epsCorr = epsr_corr;
    
    i = (f0 == 10000);
    result.eps10k = epsr_fit(i);
    result.D10k   = D_avg(i);
    result.c10k   = c_fit(i);
    
    i = (f0 == 19950);
    result.eps20k = epsr_fit(i);
    result.D20k   = D_avg(i);
    result.c20k   = c_fit(i);
    
    i = (f0 == 39810);
    result.eps40k = epsr_fit(i);
    result.D40k   = D_avg(i);
    result.c40k   = c_fit(i);
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

function [C0, delta, slope, func] = delta_fit(R, x, C)
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
    slope = uval(final(3), interv(3,:), 'interval');
    func  = @(r)model(final,r);
end

function [D0, Gp, Rs] = loss_fit(f, C, D)
    
    function Deff = Deff_model(f, C, D0, Gp, Rs)
        w = 2*pi*f;
        Deff = ((w*C*D0 + Gp).*(w*Rs*C*D0 + Rs*Gp + 1) + (w*Rs*C).^2/Rs)./(w*C);
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
