% New User Script: Enter Title on next line
% #Title: "Stress Plot" 
% Description goes here
function stress_plot(repo, wafers)
    
    fig 'stress:eins';clf;
    
    n = length(wafers);
    for k = 1:n
        node = repo.getNode(wafers{k}, 'stress');
        T = node.get('stress_avg');
        pos = node.get('Position');
        
        h = plot(pos, T);
        h.DisplayName = wafers{k};
        
    end
    legend show; legend location best;
    
end