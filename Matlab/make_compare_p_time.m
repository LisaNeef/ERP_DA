function make_compare_p_time(E,hostname,plot_name)
% Compare different DART diagnostics or different experiments, for
% perfect-model experiments assimilating radiosondes and assimilating 
% ERPs
%
%
% Lisa Neef, 20 June 2013
%
% MODS:
%  24 June 2013: make the initialization of experiments more compact
%	using load_experiments.m
% 15 Jul 2013: make inputs more flexible
% 15 Jul 2013: make an eps file rather than png -- it looks better
% 26 Jul 2013: mods to accomidate plotting the error reduction relative to no DA, plus
%              accomodating the new variable definitions in diagnostic_quantities.m
% 17 Aug 2013: fixed an error in the inputs to the plot___diff code when ploting ER -- 
%		the No-DA run shoulld be the second argument!
% 10 Sep 2013: simplify the input to be only a structure that holds all the experiments
% we want to compare, and the desired time range, etc.
% 10 Sep 2013: the iff loop for pplotting a difference is now entered by having E.diff 
%	set to some experiment name - then any diff between two experiments is possible
%	(as opposed to setting not E.diagn = 'ER', which is super misleading)
%  7 Oct 2013: make more flexible for comparing different things
%----------------------------------------------------------------------

%---inputs if not running as a function
%clear all;
%clc;
%EE = load_experiments;
%E = EE(3);
%E.diff = 'none';
%E.copystring = 'ensemble spread';
%E.diagn = 'Posterior';
%hostname = 'blizzard';
%plot_name = 'baseline_spread_U';
%E.exp_name = 'Zonal Wind Ensemble Spread, ERPALL';
%-------------




%% define overall plot settings
clim = [0,30];     % color limits in terms of zonal wind error (m/s)

nX = length(E);
E_all = load_experiments;


%% make the plots

figure(1),clf
h = zeros(1,nX);
clim = zeros(nX,2);

for iX = 1:nX
  h(iX) = subplot(nX,1,iX);
  if strcmp(E(iX).diff,'none')
    disp('plotting the following experiment:')
    E(iX)
    if strcmp(E(iX).diagn,'Innov')
      plot_height_time_pcolor(E(iX),hostname)
    else
      plot_height_time(E(iX),hostname)
    end
  else
    disp('plotting ER for the following experiment:')
    E(iX)
    E_all = load_experiments;
    E_diff = E_all(E(iX).diff);
    E_diff.day0 = E(iX).day0;
    E_diff.dayf = E(iX).dayf;
    E_diff.diagn = E(iX).diagn;
    E_diff.variable = E(iX).variable;
    E_diff.level = E(iX).level;
    plot_height_time_diff(E(iX),E_diff,hostname)
  end

  title(E(iX).exp_name)
  xlim = get(gca,'Xlim');
  set(gca,'XTick',[xlim(1):10:xlim(2)])
  set(gca,'YTick',[1 10 100 1000])

  datetick('x','dd-mmm','keeplimits','keepticks')
  clim(iX,:) = get(gca,'Clim');

  % even out the color limits so that white is zero
  cc = get(gca,'Clim');
  set(gca,'Clim',max(abs(cc))*[-1,1])

end



%% go through the axes and make them not suck
x0 = 0.15;
y0 = 0.95;
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

set(gcf, 'renderer', 'painters');
fig_name = ['compare_',plot_name,'_p_time.eps'];
disp(['creating figure ',fig_name])

ph = 3*nX;
pw = 8;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

