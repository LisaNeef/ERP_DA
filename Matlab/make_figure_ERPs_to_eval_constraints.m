% function make_figure_ERPs_to_eval_constraints(ERP)
%% 
% This makes a figure showing the fit to one of three earth rotation 
% parameters for experiments with different observational constraints.
% The point is to show that ERPs are a good tool for evaluating observational 
% constraints.
%
% INPUTS:
%	ERP: 'ERP_LOD','ERP_PM1',or 'ERP_PM2'
%
% Lisa Neef, 8 Dec 2013
%
%----------------------------------------------------------------------

%% temp inputs----------
hostname = 'blizzard';
ERP = 'ERP_PM2';
%% temp inputs----------

%% load the experiments, set up a structure that holds all the details
EE = load_experiments;

%% some texts for the figure
switch ERP
  case 'ERP_PM1'
    erpname = 'Polar Motion Angle 1';
  case 'ERP_PM2'
    erpname = 'Polar Motion Angle 2';
  case 'ERP_LOD'
    erpname = 'Length-of-day Anomalies';
end
EE(1).exp_name = 'No Data Constraints';
EE(2).exp_name = 'Assim. Wind and Temp';
EE(8).exp_name = 'Assim. Temp';


%% choose which experiments to show
E = EE([1,2,8]);

nX = length(E);
for iX = 1:nX
	E(iX).day0 = 149019;
	E(iX).dayf = E(iX).day0+30;
end

nX = length(E);

%% calculate what the time limits should be
ref_day = datenum(1601,1,1,0,0,0);
t0 = E(1).day0+ref_day;
tf = E(1).dayf+ref_day;


%% cycle over the experiments and plot the truth, ensemble, and ensemble mean

figH = figure(1),clf
set(gcf,'DefaultAxesFontName','Arial')
h = zeros(1,nX);
k = 1;

for iX = 1:nX

    include_legend = 0;

    h(k) = subplot(1,nX,k);
    disp(['Plotting ERPs for ',E(iX).exp_name])
    plot_ERPs_filter(E(iX),ERP,include_legend,hostname)
    k = k+1;

    % add a title
    %if iX == 2
    %  title(['Fit to ',erpname])
    %end

    % set the time limits
    set(gca,'XLim',[t0,tf])

    % set the yaxis to something specific for that ERP
    if iX == 1
      yy = get(gca,'YLim'); 
      yticks = get(gca,'YTick');
    end
    if strcmp(ERP,'ERP_PM2')
      yy = [100,400];
    end
    set(gca,'Ylim',yy)
    set(gca,'YTick',yticks(1:length(yticks)-1))

    % fix xticks
    xlim = get(gca,'Xlim');
    set(gca,'XTick',xlim(1):7:xlim(2))
    datetick('x','dd-mmm','keeplimits','keepticks')

    % annotate with the name of the experiment
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
    dxlim = xlim(2)-xlim(1);
    dylim = ylim(2)-ylim(1);
    text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,E(iX).exp_name)

end



%% go through the axes and make them not suck

pw = 20;
ph = 4.5;
fs = 1.7;
set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])

x0 = 0.1;
y0 = 0.90;
dx = 0.06;
dy = 0.06;
width = (1-x0-nX*dx)/(nX+1);
height = (y0-dy);

kk = 1;
for iX = 1:nX

    x = x0+iX*width+(iX-1)*dx;
    y = y0-height;
    set(h(kk),'Position',[x y width height])

    kk = kk+1;
end


%% export this plot

% when exporting with export_fig, the following two commands
% determine the aspect ratio of our figure, as well as the relative
% font size (larger paper --> smaller font)

set(gcf, 'renderer', 'painters');
fig_name = ['compare_constraints',ERP,'.eps'];

exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)
disp(['exporting figure ',fig_name])



