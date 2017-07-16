%% make_compare_U700_lat_time.m%
% Compare the reduction in RMS error in the U and V fields, for 
% perfect-model experiments assimilating radiosondes and assimilating 
% ERPs
%
%
% Lisa Neef, 7 June 2013
%----------------------------------------------------------------------

clear all; clf;
hostname = 'blizzard';

%% define overall plot settings
clim = [0,30];     % color limits in terms of zonal wind error (m/s)


%% define the experiments we want to compare as structures

% experiment 1
E1              = experiment_structure;
E1.run_name     = 'ERPALL_2009_N80/Exp1';
E1.truth        = 'PMO_ERPs_2009/PMO_ERPs_2009';
E1.copystring   = 'ensemble mean';
E1.variable     = 'U';
E1.level        = 700;
E1.AAM_weighting = 'none';
E1.diagn        = 'RMSE';
E1.day0                 = 149021;
E1.dayf                 = 149080;
E1.exp_name	= 'All ERPs';

% experiment 2
E2              = experiment_structure;
E2.run_name     = 'RADIOSONDE_SYNTHETIC_2009/Exp1';
E2.truth        = 'PMO_RADIOSONDES_2009/PMO_RADIOSONDES_UVT/';
E2.copystring   = 'ensemble mean';
E2.variable     = 'U';
E2.level        = 700;
E2.AAM_weighting = 'none';
E2.diagn        = 'RMSE';
E2.day0                 = 149021;
E2.dayf                 = 149080;
E2.exp_name	= 'Radiosondes';

%% make the plots

figure(1),clf

subplot(2,1,1)
plot_lat_time(E1,hostname)
title(E1.exp_name)
xlim = get(gca,'Xlim');
set(gca,'XTick',[xlim(1):7:xlim(2)])
datetick('x','dd-mmm','keeplimits','keepticks')
set(gca,'Clim',clim)

subplot(2,1,2)
plot_lat_time(E2,hostname)
title(E2.exp_name)
xlim = get(gca,'Xlim');
set(gca,'XTick',[xlim(1):7:xlim(2)])
datetick('x','dd-mmm','keeplimits','keepticks')
set(gca,'Clim',clim)


%% export this plot

  pw = 10;
  ph = 10;

  % paper and export settings
  % when exporting with export_fig, the following two commands
  % determine the aspect ratio of our figure, as well as the relative
  % font size (larger paper --> smaller font)
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  fig_name = 'compare_U700_lat_time.png';
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)

