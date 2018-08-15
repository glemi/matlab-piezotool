function result = calc_DK(info, data)
    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    data = data(i);
    config = info(1).Config;
    
    f0  = round(logspace(3, 5, 21),-1);
    m   = length(f0);
    n   = length(data);

    abscap = uval(NaN(m,n));
    losstg = uval(NaN(m,n));
    
    for i = 1:m
        for k = 1:n
            this = data(k);
            abscap(i,k) = average_neighborhood(f0(i), this.f, this.Cp, 1.05);
            losstg(i,k) = average_neighborhood(f0(i), this.f, this.D, 1.5);
        end
    end
    
    arlcap = uval(NaN(m,n));
    
    c_fit = uval(NaN(m,1));
    delta = uval(NaN(m,1));
    cxslope = uval(NaN(m,1));
    
    abspos = [info.Position];
    refpos = round(mean([abspos]),1);
    relpos = abspos - refpos;
    elsize = [info.ElSize];
    radius = elsize/2;
    elarea = (radius*1e-3).^2*pi;
    thickn = getConfigValue(config, 'tPL');
    arlcap = abscap./repmat(elarea,m,1)*1e12;
   
    
    for i = 1:m
        [c,d,s] = delta_fit(radius, relpos, arlcap(i,:));
        c_fit(i,1) = c;
        delta(i,1) = d;
        cxslope(i,1) = s;
    end
    
    for k = 1:m
    	[d,sgma,r,s] = loss_fit(f0(k), radius, relpos, abscap(k,:), losstg(k,:));
        D0_fit(k)   = d;
        sgma_fit(k) = sgma;
        Rs_fit(k)   = r;
        dxslope(k)  = s;
    end
    
    mslope = mean(cxslope);
    mdelta = mean(delta);
    
    c_slope = repmat(relpos,m,1)*mslope;
    c_delta = 1 + 2*mdelta./repmat(radius,m,1);    
    c_corr = (arlcap - c_slope)./c_delta;    
    c_corr = mean(c_corr,2);
    
    c_avg = mean(arlcap,2);
    D_avg = mean(losstg,2);
    
    epsr_fit = compute_eps(c_fit*1e-6, config);
    epsr_avg = compute_eps(c_avg*1e-6, config);
    epsr_corr = compute_eps(c_corr*1e-6, config);
    
    result.f = f0;
    result.ElSizes = elsize;
    result.ElAreas = elarea;
    result.Thick   = thickn;
    
    result.Clocal  = abscap;
    result.clocal  = arlcap;
    result.Dlocal  = losstg;
    
    result.cAvg   = c_avg(:);
    result.cFit   = c_fit(:);
    result.cCorr  = c_corr(:);
    result.Davg   = D_avg(:);
    result.deltaR = delta(:);
    
    result.cslope = cxslope(:);
    result.dslope = dxslope(:);
    result.relpos = relpos;
    
    result.sigma  = sgma_fit(:);
    result.Rs     = Rs_fit(:);
    result.D0Fit  = D0_fit(:);
    
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

function [D0, sigma, Rs, slope, model] = loss_fit(f, R, x, C, D)
    C = double(C);
    D = double(D);

    function Deff = Deff_model(f, D0, sigma, Rs, s)
%         persistent h;
        w = 2*pi*f;         % Angular frequency (omega)
        A = (R.^2)*pi*1e-6; % Electrode Area in mm^2
        G = sigma.*A;       % Conductance = conductivity x area
        Deff = D0 + G./(w.*C) + w*Rs.*C + s*x;
        
%         fig deffmodel; 
%         try delete(h); end
%         h = plot(R, Deff);
    end

%     fig deffmodel; clf;
%     plot(R, double(D), 'o'); fillmarkers;
%     

    initial = [1e-3 1e-9 1 1e-4];
    modelfcn = @(c,f)Deff_model(f, abs(c(1)), abs(c(2)), abs(c(3)), abs(c(4)));
    [final,res, ~, covar] = nlinfit(f, double(D), modelfcn, initial);
    interv = nlparci(final,res,'covar',covar,'alpha',0.5);

    D0    = uval(final(1), interv(1,:), 'interval');
    sigma = uval(final(2), interv(2,:), 'interval');
    Rs    = uval(final(3), interv(3,:), 'interval');
    slope = uval(final(4), interv(4,:), 'interval');
    model = @(f)modelfcn(final,f);
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

function y_avg = average_neighborhood(f0, f, y, range_factor)
    fmin = f0/range_factor;
    fmax = f0*range_factor;
    i = f >= fmin & f <= fmax;
    y_avg = uval(median(y(i)), iqr(y(i)));
end

