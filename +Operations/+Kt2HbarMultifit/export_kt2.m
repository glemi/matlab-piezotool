function export_kt2(info, data, repo)
    
    wdata = organize(data, info);
    
    if length(unique(wdata.wid)) > 1
        error('All sample data must be from the same wafer');
    end

    %rootdir = 'C:\Users\Nyffeler\switchdrive\AlScN_project\Analysis\Matlab\Repo';
    wafer = info(1).WaferID;
    node = repo.getNode(wafer, 'coupling');
    
    node.add('kt2',    wdata.pos, wdata.kt2);  
	node.add('e33',    wdata.pos, wdata.e33);     
	node.add('c33E',   wdata.pos, wdata.c33E);    
	node.add('c33D',   wdata.pos, wdata.c33D);    
	node.add('epsf',   wdata.pos, wdata.epsf);    
	node.add('epsS',   wdata.pos, wdata.epsS);    
	node.add('QSubst', wdata.pos, wdata.QSubst);  
	node.add('td',     wdata.pos, wdata.td);    
    
    node.write();
end

function wdata = organize(data, samples)
    pars = {'kt2' 'cPiezo' 'QSubst' 'tdPiezo'};
    
    fitdata = [data.fitdata];

    final0 = real(HBAR_parameters([fitdata.FinalConfig], pars));
    final1 = real(HBAR_parameters([fitdata.FinalProcConfig], pars));

    wdata.pos = [samples.Position]';
    wdata.sid = {samples.SampleID}';
    wdata.wid = {samples.WaferID}';

    eps0 =  8.854187817e-12;
    
    % e33 can be calculated from kt2 c33 eps33
    % eps33 can becalculated from kt2 c33 e33
    % only kt2 and c33 are fit parameters so with two unknowns it's not
    % proper to conclude on either e33 or eps33 
    
    wdata.kt2     = final1(:,1)';
    wdata.c33E    = final0(:,3)';
    wdata.c33D    = final1(:,3)';
    wdata.QSubst  = final1(:,5)';
    wdata.td      = final0(:,6)';
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









