function ops = def(ops)

    op = Operations.Operation('E31LineFit');
        op.Title = 'e31 Line Fit';
        op.Description = ['Computes the e31,f coefficient from data'...
            'measured using the aix-ACCT characterization instrument'];
        op.FileType = 'E31Data';
        op.Aggregatable = false;
        op.CalculateFcn = @Operations.E31LineFit.calc_e31;
        op.ResultPlotFcn = @Operations.E31LineFit.plot_e31;
        op.MultiResultPlotFcn = @Operations.E31LineFit.aggregate;
        op.ExportFcn = @Operations.E31LineFit.export;
        op.SubmitFcn = @Operations.E31LineFit.submit_e31;
    ops.add(op);
    
    op = Operations.Operation('Kt2HbarMultifit');
        op.Title = 'kt2 HBAR Multifit (mag/phase)';
        op.Description = ['Removes parasitics and performs a HBAR fit'...
            'using filtered magnitude and phase curves.'];
        op.FileType = 's1pData';
        op.Aggregatable = false;
        op.CalculateFcn = @Operations.Kt2HbarMultifit.calc_s1p_multifit;
        op.RawPlotFcn = @Operations.Kt2HbarMultifit.plot_s1p;
        op.ResultPlotFcn = @Operations.Kt2HbarMultifit.plot_s1p_multifit;
        op.MultiResultPlotFcn = @Operations.Kt2HbarMultifit.aggr_s1p_multifit;
        op.SubmitFcn = @Operations.Kt2HbarMultifit.export_kt2;
    ops.add(op);
    
    op = Operations.Operation('Kt2ManualFit');
        op.Title = 'kt2 Manual HBAR Fit';
        op.Description = ['Adjust Paramters manually to match measured '...
            'data with HBAR simulation.'];
        op.FileType = 's1pData';
        op.Aggregatable = false;
        op.RawPlotFcn = @Operations.Kt2ManualFit.plot_s1p_manual;
    ops.add(op);
    
    op = Operations.Operation('BawParasitics');
        op.Title = 'Extract Parasitics through BvD Fit';
        op.Description = ['Fit the VNA measured data with an extended ' ...
            'BvD model in order to extract parasitics'];
        op.FileType = 's1pData';
        op.Aggregatable = false;
        op.RawPlotFcn = @Operations.BawParasitics.plot_s1p_parasitics;
    ops.add(op);
    
    op = Operations.Operation('CpDAnalysis');
        op.Title = 'Cp/D Analysis';
        op.Description = ['Computes Capacitance, Loss Factor and '...
            'dielectric constant from multiple CpD data files.'];
        op.FileType = 'CpDData';
        op.Aggregatable = true;
        op.RawPlotFcn = @Operations.CpDAnalysis.plot_cpd;
        op.CalculateFcn = @Operations.CpDAnalysis.calc_DK;
        op.ResultPlotFcn = @Operations.CpDAnalysis.plot_DK;
        op.SubmitFcn = @Operations.CpDAnalysis.submit_DK;
    ops.add(op);
    
    op = Operations.Operation('CpDAdvanced');
        op.Title = 'Advanced Cp/D Analysis';
        op.Description = ['Computes Capacitance, Loss Factor and '...
            'dielectric constant from multiple CpD data files.'];
        op.FileType = 'CpDData';
        op.Aggregatable = true;
        op.RawPlotFcn = @Operations.CpDAdvanced.cpd_plot;
        op.CalculateFcn = @Operations.CpDAdvanced.calc_DK;
        op.ResultPlotFcn = @Operations.CpDAdvanced.plot_DK;
        op.SubmitFcn = @Operations.CpDAdvanced.submit_DK;
    ops.add(op);
    
    
    op = Operations.Operation('CalcDielLoss');
        op.Title = 'Extract Dielectric Losses';
        op.Description = ['Calculcates the dielectric loss Factor '...
            'from CpD measurements, taking into account parsitic ' ...
            'resistance and leakage conductance.'];
        op.FileType = 'CpDData';
        op.Aggregatable = false;
        %op.RawPlotFcn = @Operations.CalcDielLoss.cpd_plot;
        op.CalculateFcn = @Operations.CalcDielLoss.calcfcn;
        op.ResultPlotFcn = @Operations.CalcDielLoss.resultplot;
        op.MultiResultPlotFcn = @Operations.CalcDielLoss.aggrplot;
        op.SubmitFcn = @Operations.CalcDielLoss.submit;
    ops.add(op);
    
    op = Operations.Operation('D33PolyFit');
        op.Title = 'd33 Polyfit';
        op.Description = ['Computes a median value from the d33 spectra' ...
            ' and interpolates the value for the ideal electrode size.'];
        op.FileType = 'd33Data';
        op.Aggregatable = true;
        op.Cacheable = false; % don't bother caching, calculating is faster
        op.RawPlotFcn = @Operations.D33PolyFit.plot_d33;
        op.CalculateFcn = @Operations.D33PolyFit.calc_d33;
        op.ResultPlotFcn = @Operations.D33PolyFit.aggr_d33;
        op.SubmitFcn = @Operations.D33PolyFit.submit_d33;
    ops.add(op);
    
    op = Operations.Operation('D33LineFit');
        op.Title = 'd33 Line Fit';
        op.Description = ['Computes a median value from the d33 spectra' ...
            ' and interpolates the value for the ideal electrode size.'];
        op.FileType = 'd33Data';
        op.Aggregatable = true;
        op.Cacheable = false; % don't bother caching, calculating is faster
        op.RawPlotFcn = @Operations.D33LineFit.plot_d33;
        op.CalculateFcn = @Operations.D33LineFit.calc_d33;
        op.ResultPlotFcn = @Operations.D33LineFit.aggr_d33;
        op.SubmitFcn = @Operations.D33LineFit.submit_d33;
    ops.add(op);
    
    op = Operations.Operation('StressImport');
        op.Title = 'Import Stress Data';
        op.Description = ['Import and Plot Stress Data from xls sheets'];
        op.FileType = 'stressData';
        op.Aggregatable = false;
        op.RawPlotFcn = @Operations.StressImport.plot_stress;
        op.SubmitFcn = @Operations.StressImport.submit_stress;
    ops.add(op);
end

