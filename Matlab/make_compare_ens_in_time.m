%function make_compare_ens_time(E,hostname,plot_name)
% The ensemble to its mean and the true state, for 
% different experiments and for 
% a given regsion in state space over which we average.
% 
%
%
% Lisa Neef, 9 oct 2013
%
% MODS:
%----------------------------------------------------------------------

%---inputs if not running as a function
EE = load_experiments;
E = EE([1,2,8,13]);

for iX = 1:length(E)
  E(iX).diagn = 'Posterior';
  E(iX).dayf = E(iX).day0+8;
end
hostname = 'blizzard';
plot_name = 'RSconfigurations_NAO';
special_diagnostic = 'NAO';
%---inputs if not running as a function


%% define overall plot settings
nX = length(E);

%% make the plots

figure(1),clf
h = zeros(1,nX);
clim = zeros(nX,2);

for iX = 1:nX
  h(iX) = subplot(nX,1,iX);
  plot_ensemble_in_time(E(iX),hostname,special_diagnostic)

  title(E(iX).exp_name)
  % slave the x and y limits to thosee of the first plot
  if iX == 1
    xlim = get(gca,'Xlim');
    ylim = get(gca,'Ylim');
  else
    set(gca,'Xlim',xlim)
    set(gca,'Ylim',ylim)
  end
  set(gca,'XTick',[xlim(1):10:xlim(2)])
  datetick('x','dd-mmm','keeplimits','keepticks')

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
fig_name = ['compare_',plot_name,'_ens_in_time.eps'];
disp(['creating figure ',fig_name])

ph = 3*nX;
pw = 8;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

