function make_plots_european_jet
%% make_plots_european_jet.m
% Run several DART output diagnostics in order to see whether ERP assimilation
% can improve the moding of the North Atlantic eddy-driven jet.
%
% Lisa Neef, 27 Jul 2013
%
%--------------------------------------------------------


%% basic settings for all plots
hostname = 'blizzard';
day0 = 149019;
dayf = 149019+31+28;
vv = 'UEUR';


%% load the experiment details
E_all = load_experiments; 
nX = length(E_all);

%% set up the European eddy-driven jet diagnostic
[variable,level,latrange,lonrange] = diagnostic_quantities(vv);
for iX = 1:nX
  E_all(iX).variable = variable;
  E_all(iX).level = level;
  E_all(iX).latrange = latrange;
  E_all(iX).lonrange = lonrange;
end

%% initialize a figure
figure(1),clf


%% the jet in the true state
disp('plotting the true state...')
E = E_all(1);
E.copystring = '';
E.diagn = 'Truth';
subplot(5,1,1)
plot_lat_time(E, hostname)
title('True State')

%% the ensemble mean analysis when we don't assimilate
disp('plotting the No DA analysis...')
E = E_all(1);
E.copystring = 'ensemble mean';
E.diagn = 'Posterior';
subplot(5,1,2)
plot_lat_time(E, hostname)
title('No DA Analysis State')
clim = get(gca,'Clim');

%% the ensemble mean analysis when we assimilate ERPs
disp('plotting the ERP DA analysis...')
E = E_all(3);
E.copystring = 'ensemble mean';
E.diagn = 'Posterior'
subplot(5,1,3)
plot_lat_time(E, hostname)
title('ERP DA Analysis State')
set(gca,'Clim',clim)

%% the spread when we assimilate ERPs
disp('plotting the error reduction when assimilating ERPs...')
E = E_all(3);
E.copystring = 'ensemble spread';
subplot(5,1,4)
plot_lat_time(E, hostname)
title('ERP DA - Ensemble Spread')
set(gca,'Clim',clim)

%% the error reduction relative to No -DA when we assimilated ERPs
disp('plotting the error reduction relative to No DA...')
E = E_all(3);
E_noDA = E_all(1);
E.copystring = 'ensemble mean';
E.diagn = 'RMSE';
E_noDA.copystring = 'ensemble mean';
E_noDA.diagn = 'RMSE';
subplot(5,1,5)
plot_lat_time_diff(E,E_noDA, hostname)
title('ERP DA - Error Reduction ')
cmap = div_red_yellow_blue11;
colormap(cmap);

%% plot export
fig_name = 'compare_european_jet.eps'
nX = 5;
ph = 3*nX;
pw = 8;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)


