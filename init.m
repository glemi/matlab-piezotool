function init
    set(groot, 'DefaultAxesNextPlot', 'add');
    set(groot, 'DefaultAxesBox', 'on');
    set(groot, 'DefaultLegendInterpreter', 'latex');
    set(groot, 'DefaultLineMarkerSize', 6);
    set(groot, 'DefaultLineLineWidth', 1.2);
    set(groot, 'DefaultErrorBarLineWidth', 1.2);
    set(groot, 'DefaultErrorBarMarkerSize', 16);
    
    warning off MATLAB:table:RowsAddedNewVars;

    addpath '../lib/GUI Layout Toolbox 2.3.1/layout';
    addpath '../lib/For-Each';
    addpath '../lib/inputsdlg_v2.1.2';
    addpath '../lib/uicomponent';
    addpath '../lib/mmx';
    addpath '../universal';
    
    addpath ..\coupling\fitting;
    addpath ..\coupling\algorithm;
    addpath ..\coupling\analysis;
    addpath ..\coupling\auxilary;
    addpath ..\coupling\model;
    addpath ..\coupling\plotting;
    
    format compact;
end

