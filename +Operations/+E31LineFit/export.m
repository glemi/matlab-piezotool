function export_e31(data, samples, outfile)
    
    n = length(data);

    pos = [samples.Position];
    [pos, order] = sort(pos);
    data = data(order);
    samples = samples(order);
    
    e31 = -[data.e31_matlab];
    stress = [samples.Stress];

    
    if isfield(samples, 'Parameters') && ~isempty([samples.Parameters])
        De31 = compute_errorbars(e31, samples);
    else
        De31 = nan(n, 1);
    end
    
    top     = {samples(1).WaferID '' '' '' 'File generated:' datestr(now)};
    empty   = {'' '' '' '' '' ''};
    headers = {'sample' 'position' 'stress' 'e31f' 'slope' 'error'};
    units   = {'' 'mm' 'MPa' 'C/m^2' '' 'C/m^2'}; 
    for k = 1:n
        columns{k, 1} = samples(k).SampleID;
        columns{k, 2} = samples(k).Position;
        columns{k, 3} = samples(k).Stress;
        columns{k, 4} = data(k).e31_matlab;
        columns{k, 5} = data(k).slope;
        columns{k, 6} = De31(k);
    end
    
    array = [top; empty; headers; units; columns];
    xlswrite(outfile, array);
end


function De31 = compute_errorbars(e31, samples)
    n = length(samples);
    for k = 1:n
        sample = samples(k);
        Ae(k) = sample.Parameters.ElectrodeArea.Value*1e-6;
        ts(k) = sample.Parameters.SampleThickness.Value*1e-6;
        nu(k) = sample.Parameters.PoissonRatio.Value;
        L1(k) = sample.Parameters.CantileverLength.Value*1e-3;

        dAe(k) = sample.Parameters.ElectrodeArea.Delta*1e-6;
        dts(k) = sample.Parameters.SampleThickness.Delta*1e-6;
        dnu(k) = sample.Parameters.PoissonRatio.Delta;
        dL1(k) = sample.Parameters.CantileverLength.Delta*1e-3;
    end

    M  = -e31*4 .* Ae .* ts .* (1-nu) ./ (L1.^2);
    DA =  abs(dAe .* M .* L1.^2 ./ (4*Ae.^2 .* ts .* (1-nu)));
    Dt =  abs(dts .* M .* L1.^2 ./ (4*Ae .* ts.^2 .* (1-nu)));
    DL =  abs(dL1 .* M .* L1*2  ./ (4*Ae .* ts    .* (1-nu)));

    fprintf('wafer thickness: %.0fum\n', ts(1)*1e6); 
    
    De31 = DA + Dt + DL;
end