function plot_lat_lon_daily(E,hostname)
%
% Make a 2-D plot of any diagnostic in DART-CAM, given some date
% Input is an experiment structure, E (these are stored in load_experiments.m)
% The date where the plot is made is E.dayf.
%
% Lisa Neef, 13 Mar 2012.
%
% MODS:
%  19 March 2012: instead of ABSPo-Tr, plot RMSE, where the average is over
%  the time specified
%  28 Jun 2013: overhauling the whole thing to suit my new experiments.
%-------------------------------------------------------------

testplot = 0;

%% temporary inputs
%testplot = 1;
%clc;
%[E1,E2,E3,E4,E5,E6] = load_experiments;
%E = E2;
%hostname = 'blizzard';
%E.dayf = E.start+10;

%% fix copystring if the true state is the diagnostic
if strcmp(E.diagn,'Truth')
    E.copystring = 'true state';
end

%% Fetch the data
[VAR,lat,lon] = get_lat_lon_daily_DART_CAM(E,hostname);

%% if there is a time dimension, average over time (i.e. average of this day)
dum = size(VAR);
if length(dum) == 3
  VAR2 = squeeze(mean(VAR,1));
else
  VAR2 = VAR;
end

%% Plot settings
ncontours = 11;

%% shift the lons over to get it right for the map 
% (lons should go -180 to 180)
if min(lon) <= 0
  dum = find(lon > 180);
  lon2=lon;
  lon2(dum) = -(360 - lon(dum));
  [a,b] = sort(lon2);
  lon = a;
end

cmap1 = jet(ncontours);  % straight colormap
cmap2 = cmap1;
cmap2(round(ncontours/2),:) = ones(1,3);  % colormap with center zero
cmap = cmap2;

% if looking at the spread and not innovation, dont allow for negative values
if strcmp(E.copystring,'ensemble spread') && ~strcmp(E.diagn,'Innov') 
  cmap = seq_yellow_green_blue9;
end

% same goes for if looking at the absolute increment
if strcmp(E.diagn,'RMSE')  
  cmap = seq_yellow_green_blue9;
end



[X,Y] = meshgrid(lon,lat);

%% Plots!

  %ax = axesm('MapProjection','eqdcylin','grid','on',...
  %    'MeridianLabel','on','ParallelLabel','on',...
  %    'PLabelLocation',30,'MLabelLocation',90);
  contourf(X,Y,VAR2(:,b),ncontours,'LineStyle','none');
  hold on
  colormap(cmap)
  c = load('coast');
  plot(c.long,c.lat,'Color','black','LineWidth',1);

  box off
  %axis off
  set(gca,'XTick',[-180:60:180])
  set(gca,'YTick',[-90:30:90])

% adjust color axis and add color bar.
switch E.variable
  case 'U'
      cmax = 50;
    case 'V'
        cmax = 50;
  case 'PS'
      cmax = 1e5;
end
        
% plot labels
ylim = get(gca,'YLim');
xlim = get(gca,'XLim');
dxlim = xlim(2)-xlim(1);
dylim = ylim(2)-ylim(1);

if strcmp(E.diagn,'RMSE')
    textstring = E.diagn;
else
    textstring = [E.diagn,' ',E.copystring];
end



%% plot export if running this code standalone
if testplot
  name = strsplit(E.run_name,'/');
  fig_name = char(['Snapshot_',char(name(1)),'_',E.diagn,'_',num2str(E.dayf)]);
  exportfig(gcf,fig_name,'width',10,'height',7,'format','png','color','cmyk','FontSize',1.5)
end


