%function make_compare_ERPs(E,hostname,ERP,plot_name)
%% 
% Compare the fit to Earth rotation parameters in the different DARt experiments
%
% Lisa Neef, 18 June 2013
%
%
% MODS:
%  10 Sep 2013: instead of a list of experiments as the input, have the experiments
%    themselves in a large structure called E
%  10 Sep 2013: remove day0 and day0f as external inputs -- they are contained in the 
%     experiment structures that we are plotting over
%----------------------------------------------------------------------

%% temp inputs----------
hostname = 'blizzard';
EE = load_experiments;
%E = EE([1,2,8,13]);
E = EE([1,3])
plot_name = 'ERPDA_vs_NODA';
ERP = {'ERP_LOD';'ERP_PM1';'ERP_PM2'};

nX = length(E);
for iX = 1:nX
	E(iX).day0 = 149019;
	E(iX).dayf = E(iX).day0+20;
end

%% define the experiments we want to compare as structures
nX = length(E);
nERP = length(ERP);


%% calculate what the time limits should be
ref_day = datenum(1601,1,1,0,0,0);
t0 = E(1).day0+ref_day;
tf = E(1).dayf+ref_day;

%% cycle over ERPs and experiments

%figH = figure('visible','off') ;
figH = figure(1),clf
h = zeros(1,nX*nERP);
k = 1;

for iERP = 1:nERP
  for iX = 1:nX

      include_legend = 0;

    h(k) = subplot(nERP,nX,k);
    disp(['Plotting ERPs for ',E(iX).exp_name])
    plot_ERPs_filter(E(iX),char(ERP(iERP)),include_legend,hostname)
    k = k+1;

    % for first row only
    if iERP == 1
      title(E(iX).exp_name)
    end

    % set the time limits
    set(gca,'XLim',[t0,tf])

    % set the yaxis to whatever it is in the first case (usually NoDA)
    if iX == 1
      yy = get(gca,'YLim'); 
      yticks = get(gca,'YTick');
    end
    %set(gca,'Ylim',yy)
    %set(gca,'YTick',yticks(2:length(yticks)-1))

    % fix xticks
    xlim = get(gca,'Xlim');
    set(gca,'XTick',xlim(1):7:xlim(2))
    datetick('x','dd-mmm','keeplimits','keepticks')

    % annotate
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
    dxlim = xlim(2)-xlim(1);
    dylim = ylim(2)-ylim(1);
    parts = strsplit(char(ERP(iERP)),'_');
    text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,parts(2))

  end

end



%% go through the axes and make them not suck


x0 = 0.1;
y0 = 0.90;
dx = 0.09;
dy = 0.05;
width = (1-x0-nX*dx)/nX;
height = (y0-nERP*dy)/nERP;

kk = 1;
for iERP = 1:nERP
  for iX = 1:nX

    % sizing
    x = x0+(iX-1)*(width+dx);
    y = y0-iERP*height-(iERP-1)*dy;
    set(h(kk),'Position',[x y width height])


    kk = kk+1;
  end
end


%% export this plot

% when exporting with export_fig, the following two commands
% determine the aspect ratio of our figure, as well as the relative
% font size (larger paper --> smaller font)

set(gcf, 'renderer', 'painters');
fig_name = ['compare_ERPs',plot_name,'.eps'];

ph = 4*nERP;
pw = 4*nX;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)
disp(['exporting figure ',fig_name])
