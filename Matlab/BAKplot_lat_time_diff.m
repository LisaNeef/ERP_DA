%function plot_lat_time_diff(E1, E2,hostname)
%% plot_lat_time.m
%
% Make a plot of the difference between two datasets, in terms of
% a variable as a function of latitude and time.
% Right now equipped for variables U and PS, and AAM excitation functions
% X1, X2, and X3, using either ERA-Interim data or DART-CAM output.
%
%
% Lisa Neef, 111 July 2013
%
% INPUTS:
%  E1, E2: experiment structures - see load_experiments.m
%  hostname: presently only supporting 'blizzard'
%
% MODS:
%  19 Aug 2013: modify the divergent colormap to an NCL colormap
%--------------------------------------------------------------------------------------------------------------

testplot = 0;

% temporary inputs if not running as a function:
clear all; clf;
testplot = 1;
hostname = 'blizzard';
E = load_experiments;
E1 = E(2);
E2 = E(1);  
E1.variable = 'U';
E2.variable = 'U';

%---------------------------------------------------


%% other paths, etc.
%
% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end

%% some built in checks
if ((strcmp(E1.variable,'U') && E1.level == 0) || (strcmp(E1.variable,'V') && E1.level == 0))
  disp('cannot have level 0 with wind field....abort.')
  return
end

if strcmp(E1.diagn, E2.diagn) == 0
  disp('dont have the sane diagnostic set for the two experiments -abort.')
  return
end


%% Fetch the data
[VAR1,t1,lat] = get_lat_time_DART_CAM(E1,hostname);
[VAR2,t2,lat] = get_lat_time_DART_CAM(E2,hostname);


%% these experiments might have different time grids so look at the times they have in common
[t,i1,i2] = intersect(t1,t2);
VAR1b = VAR1(i1);
VAR2b = VAR2(i2);

%% these experiments might not be the same length so only look at the times they have in common
t1 = round(t1);
t2 = round(t2);
tstart = max(t1(1),t2(1));
tend = min(max(t1),max(t2));

start1 = find(t1 >= tstart,1,'first');
start2 = find(t2 >= tstart,1,'first');

stop1 = find(t1 <= tend,1,'last');
stop2 = find(t2 <= tend,1,'last');


%% Compute the difference
D = VAR1(:,start1:stop1) - VAR2(:,start2:stop2);
D = VAR1b - VAR2b;

%% load a color map
cmap = read_ncl_colors('blue_white_orange_red');

%% Plot settings
ncontours = 11;

% compute X-ticks for the first of each month
[y0,m0,d0] = gregorian_to_date(E1.day0,0);
xtick_monthly = zeros(1,12);
for m = 1:12
   xtick_monthly(m) = datenum(y0,m,1,0,0,0);
end


%% convert t from Gregorian to a number that works for matlab datenum
ref_day = datenum(1601,1,1,0,0,0);
t = t2(start2:stop2)+ref_day;

% Also get the axis limits as the input start and end dates, in Matlab
% style.
t0 = E1.day0+ref_day;
tf = E1.dayf+ref_day;

%% Plot settings

[X,Y] = meshgrid(t,lat);


%% Plot!


contourf(X,Y,D,ncontours,'LineColor','none')
colormap(cmap)
  
  xticks = t0:7:tf;
  set(gca,'XTick',xticks)
  datetick('x','dd-mmm','keeplimits','keepticks')
  hbar = colorbar('Location','EastOutside');
  %xlabel('time')
  ylabel('Latitude')
  grid on
  set(gca,'Xlim',[t0,tf])


  % make color limits symmetric
  clim = get(gca,'Clim');
  cc = max(abs(clim));
  set(gca,'Clim',cc*[-1,1]);

  % title
  if testplot
    TT = ['Diff ',E1.diagn,' ',E1.variable,num2str(E1.level),' ',E1.exp_name,'-',E2.exp_name];
    title(TT)
  end

%% export this plot

if testplot 
  
  pw = 10;
  ph = 5;

  % paper and export settings

  set(gcf, 'renderer', 'painters');
  set(gcf, 'Units','inches')
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  dum1 = strsplit(E1.run_name,'/');
  dum2 = strsplit(E2.run_name,'/');
  fig_name = ['diff_',char(dum1(1)),'_',char(dum2(1)),E1.diagn,'_',E1.variable,num2str(E1.level),'_lat_time.eps'];
  disp(['Exporting figure  ',fig_name])
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)
end
