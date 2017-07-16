%% make_compare_10dayerror_singleplots.m
%
% Make plots of the true error at 10 days in the main assimilation experiments.
% This particular version of the code makes separate figures for the different plots.
%
% Lisa Neef,  1 July 2013
%
%----------------------------------------------------------------------

clc;
clear all;

%% load the experiments:
[E1,E2,E3,E4,E5,E6] = load_experiments;
E = [E1,E2,E3,E4,E5,E6];
nX = length(E);

%% some figure settings 
ph = 7;
pw = 10;
fs = 1.5;

%% loop over the experiments and make the plot

for iX = 1:nX
  E(iX).dayf = E(iX).start+10;
  figure(iX),clf
  plot_lat_lon_daily(E(iX),'blizzard')
  title([E(iX).exp_name, ': 10-day Error U(300hPa)'])
  set(gca,'Clim',[-30,30])
  colorbar

  % export it!
  name = strsplit(E(iX).run_name,'/');
  fig_name = char(['10_day_error_',char(name(1)),'.png']);
  disp(fig_name)
  exportfig(iX,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
end

