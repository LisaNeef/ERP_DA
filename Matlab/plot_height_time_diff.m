function plot_height_time_diff(E1, E2, hostname)
%
% Make a plot of a variable as a function of height and time.
% This version plots the difference between two experiments where
% DIFF = E1-E2
% this means that if we look at RMSE relative to NoDA, we want to have
% E1 = experiment
% E2 = No DA
% Right now equipped for variables U and PS, and AAM excitation functions
% X1, X2, and X3, using DART-CAM output.
%
%
% Lisa Neef, 26 Jul 2013
%
%  INPUTS:
%  E: a structure holding all the experiment details and what we want to show.
%   these are the field names
%    run_name:
%    truth:
%    copystring:
%    variable:
%    level:
%    AAM_weighting:
%    diagn:
%    day0:
%    dayf:
%
%  hostname: presently only supporting 'blizzard'

% Mods:
%  14 Aug 2013: fixing a mistake in the part where we select the temporal overlap of the two datasets
%  19 Aug 2012: changing the colormap to an NCL colormap, which is waaaay clearer.
%  20 Aug 2013: use intersect.m to find the overlap between two experiments - now they can be on different temporal girds
%----------------------------------------------------------------

testplot = 0;

% temporary inputs if not running as a function:
%testplot = 1;
%hostname = 'blizzard';
%E_all = load_experiments;
%E1 = E_all(10);
%E2 = E_all(1);
%E1.dayf = 149029;
%E2.dayf = 149029;

%%% other paths, etc.
%
% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end




%% Fetch the data
[VAR1,t1,lev] = get_height_time_DART_CAM(E1,hostname);
[VAR2,t2,lev] = get_height_time_DART_CAM(E2,hostname);

%% these experiments might have different time grids so look at the times they have in common
[tb,i1,i2] = intersect(t1,t2);
VAR1b = VAR1(:,i1);
VAR2b = VAR2(:,i2);


%% Compute the difference
D = VAR1b - VAR2b;

%% Plot settings
ncontours = 11;
cmap = read_ncl_colors('blue_white_orange_red');

% compute X-ticks for the first of each month
[y0,m0,d0] = gregorian_to_date(E1.day0,0);
xtick_monthly = zeros(1,12);
for m = 1:12
   xtick_monthly(m) = datenum(y0,m,1,0,0,0);
end

%% convert t from Gregorian to a number that works for matlab datenum
ref_day = datenum(1601,1,1,0,0,0);
t = tb+ref_day;

% Also get the axis limits as the input start and end dates, in Matlab
% style.
t0 = E1.day0+ref_day;
tf = E1.dayf+ref_day;

%% Plot settings

lev2 = flipud(lev);
[X,Y] = meshgrid(t,lev);

%% Plot!

  contourf(X,Y,D,ncontours,'LineColor','none')
  shading flat
  set(gca,'yscale','log')
  set(gca,'ydir','reverse')
  colormap(cmap)

  ylabel('hPa')

  if E1.cbar
    colorbar('Location','EastOutside')
  end
  
  set(gca,'Xlim',[t0,tf])

  xticks = t0:7:tf;
  set(gca,'XTick',xticks)
  datetick('x','dd-mmm','keeplimits','keepticks')
  hbar = colorbar('Location','EastOutside');
  grid on
  set(gca,'Xlim',[t0,tf])


  % make color limits symmetric
  clim = get(gca,'Clim');
  cc = max(abs(clim));
  set(gca,'Clim',cc*[-1,1]);


  %set(gca,'YScale','log')
  % somehow contourf doesn't like Y to go from large to small, so need to
  % flip the ticklabels manually
  %set(gca,'YTick',[1000 800 700 600 500 400 300 100 50 5 1])


%% export this plot

if testplot 
  
  pw = 10;
  ph = 5;

  pos = get(gcf,'Position')
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  dum1 = strsplit(E1.run_name,'/');
  dum2 = strsplit(E2.run_name,'/');
  fig_name = ['diff_',char(dum1(1)),'_',char(dum2(1)),E1.diagn,'_',E1.variable,num2str(E1.level),'_p_time.eps'];
  disp(['saving figure  ',fig_name])
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)
end
