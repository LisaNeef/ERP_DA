function make_compare_lat_time(E,hostname,plot_name)
%% make_compare_U300_lat_time.m%
% Compare the reduction in RMS error some variable field for
% perfect-model experiments assimilating radiosondes and assimilating 
% ERPs
%
%
% Lisa Neef, 7 June 2013
%
% MODS:
%  23 June 2013: make the loading of experiment infor more compact
%	using load_experiments.m
%  3 Jul 2013: make it even more compact by loading a single structure E for all experiments.
%	also make this code a function that takes as arguments the experiments we want to comparae.
%	...this lends flexibility to running a lot of diagnostics quickly.
% 15 Jul 2013: make inputs more flexible
% 15 Jul 2013: change the plot export to eps -- it looks better.
% 26 Jul 2013: make diagnostic an input; also make 'ER' a possible diagnostic, i.e the diff from the No-DA case.
% 29 Jul 2013: cosmetic changes and small bug-fixes
% 17 Aug 2013: define how the color axis should look for RMSE plots
% 17 Aug 2013: fix an error in the input to the code that plots the diff betwene 2 runs:
%		for ER, we want No-DA to be the second argument (which is subtracted)
%  7 Oct 2013: simplify the input -- all details are contained in the experiment structure E.
%----------------------------------------------------------------------

%% temp inputs
%clear all;
%clc;
%plot_name = 'test_reverse';
%exp_list = 10;
%hostname = 'blizzard';
%day0 = 149020;
%dayf = 149020+10;
%diagn = 'ER';
%vv = 'U300';



nX = length(E);


%% print to the screen what is being plotted
disp('Plotting following experiments:')
E.exp_name

%% make the plots

figure(1),clf

h = zeros(1,nX);

for iX = 1:nX
  h(iX) = subplot(nX,1,iX);
  if strcmp(E(iX).diff,'none')
    if strcmp(E(iX).diagn,'Innov')
      plot_lat_time_pcolor(E(iX),hostname)
    else
      plot_lat_time(E(iX),hostname)
    end
  else
    E_all = load_experiments;
    E_diff = E_all(E(iX).diff);
    E_diff.day0 = E(iX).day0;
    E_diff.dayf = E(iX).dayf;
    E_diff.diagn = E(iX).diagn;
    E_diff.variable = E(iX).variable;
    E_diff.level = E(iX).level;
    plot_lat_time_diff(E(iX),E_diff,hostname)

  end
 
  title(E(iX).exp_name)
  xlim = get(gca,'Xlim');
  set(gca,'XTick',[xlim(1):14:xlim(2)])
  datetick('x','dd-mmm','keeplimits','keepticks')

  % even out the color axis so that zero corresponds to white
  cc = get(gca,'Clim');
  set(gca,'Clim',max(abs(cc))*[-1,1])
end



%% go through the axes and make them not suck

x0 = 0.1;
y0 = 0.97;
dx = 0.11;
dy = 0.08;
dbar = 0.1;
width = (1-x0-dx);
height = (y0-nX*dy-dbar)/nX;

ii = 1;
for iX = 1:nX
    x = x0;
    y = y0-iX*(height+dy);
    set(h(ii),'Position',[x y width height])
    ii = ii+1;
end


%% export this plot

% better: export as eps and then convert to pdf
set(gcf, 'renderer', 'painters');
% when exporting with export_fig, the following two commands
% determine the aspect ratio of our figure, as well as the relative
% font size (larger paper --> smaller font)

fig_name = ['compare_',plot_name,'_lat_time.eps'];
disp(['Creating figure ',fig_name])

ph = 3*nX;
pw = 8;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

