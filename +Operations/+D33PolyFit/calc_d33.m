function result = calc_d33(info, data)
    
    [~,i] = sort([info.MIndex]);
    info = info(i); data = data(i);    
    
    dEl_ref = info(1).Params.Refd33ElectrodeSize.Value;
    dEl_delta = info(1).Params.Refd33ElectrodeSize.Delta;
    
    n = length(data);
    fprintf('El Size  d33 (median)    sample \n');
    for k = 1:n
        d33_med(k) = median(data(k).d33);
        d33_std(k) = std(data(k).d33);
        d33_iqr(k) = iqr(data(k).d33);
        dEl(k) = info(k).ElSize;
        
        fprintf('  %5s  %5s %13s m%d\n', sprintf('%d', dEl(k)), sprintf('%.2f', d33_med(k)), info(k).SampleID, info(k).MIndex);
    end
    
    [p, S] = polyfit(dEl, d33_med, 2);
    d33_ref = polyval(p, dEl_ref);
    [~,delta] = polyval(p, dEl_ref, S);
    
    fprintf('\ncoefficients: \t %+f \n\t\t\t\t %+f x \n\t\t\t\t %+f x^2\n', p(:));
    
    upr_d33 = polyval(p, dEl_ref + dEl_delta);
    low_d33 = polyval(p, dEl_ref - dEl_delta);
    
    err_fit = delta;
    err_dEl = max(abs(d33_ref - [upr_d33 low_d33]));
    err_std = mean(d33_std);
    err_iqr = mean(d33_iqr);
    
    result.d33_med = d33_med;
    result.d33_std = d33_std;
    result.dEl_meas = dEl;

    result.d33 = d33_ref;
    result.d33_error.dEl = err_dEl;
    result.d33_error.std = err_std;
    result.d33_error.iqr = err_iqr;
    result.d33_error.fit = err_fit;
    result.d33_error.tot = err_fit + err_dEl + err_iqr;
    
    result.poly_coeffs = p;
    result.poly_err = S;
    
    result.dEl_ref = dEl_ref;
    result.dEl_err = dEl_delta;
    
end

