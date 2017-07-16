%% make_ERPDA_summary2.m
%  Yet another figure summarizing what happens when we assimilate
%  Earth rotation measurements
% 
% 3 PLOTS:
% 1. fit to one of the ERPs as a function of time -- showing how the assimilation progresses
% 2. latitude-time progression of error reduction in surface pressure -- shows that error is reduced here and there
% 3. ensemble NAO index in time -- shows that on the whole, the improvement sucks
%
% 30 Oct 2013
%-------------------------------------------

clear all;
clc;


%% experiment info

EE = load_experiments;
E = EE(3);
E.variable = 'PS';
E.diff = 1;
E.dayf = E.day0+29;
EnoDA = EE(1);

hostname = 'blizzard';


%% initialize figure
figure(1),clf
ph = 12;
pw = 10;
fs = 1.2;
fig_name = 'erp_da_summary.eps';
h = zeros(1,3);

ref_day = datenum(1601,1,1,0,0,0);
t0 = E.day0+ref_day;
tf = E.dayf+ref_day;
xlim = [t0,tf];
xticks = t0:5:tf;

%% (1) fit to observations plot

obs_string = 'ERP_PM1';
include_legend = 1;

h(1) = subplot(3,1,1);
plot_ERPs_filter(E,obs_string,include_legend,hostname)
title('(A) Fit to Observed Polar Motion Parameter')
set(gca,'Xlim',xlim)
set(gca,'XTick',xticks)
set(gca,'xgrid','on','ygrid','off')
datetick('x','dd-mmm','keeplimits','keepticks')

%% (2) error reduction in surface pressure over latitude and time

h(2) = subplot(3,1,2);
plot_lat_time_diff(E, EnoDA,hostname)
title('(B) Error Relative to No Assimilation (Surface Pressure)')
set(gca,'Xlim',xlim)
set(gca,'XTick',xticks)
set(gca,'xgrid','on','ygrid','off')
datetick('x','dd-mmm','keeplimits','keepticks')
hbar = colorbar('Location','SouthOutside');
xlabel(hbar,'Pa')

%% (3) NAO index in the entire ensemble in time

h(3) = subplot(3,1,3);

E.diang = 'Posterior';
plot_ensemble_in_time(E,hostname,'NAO')
title('(C) NAO Index')
set(gca,'Xlim',xlim)
set(gca,'XTick',xticks)
set(gca,'xgrid','on','ygrid','off')
datetick('x','dd-mmm','keeplimits','keepticks')


%% make the axes non-shitty

nX = 3;

x0 = 0.1;
y0 = 0.90;
dx = 0.11;
dy = 0.12;
dbar = 0.05;
width = (1-x0-dx);
height = (y0-nX*dy-dbar)/nX;

ii = 1;
for iX = 1:nX
    x = x0;
    y = y0-iX*(height+dy);
    set(h(ii),'Position',[x y width height])
    ii = ii+1;
end

% also change the position of the colorbar
pbar = get(hbar,'Position');
set(hbar,'Position',[0.1,0.3,width,.01])

%% export this figure
set(gcf, 'renderer', 'painters');
disp(['creating figure ',fig_name])
set(gcf,'units','inches')
pos = get(gcf,'Position');
%set(gcf, 'Position',[0.1,0.1,pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

