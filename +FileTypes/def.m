function types = def
    
    types = FileTypes.Store;
    
    type = FileTypes.DataFile;    
        type.ID = 'E31Data';
        type.AltID = 'e31';
        type.Name = 'e31 Data';
        type.Description = 'aixAcct e31 File';
        type.Extension = '.dat';
        type.RegexFilter = '.+\.dat$';
        type.WildcardFilter = '*.dat';
        type.ReadFcn = @FileTypes.read_aix;
        type.IdentFcn = @FileTypes.ident_std;
    types.add(type);
    
    type = FileTypes.DataFile;    
        type.ID = 'CpDData';
        type.AltID = 'cpd';
        type.Name = 'CpD Data';
        type.Description = 'Impedance Data (CpD)';
        type.Extension = '.cpd';
        type.RegexFilter = '.+\.cpd$';
        type.WildcardFilter = '*.cpd';
        type.ReadFcn = @FileTypes.read_cpd;
        type.IdentFcn = @FileTypes.ident_std;
    types.add(type);
    
    type = FileTypes.DataFile;    
        type.ID = 's1pData';
        type.AltID = 's1p';
        type.Name = 's1p Data';
        type.Description = 'VNA Measurement (s1p)';
        type.Extension = '.s1p';
        type.RegexFilter = '.+\.s1p$';
        type.WildcardFilter = '*.s1p';
        type.ReadFcn = @FileTypes.read_s1p;
        type.IdentFcn = @FileTypes.ident_std;
    types.add(type);
    
    type = FileTypes.DataFile;    
        type.ID = 'XrdData';
        type.AltID = 'xrd';
        type.Name = 'XRD Data';
        type.Description = 'XRD scan data (dql)';
        type.Extension = '.dql';
        type.RegexFilter = '.+\.dql$';
        type.WildcardFilter = '*.dql';
        type.ReadFcn = @FileTypes.read_dql;
        type.IdentFcn = @FileTypes.ident_std;
    types.add(type);
    
    type = FileTypes.DataFile;    
        type.ID = 'd33Data';
        type.AltID = 'd33';
        type.Name = 'd33 Data';
        type.Description = 'Interferometer d33 scan';
        type.Extension = '.sca';
        type.RegexFilter = '.+\.sca$';
        type.WildcardFilter = '*.sca';
        type.ReadFcn = @FileTypes.read_sca;
        type.IdentFcn = @FileTypes.ident_std;
    types.add(type);
    
    type = FileTypes.DataFile;    
        type.ID = 'stressData';
        type.AltID = 'stress';
        type.Name = 'Stress Data';
        type.Description = 'Stress Data';
        type.Extension = '.stress.xlsx';
        type.RegexFilter = '.+\.stress\.xlsx$';
        type.WildcardFilter = '*.stress.xlsx';
        type.ReadFcn = @FileTypes.read_stress;
        type.IdentFcn = @FileTypes.ident_wdata;
    types.add(type);
    
end
