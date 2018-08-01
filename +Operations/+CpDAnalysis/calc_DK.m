function result = calc_DK(info, data)
    
    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    data = data(i);

    epsilon0 = 8.854e-12;
    
    f0  = round(logspace(3, 5, 21),-1);
    m   = length(f0);
    n   = length(data);

    C_local = NaN(m,n);
    D_local = NaN(m,n);
    
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
        
        c_local(i,:) = C_local(i,:)./elarea*1e12;
        [c_fit(i,1), delta(i,1)] = delta_fit(radius, c_local(i,:));
    end
    
    
    c_avg = mean(c_local, 2);
    D_avg = mean(D_local, 2);
    
    epsr_fit = c_fit*1e-6*thickn/epsilon0;
    epsr_avg = c_avg*1e-6*thickn/epsilon0;
        
    result.f = f0;
    result.ElSizes = elsize;
    result.ElAreas = elarea;
    result.Thick   = thickn;
    result.Clocal  = C_local;
    result.clocal  = c_local;
    result.Dlocal  = D_local;
    result.cAvg   = c_avg(:);
    result.cFit   = c_fit(:);
    result.Davg   = D_avg(:);
    result.deltaR = delta(:);
    result.epsAvg = epsr_avg;
    result.epsFit = epsr_fit;
    
    i = (f0 == 1e3);
    result.eps10k = epsr_fit(i);
    result.D10k   = D_avg(i);
    result.c10k   = c_fit(i);
end


function [C0, delta, func] = delta_fit(R, C)
    initial = [min(C) 1];
    
    opts = statset('nlinfit');
    opts.RobustWgtFun = 'bisquare';
    final = nlinfit(R, C, @model, initial, opts);
    
    C0 = final(1);
    delta = final(2);
    func = @(r)model(final,r);
    
    function c = model(coeffs, r)
        c0 = coeffs(1);
        d = coeffs(2);
        c = c0*(1 + 2*d./r + d^2./r.^2);
    end
end

function y_avg = average_neighborhood(f0, f, y, range_factor)
    fmin = f0/range_factor;
    fmax = f0*range_factor;
    indices = f >= fmin & f <= fmax;
    y_avg = median(y(indices));
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
