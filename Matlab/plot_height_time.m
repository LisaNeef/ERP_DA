%function plot_height_time(E, hostname, pcol)
%
% Make a plot of a variable as a function of height and time.
% Right now equipped for variables U and PS, and AAM excitation functions
% X1, X2, and X3, using DART-CAM output.
%
%
% Lisa Neef, 20 June 2013
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
%  pcol: set to 1 to make a pcolor plot, zero otherwise 

% Mods:
%  20 Aug 2013: improving color map for innovation plots
%  23 Sep 2013: make the x-axis dates rather than numbers
%  25 Sep 2013: takeout the call to the file list -- it's no longer needed
%  17 Oct 2013: make the pcolor plot an option in this code, rather than a separate code
%----------------------------------------------------------------

testplot = 0;

% temporary inputs if not running as a function:
clear all; clf;
clc;
hostname = 'blizzard';
testplot 	= 1;
E_all = load_experiments;
E = E_all(3);
E.diagn = 'Posterior';
E.copystring = 'ensemble spread';
E.diagn = 'Innov';
E.copystring = 'ensemble mean';
pcol = 1;
E.day0 = 149020+20;
E.dayf = 149020+30;

%%% other paths, etc.
%
% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end


if strcmp(E.diagn,'Truth')
  copystring = 'true state';
end
  


%% Fetch the data
[VAR,t,lev] = get_height_time_DART_CAM(E,hostname);


%% Plot settings
ncontours = 10;

% in most cases, we want a divergent colormap
  cmap = read_ncl_colors('blue_white_orange_red');


% if looking at the spread and not innovation, need a progressive colormap
if strcmp(E.copystring,'ensemble spread') && ~strcmp(E.diagn,'Innov') 
  cmap = seq_yellow_green_blue9;
end

% same goes for if looking at the rms error 
if strcmp(E.diagn,'RMSE')  
  cmap = seq_yellow_green_blue9;
end


% compute X-ticks for the first of each month
[y0,m0,d0] = gregorian_to_date(E.day0,0);
xtick_monthly = zeros(1,12);
for m = 1:12
   xtick_monthly(m) = datenum(y0,m,1,0,0,0);
end


%% If it's DART output, convert t from Gregorian to a number that works for matlab datenum

ref_day = datenum(1601,1,1,0,0,0);
t2 = t+ref_day;

% Also get the axis limits as the input start and end dates, in Matlab
% style.
t0 = E.day0+ref_day;
tf = E.dayf+ref_day;

%% Plot settings

lev2 = flipud(lev);
[X,Y] = meshgrid(t2,lev);

%% Plot!

if pcol
  pcolor(t2,lev,VAR)
  shading flat
else
  contourf(X,Y,VAR,ncontours,'LineColor','none')
end
  set(gca,'yscale','log')
  set(gca,'ydir','reverse')
  colormap(cmap)

  % even out the color axis if plotting innovation 
  if strcmp(E.diagn,'Innov') 
    clim = get(gca,'Clim');
    cc = max(abs(clim));
    set(gca,'Clim',cc*[-1,1])
  end

  ylabel('Level (hPa)')
  colorbar('Location','EastOutside')
  
  %set(gca,'YGrid','on')
  set(gca,'Xlim',[t0,tf])

  %set(gca,'YScale','log')
  % somehow contourf doesn't like Y to go from large to small, so need to
  % flip the ticklabels manually
  %set(gca,'YTick',[1000 800 700 600 500 400 300 100 50 5 1])
  set(gca,'YTick',fliplr([1000 500 300 100 50 5 1]))

  % set the x axis to dates
  xticks = t0:14:tf;
  set(gca,'XTick',xticks)
  datetick('x','dd-mmm','keeplimits','keepticks')


%% export this plot

if testplot 
  
  pw = 10;
  ph = 5;

  % paper and export settings
  set(gcf, 'PaperUnits','inches')
  set(gcf, 'Units','inches')
  set(gcf, 'PaperSize', [pw ph]);
  set(gcf, 'PaperPositionMode', 'manual');
  set(gcf, 'PaperPosition', [0 0 pw ph]);
  set(gcf, 'renderer', 'painters');
  % when exporting with export_fig, the following two commands
  % determine the aspect ratio of our figure, as well as the relative
  % font size (larger paper --> smaller font)
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  dum = strsplit(E.run_name,'/');
  cs = strrep(E.copystring,' ','_');
  datestring = [num2str(E.day0),'_',num2str(E.dayf)];
  if pcol
    pc = '_pcolor';
  else
    pc = '';
  end
  fig_name = [char(dum(1)),'_',E.variable,'_',E.diagn,'_',cs,'_',datestring,pc,'_p_time.eps'];
  disp(['Saving figure ',fig_name])
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)
end
