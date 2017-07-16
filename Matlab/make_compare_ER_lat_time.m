function make_compare_ER_lat_time(exp_list,hostname,variable,level)
%% make_compare_ER_lat_time.m%
% Compare the reduction in RMS error in some quantity, relative to the 
% No-DA case
%
% Lisa Neef, 14 July 2013
%
% MODS:
%----------------------------------------------------------------------

%% define overall plot settings
clim = [0,30];     % color limits in terms of zonal wind error (m/s)

%% define the experiments we want to compare as structures
E_all = load_experiments;
E = E_all(exp_list);
nX = length(E);
E_noDA = E(1);


%% define the variable and level for each experiment
for iX = 1:nX
  E(iX).variable = variable;
  E(iX).level = level;
end

%% make the plots

figure(1),clf

for iX = 1:nX
  subplot(nX,1,iX)
  plot_lat_time_diff(E(iX),E_noDA,hostname)
  title(E(iX).exp_name)
  xlim = get(gca,'Xlim');
  set(gca,'XTick',[xlim(1):14:xlim(2)])
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

  fig_name = ['compare_ER_',variable,num2str(lev),'_lat_time.png'];
  fs = 2;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)

