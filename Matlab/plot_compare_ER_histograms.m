%% plot_compare_ER_histograms.m
%
% Make a plot comparing histograms of error reduction for a given set of ERP runs.
% 
% Lisa Neef, 1 Aug 2012
%------------------------------------------------------------------

clc;
clear all;


% select machine.
hostname = 'blizzard';

% select the plot type

%plot_type = 1;     % compare assimilation variables
%plot_type = 2;     % oops...currently an empty slot
plot_type = 3;     % compare some inflation settings
%plot_type = 4;      % compare Gaspari-Cohn localization radii


% settings for each plot type

switch plot_type
  case 1
    RR = {'ERP1_2001_N64_UVPS';'ERP2_2001_N64_UVPS_V2';'ERP3_2001_N64_UVPS'};
    %run_labels = {'\chi_1 obs.';'\chi_2 obs.';'\chi_3 obs.'};
    run_labels = {'Observing p_1';'Observing p_2';'Observing \Delta LOD'};
    %VV = {'U','V','PS'};
    VV = {'U'};
    LL = [300,300,0];
    GD = 146097:1:146153;
    suffix = '_DAvar';
  case 3
    R1 = 'ERP2_2001_N64_UVPS_V2';
    R2 = 'ERP2_2001_N64_UVPS_obsinfl_adap_sd0p1';
    R3 = 'ERP2_2001_N64_UVPS_obsinfl_adap_sd0p5';
    RR = {R1,R2,R3};
    run_labels = {'BASELINE','INFL 1','INFL 2'};
    VV = {'U','V','PS'};
    LL = [300,300,0];
    GD = 146097:1:146153;
    suffix = '_infl';
  case 4
    R1 = 'ERP2_2001_N64_UVPS_V2';
    R2 = 'ERP2_2001_N64_GC0p32';
    R3 = 'ERP2_2001_N64_GC0p46';
    R4 = 'ERP2_2001_N64_GC0p58';
    R5 = 'ERP2_2001_N64_GC0p68';
    RR = {R1,R2,R3,R4,R5};
    run_labels = {'BASELINE','\theta = 0.32','\theta = 0.46','\theta = 0.58','\theta = 0.68'};
    VV = {'U','V','PS'};
    LL = [300,300,0];
    GD = 146097:1:146153;
    suffix = '_tobs';

end

nruns = length(RR);
nvar = length(VV);
fig_handles = zeros(1,nvar);

% plot settings and figure initialization

col = hsv(nruns);
pw = 16;
ph= 12;
fs = 25;
LW = 3;
prefix = 'compare_ER_histogram_';

% cycle over the given runs, retrieve the histograms, and plot them

for ivar = 1:nvar

  v = char(VV(ivar));
  l = LL(ivar);
  fig_name = [prefix,'_',v,num2str(l),suffix];

  % initialize the figure
  fig_handles(ivar) = figure('visible','off') ;
  maxx = zeros(1,nruns);
  minx = zeros(1,nruns);
  ax_handles = zeros(1,nruns);

  % add a line (shading?) denoting the zero
  plot([0,0],[0,1],'k-');
  hold on

  % cycle over the runs to show in this figure
  for irun = 1:nruns 
    r = char(RR(irun));
    [h,x] = get_ER_global_histogram(r,v,l,GD,hostname);

    % collect the maxima of each case
    maxx(irun) = max(x);
    minx(irun) = min(x);
    maxh(irun) = max(h./sum(h));

    ax_handles(irun) = stairs(x,h./sum(h),'Color',col(irun,:));

    % give each plot a unique color
    %set(ax_handles(irun),'facecolor',col(irun,:))

  end


  % adjust the axis 
  axis([min(minx),max(maxx),0,max(maxh)]);

  % add a title and labels
  title([v,num2str(l),': Global Mean Error Relative to No Assimilation']);
  switch v
    case 'PS'
      units = '(hPa)';
    case {'U','V'}
      units = '(m/s)';
  end
  xlabel(['Relative Error ',units]);
  ylabel('Sample Fraction');

  % add a legend
  legend(ax_handles,run_labels,0)
  legend('boxoff')

  % export the figure and close it
  exportfig(fig_handles(ivar),fig_name,'width',pw,'height',ph,'fontmode','fixed', 'fontsize',fs,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');

  close(fig_handles(ivar));

end 



