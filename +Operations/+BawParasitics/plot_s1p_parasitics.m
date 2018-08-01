function plot_s1p_parasitics(info, data)
    f = data.f;
    Z = squeeze(data.z(1,1,:));

    zr = deripple(f, real(Z));
    zi = deripple(f, imag(Z));
    Zc = complex(zr, zi);
    
    % optional variables: R0 Rp Rc Lc X1 X2 Y1 Y2    
    variables = {'td' 'Lc' 'Rc'}; 
    fit = bvdextfit_v2(f, Zc, variables);
    
    Zf = fit.Zfit;    
    
    fit.Lc = fit.Lc;
    Rc = fit.Rc;
    Rp = fit.Rp;
    R0 = fit.R0;
    
    ZC0 = 1./(2i*pi*f*fit.C0);
    ZCm = 1./(2i*pi*f*fit.Cm);
    ZLm =     2i*pi*f*fit.Lm;
    ZLc =     2i*pi*f*fit.Lc;
    ZCs = 1./(2i*pi*f*fit.Cs);
    Zx1  =    (fit.X1*2*pi*f);
    Zx2  =    (fit.X2*2*pi*f).^2;
    Zy1  =-1./(fit.Y1*2*pi*f);
    Zy2  =-1./(fit.Y1*2*pi*f).^2;
    Zm  = ZCm + ZLm + fit.Rm;
    
    function z1 = deembed(z, variable)
        switch variable
            case 'Rc',  z1 = z - Rc;
            case 'Lc',  z1 = z - ZLc;
            case 'Cs',  z1 = z - ZCs;
            case 'Rp',  z1 = Rp*z./(Rp - z);
            case 'X1',   z1 = z - Zx1;
            case 'X2',   z1 = z - Zx2;
            case 'Y1',   z1 = z - Zy1;
            case 'Y2',   z1 = z - Zy2;
            case 'R0'
                z1 = 1./(1./z - 1./Zm) - ZC0 - R0;
                z1 = 1./(1./(z1 + ZC0) + 1./Zm);
            case 'td',  z1 = z; % no way to extract this;
        end
    end

    fig parasitics:C0; clf;
    rawdataplot(f, Z.*f);
    rawdataplot(f, Zc.*f);
    rawdataplot(f, Zf.*f);
    subplot(2,2,1);
    label([0.6 0.85], sprintf('$C_0 = %.2f$\\,pF', fit.C0*1e12));
    label([0.6 0.75], sprintf('$\\tan(\\delta) = %.2f\\%%$', fit.td*100));
    
    n = length(variables);
    for k = 1:n
        var = variables{k};
        Z  = deembed(Z,  var);
        Zc = deembed(Zc, var);
        Zf = deembed(Zf, var);
        
        fig(['parasitics:' var]); clf;
        rawdataplot(f, Z.*f);
        rawdataplot(f, Zc.*f);
        rawdataplot(f, Zf.*f);
        makelabel(fit, var);
    end
    
    fig('parasitics:final'); clf;
    rawdataplot(f, Z.*f);
    rawdataplot(f, Zc.*f);
    rawdataplot(f, Zf.*f);

    fig('parasitics:testing'); clf;
    rawdataplot(f, Z.*f);
    rawdataplot(f, (Z -0.2 + 1./f.^2*10e18).*f);
end

function makelabel(fit, variable)
    subplot(2,2,1); 
    
     switch variable
        case 'Rc'
            label([0.1 0.85], sprintf('$R_c = %.2f\\,\\Omega$', fit.Rc));
        case 'Lc'
            label([0.1 0.85], sprintf('$L_c = %.2f\\,nH$', fit.Lc*1e9));
        case 'Cs'
            label([0.1 0.85], sprintf('$C_s = %.2f\\,nF$', fit.Cs*1e9));
        case 'Rp'
            label([0.1 0.85], sprintf('$R_p = %.0f\\,\\rm M\\Omega$', fit.Rp/1e6));
        case 'U'
            label([0.1 0.85], sprintf('$U = %.2f\\,p$', fit.U*1e12));
        case 'R0'
            label([0.1 0.85], sprintf('$R_0 = %.2f\\,\\Omega$', fit.R0));
         otherwise
            valuestr = uprefix(fit.(variable),'', 'latex', 'escape');
            label([0.1 0.85], sprintf('$%s = \\rm %s\\,$', variable, valuestr));
     end  
end

