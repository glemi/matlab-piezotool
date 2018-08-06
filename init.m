function init
    set(groot, 'DefaultAxesNextPlot', 'add');
    set(groot, 'DefaultAxesBox', 'on');
    set(groot, 'DefaultLegendInterpreter', 'latex');
    set(groot, 'DefaultLineMarkerSize', 6);
    set(groot, 'DefaultLineLineWidth', 1.2);
    set(groot, 'DefaultErrorBarLineWidth', 1.2);
    set(groot, 'DefaultErrorBarMarkerSize', 16);
    
    warning off MATLAB:table:RowsAddedNewVars;

    restoredefaultpath;
    
    addpath 'dependencies/universal';
    
    addpath 'dependencies/libraries/GUI Layout Toolbox 2.3.1/layout';
    addpath 'dependencies/libraries/For-Each';
    addpath 'dependencies/libraries/inputsdlg_v2.1.2';
    addpath 'dependencies/libraries/uicomponent';
    addpath 'dependencies/libraries/buttondlg';
    addpath 'dependencies/libraries/mmx';
    
    addpath 'dependencies/coupling/fitting';
    addpath 'dependencies/coupling/algorithm';
    addpath 'dependencies/coupling/analysis';
    addpath 'dependencies/coupling/auxilary';
    addpath 'dependencies/coupling/model';
    addpath 'dependencies/coupling/plotting';
    
    format compact;
end

