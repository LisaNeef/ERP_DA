%% plot_pmo_radiosondes.m
%
%  Make figures showing the horizontal, verical, and temporal distributions of the 
%  radiosonde observations.
%
%  Lisa Neef, 24 April 2013
%  completely changed everything 22 Jul 2013
%
%------------------------------------------

clc;
clear all;

%% main inputs
E_all = load_experiments;
E = E_all(1);
figure(1),clf

%% paths and stuff
datadir = ['/work/scratch/b/b325004/DART_ex/',E.run_name];

RS = 'RADIOSONDE_U_WIND_COMPONENT';

fname         = [datadir,'/postprocess/obs_epoch_001.nc'];
region        = [0 360 -90 90 -Inf Inf];
CopyString    = 'observations';
QCString      = 'Quality Control';
maxgoodQC     = 2;
verbose       = 0;   % > 0 means 'print summary to command window'
twoup         = 1;   % > 0 means 'use same Figure for QC plot'



%% load the data
obs = read_obs_netcdf(fname, RS, region, CopyString, QCString, verbose);



%% make a plot
scatter(obs.lons,obs.lats)
hold on
worldmap;
title('Radiosonde Observation Grid')

%% export this figure
set(gcf, 'renderer', 'painters');
fig_name = 'radiosonde_locations.eps';

ph = 10;
pw = 10;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

