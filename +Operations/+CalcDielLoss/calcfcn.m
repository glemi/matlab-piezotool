function result = calcfcn(info,data)
    
    f0  = round(logspace(3, 5, 21),-1)';
    n   = length(f0);
    
    elsize = info.ElSize;
    elarea = elsize.^2*pi*1e-6; %in mm^2
    
    C = uval(NaN(n,1));
    D = uval(NaN(n,1));
    
    for k = 1:n
        C(k) = average_neighborhood(f0(k), data.f, data.Cp, 1.05);
        D(k) = average_neighborhood(f0(k), data.f, data.D, 1.25);
    end
    
    [D0,Gp,Rs,model] = loss_fit(f0, double(C), double(D));
    
    result.f = f0;
    result.C = C;
    result.D = D;
    result.Dfit = model(f0);
    result.D0   = D0;
    result.Gp   = Gp;
    result.GpA  = Gp./elarea;
    result.Rs   = Rs;
    
    i = (f0 == 10000);  result.D10k   = D(i);
    i = (f0 == 19950);  result.D20k   = D(i);
    i = (f0 == 39810);  result.D40k   = D(i);
end

function y_avg = average_neighborhood(f0, f, y, range_factor)
    fmin = f0/range_factor;
    fmax = f0*range_factor;
    i = f >= fmin & f <= fmax;
    y_avg = uval(median(y(i)), iqr(y(i)));
end

function [D0, Gp, Rs, model] = loss_fit(f, C, D)
    function Deff = Deff_model(f, D0, Gp, Rs)
%          persistent h;
        w = 2*pi*f;
        Deff = D0 + Gp./(w.*C) + w*Rs.*C;
%          fig test;
%          try delete(h); end
%          h = plot(f, Deff);
    end

%      fig test; clf; 
%      plot(f, D, 'k', 'Linewidth', 2); xscale log; yscale log;
    
    initial = [1e-3 1e-9 1];
    modelfcn = @(c,f)Deff_model(f, abs(c(1)), abs(c(2)), abs(c(3)));
    [final,res, ~, covar] = nlinfit(f, D, modelfcn, initial);
    interv = nlparci(final,res,'covar',covar,'alpha',0.5);

    D0    = uval(final(1), interv(1,:), 'interval');
    Gp    = uval(final(2), interv(2,:), 'interval');
    Rs    = uval(final(3), interv(3,:), 'interval');
    model = @(f)modelfcn(final,f);
end