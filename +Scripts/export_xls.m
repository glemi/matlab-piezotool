% New User Script: Enter Title on next line
% #Title: "export_xls" 
% Description goes here
function export_xls(repo, wafers)

    xlsfile = saveDlg();

    if ~isempty(xlsfile)
        kt2tbl = make_statstable(repo, wafers, 'coupling', 'kt2');
        e33tbl = make_statstable(repo, wafers, 'coupling', 'e33');
        c33tbl = make_statstable(repo, wafers, 'coupling', 'c33E');
        epstbl = make_statstable(repo, wafers, 'coupling', 'epsf');
        e31tbl = make_statstable(repo, wafers, 'e31', 'e31');
        dktbl  = make_statstable(repo, wafers, 'diel', 'eps10k');
        Dtbl   = make_statstable(repo, wafers, 'diel', 'D10k');
    end
    
    args = {'FileType', 'spreadsheet', 'WriteVariableNames', true, ...
        'WriteRowNames', true};
    
    wnode = repo.getNode(wafers{1});
    wtbl = wnode.DataTable(wafers,:);
    
    writetable(wtbl,   xlsfile, 'Sheet', 'wafers', args{:});
    writetable(kt2tbl, xlsfile, 'Sheet', 'coupling.kt2',  args{:});
    writetable(e33tbl, xlsfile, 'Sheet', 'coupling.e33',  args{:});
    writetable(c33tbl, xlsfile, 'Sheet', 'coupling.c33E', args{:});
    writetable(epstbl, xlsfile, 'Sheet', 'coupling.epsf', args{:});
    writetable(e31tbl, xlsfile, 'Sheet', 'aixacct.e31',   args{:});
    writetable(dktbl,  xlsfile, 'Sheet', 'aixacct.eps10k', args{:});
    writetable(Dtbl,   xlsfile, 'Sheet', 'aixacct.loss', args{:});
    
    Auxilary.sysopen(xlsfile);
end

function tbl = make_statstable(repo, wafers, nodename, varname)
    tbl = table;
    
    n = length(wafers);
    for k = 1:n
        row = make_tablerow(repo, nodename, varname, wafers{k});
		tbl(k,:) = row;
    end
    
    tbl.Properties.VariableNames = row.Properties.VariableNames;
    tbl.Properties.RowNames = wafers;    
end

function tbl = make_tablerow(repo, node, varname, wafer)
    vnode = repo.getNode(wafer, node);
    snode = repo.getNode(wafer, 'stress');

    tbl = table; tbl{1,1:8} = NaN(1,8);
    statnames = {'max' 'min' 'mean' 'median' 'T0' 'R15' 'R45' 'R80'};
    varnames = strcat([varname '_'], statnames);
    tbl.Properties.VariableNames = varnames;
    if isempty(vnode.DataTable) 
        return;
    end
    
    var = vnode.get(varname);
    pos = vnode.get('Position');
    T = snode.interp('stress_avg', pos);
    
    varmax = max(hampel(var));
    varmin = min(hampel(var));
    varavg = mean(hampel(var));
    varmdn = median(var);
    
    varT0  = getValueNearX(T, var, 0, 100);
    varr15 = getValueNearX(pos, var, 15, 10);
    varr45 = getValueNearX(pos, var, 45, 10);
    varr80 = getValueNearX(pos, var, 80, 10);
    
    tbl{1,:} = [varmax varmin varavg varmdn varT0 varr15 varr45 varr80];
end

function y0 = getValueNearX(x, y, x0, tol)
    i = abs(x-x0) < tol;
    y0 = median(y(i));
    
    if any(abs(x-x0) < 2*tol)
        [linfit, gof] = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
        if gof.rsquare > 0.9
            y0 = feval(linfit, x0);
        end
    end
end

function outfile = saveDlg
    app = DataApp.instance;
    outdir = app.OutputDir;
    title = 'Export Data to xls Spreadsheet';
    default = fullfile(outdir, 'export.xlsx');
    
    [file, path] = uiputfile('*.xlsx', title, default);
    outfile = fullfile(path, file);
end
