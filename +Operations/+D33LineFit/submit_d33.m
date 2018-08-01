function submit_d33(info, result, repo)

    if length(unique({info.WaferID})) > 1
        error('All sample data must be from the same wafer');
    end
    
    pos = mean(unique([info.Position]));
    
    %rootdir = 'C:\Users\Nyffeler\switchdrive\AlScN_project\Analysis\Matlab\Repo';
    wafer = info(1).WaferID; 
    node = repo.getNode(wafer, 'd33');        
    
    node.add('d33', pos, result.d33, result.d33_error.tot);  

    node.write();
end

% result.d33_med = d33_med;
% result.d33_std = d33_std;
% result.dEl_meas = dEl;
% 
% result.d33 = d33_ref;
% result.d33_error.dEl = err_dEl;
% result.d33_error.std = err_std;
% result.d33_error.iqr = err_iqr;
% result.d33_error.fit = err_fit;
% result.d33_error.tot = err_fit + err_dEl + err_iqr;
% 
% result.poly_coeffs = p;
% result.poly_err = S;
% 
% result.dEl_ref = dEl_ref;
% result.dEl_err = dEl_delta;

