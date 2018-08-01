function results = calc_e31(info, data)
    
    assignin('base', 'data', data);
    
    s = data.Displacement.values*1e-9;
    q = data.Charge.values*1e-6;
    
    n = length(s);
    S = [ones(n,1) s];
    b = S\q;

    [smin, k1] = min(s);
    [smax, k2] = max(s);
    s1 = [smin smax];

    q1 = [S(k1,:); S(k2,:)]*b;
    
%     A    = str2double(data.params('Area [mm2]'))                  *1e-6;
%     h    = str2double(data.params('Substrate Thickness [um]'))    *1e-6;
%     nuSi = str2double(data.params('Substrate Poisson Ratio [1]')) *1e+0;
%     l1   = str2double(data.params('Lower Support Distance [mm]')) *1e-3;

    A    = info.Params.ElectrodeArea.Value*1e-6;
    h    = info.Params.SampleThickness.Value*1e-6;
    nuSi = info.Params.PoissonRatio.Value;
    l1   = info.Params.CantileverLength.Value*1e-3;
    
    e31_matlab = b(2)*l1^2/(4*A*h*(1-nuSi));
    e31_aix    = str2double(data.params('e31av [C/m2]'));

    
    results.slope           = b(2);
    results.e31_matlab      = e31_matlab;
    results.e31_aix         = e31_aix;
    results.e31_error       = compute_errorbars(e31_matlab, info);
    
    results.Displacement_measured = s;
    results.Charge_measured = q;
    
    results.Displacement_fit = s1;
    results.Charge_fit      = q1;
    
    results.Area            = A;
    results.Thickness       = h;
    results.PoissonRatio    = nuSi;
    results.Length1         = l1;
end


function De31 = compute_errorbars(e31, info)

    Ae = info.Params.ElectrodeArea.Value*1e-6;
    ts = info.Params.SampleThickness.Value*1e-6;
    nu = info.Params.PoissonRatio.Value;
    L1 = info.Params.CantileverLength.Value*1e-3;

    dAe = info.Params.ElectrodeArea.Delta*1e-6;
    dts = info.Params.SampleThickness.Delta*1e-6;
    dnu = info.Params.PoissonRatio.Delta;
    dL1 = info.Params.CantileverLength.Delta*1e-3;

    M  = -e31*4 * Ae * ts * (1-nu) / (L1^2);
    DA =  abs(dAe * M * L1^2 / (4*Ae^2 * ts * (1-nu)));
    Dt =  abs(dts * M * L1^2 / (4*Ae * ts^2 * (1-nu)));
    DL =  abs(dL1 * M * L1*2 / (4*Ae * ts   * (1-nu)));

    De31 = DA + Dt + DL;
end