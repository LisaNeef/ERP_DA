%% make_compare_U300_lat_time.m%
% Compare the enseble spread in the U and V fields, for 
% perfect-model experiments assimilating radiosondes and assimilating 
% ERPs
%
%
% Lisa Neef, 7 June 2013
%----------------------------------------------------------------------

clear all; clf;
hostname = 'blizzard';

%% define overall plot settings
clim = [-40,40];     % color limits in terms of zonal wind error (m/s)

%% load the main experiments to compare
[E1,E2,E3] = load_experiments;
E = [E3;E2];
nX = length(E);

%% settings to change from the defaults for this plot
for iX = 1:nX
  E(iX).diagn = 'Truth';
  E(iX).copystring= 'true state';
end


%% make the plots

figure(1),clf

for iX = 1:nX
  subplot(nX,1,iX)
  plot_lat_time(E(iX),hostname)
  title(E(iX).exp_name)
  xlim = get(gca,'Xlim');
  set(gca,'XTick',[xlim(1):7:xlim(2)])
  datetick('x','dd-mmm','keeplimits','keepticks')
  set(gca,'Clim',clim)
end


%% export this plot

  pw = 10;
  ph = 10;

  % paper and export settings
  % when exporting with export_fig, the following two commands
  % determine the aspect ratio of our figure, as well as the relative
  % font size (larger paper --> smaller font)
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  fig_name = 'compare_U300truth_lat_time.png';
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)

