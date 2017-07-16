function axout = plot_diagn_in_time(E,hostname)
% Make a plot of a given state-space diagnostic, averaged globally, in time.
%
% Lisa Neef, 14 June 2013
%
% INPUTS:
%  E: structure definind the experiment
%  hostname: currently only supporting 'blizzard'
%  col: the color that we want this curve to be.
%
% MODS:
%  15 Aug 2013: export the plot as eps instead of png
%   5 Feb 2014: make it possible to plot different experiments in the same plot,
%	with externally-specified colors and linestyles
%----------------------------------------------------------------------

testplot = 0;


% temporary inputs if not running as a function:
%clear all;
%clc;
%hostname = 'blizzard';
%Eall = load_experiments;
%E = Eall([1,3]);
%testplot = 1;
%nE = length(E);
%col = jet(nE);
%for ii = 1:nE
%  E(ii).color = col(ii,:);
%  E(ii).dayf = E(ii).day0+31+27;
%end
%E(1).linestyle = '-';
%E(1).name = E(1).exp_name;
%E(2).linestyle = '--';
%E(2).name = E(2).exp_name;
%--------------temp inputs--------------------------------

%% initialize arrays 
ref_day = datenum(1601,1,1,0,0,0);
t0 = E(1).day0+ref_day;
tf = E(1).dayf+ref_day;

%% if the input structure has different variables in it, make a note -- then the axis labels wont be right
nE = length(E);
vv = E(1).variable;
if nE > 1
  for ii = 2:nE
    vv2 = E(ii).variable;
    if ~strcmp(vv,vv2)
      disp('note that different variables are being plotted together here -- need to change the axis labels.')
    end
  end
end


%% cycle over the desired experiments and plot

h = zeros(1,nE);

for iE = 1:nE

  %% retrieve the data for this run
  [D,T] = get_diagn_in_time(E(iE),hostname);

  h(iE) = plot(T,D,'Color',E(iE).color,'LineWidth',2,'LineStyle',E(iE).linestyle);
  hold on
  datetick('x','dd-mmm','keeplimits','keepticks')

  % ylabel is determined by the first thing plotted
  if iE == 1
    switch E(iE).variable
      case {'U','V'}
        ylabel('m/s')
      case {'PS'}
        ylabel('Pa')
    end
  end

end

%% add a legend
legend(h,E.exp_name,'Orientation','Vertical','Location','NorthWest')

%% -- export if desired -----
if testplot
  ph = 5;
  pw = 7;

  fig_name = 'test_global.eps';
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)

end


