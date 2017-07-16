%% plot_lat_lon_mm.m
%
% Make a 2-D plot of the DART-CAM state, using monthly-mean data.
% Right now equipped for variables U and PS, and AAM excitation functions
% X1, X2, and X3, using DART-CAM output.
%
% Lisa Neef, 19 Dec 2011.
%-------------------------------------------------------------

%% User inputs
clear all;

run             = 'ERPALL_2000';
diagn           = 'Posterior';
copystring     = 'ensemble spread';      % choose either mean or spread here
year            = '2000';
variable        = 'U';
level           = 300;
AAM_weighting   = 'none';
month           = 1;

%% other paths, etc.

plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';

if strcmp(run(1:3),'ERA')
    era_run = 1;
    diagn = '';
    copystring = '';
else 
    era_run = 0;
end

if strcmp(diagn,'Truth')
    copystring = 'true state';
end

%% Fetch the data

[VAR,lat,lon] = get_lat_lon_mm_DART_CAM(run,diagn,copystring,variable,level,AAM_weighting,month);



%% Plot settings


LW = 1;
ph = 6;        % paper height
pw = 10;        % paper width
fs = 15;        % fontsize


nlevels = 20;

% also shift the lons over to get it right for the map 
% (lons should go -180 to 180)
if min(lon) <= 0
  dum = find(lon > 180);
  lon2=lon;
  lon2(dum) = -(360 - lon(dum));
  [a,b] = sort(lon2);
  lon = a;
end

% the title will be the name of the month shown
switch month
    case 1
        month_string = 'Jan';
    case 2
        month_string = 'Feb';
    case 3
        month_string = 'Mar';
    case 4
        month_string = 'Apr';
    case 5
        month_string = 'May';
    case 6
        month_string = 'Jun';
    case 7
        month_string = 'Jul';
    case 8
        month_string = 'Aug';
    case 9
        month_string = 'Sep';
    case 10
        month_string = 'Oct';
    case 11
        month_string = 'Nov';
    case 12
        month_string = 'Dec';
end

%% Plots!

figure(1),clf

  ax = axesm('MapProjection','eqdcylin','grid','on',...
      'MeridianLabel','on','ParallelLabel','on',...
      'PLabelLocation',30,'MLabelLocation',90);
  contourfm(lat,lon,VAR(:,b),nlevels,'LineStyle','none');
  c = load('coast');
  plotm(c.lat,c.long,'Color','black','LineWidth',1);

  box off
  axis off
  gridm on
  framem off
  
setm(gca,'frame','off')
setm(gca,'MLabelParallel',-90)


% make the axes not suck
dx = .01;                   % x- margins
dy = .01;                   % y- margins
dbar = 2*dy;                % space between colorbar and plot

w = (1-2*dx);        % width of figures
ht = (1-1*dy-dbar);          % height per figure
hbar = 0.1*ht;             % height of colorbar

set(gcf,'Position',[60   610   499   363])
set(ax,'Position',[dx dy+dbar+dbar w ht])

% adjust color axis and add color bar.
switch variable
  case 'U'
    caxis(50*[-1 1])    % wind fields in m/s
  case 'PS'
     caxis(100*[-1,1])  % pressure field in hPa
end
        
cb = colorbar('horiz','OuterPosition',[dx dy w hbar]);

% title
tt= title(month_string);
get(tt,'Position')
set(tt,'Position',[0 1.7 50]) 

% plot labels
ylim = get(gca,'YLim');
xlim = get(gca,'XLim');
dxlim = xlim(2)-xlim(1);
dylim = ylim(2)-ylim(1);

parts = regexp(copystring,' ','split');
textstring = [diagn,' ',copystring];
if strcmp(diagn,'Truth'), textstring = 'Truth'; end
if strcmp(run,'ERA-Interim'), textstring = 'ERA-Interim'; end
text(xlim(1)+.05*dxlim,ylim(1)+0.2*dylim,textstring,'FontSize',16,'Color',zeros(1,3))  
 
%% Other Plot adustments

      set( gca                       , ...
          'FontName'   , 'Helvetica' ,...
          'Box'         , 'off'     , ...
          'TickDir'     , 'out'     , ...
          'TickLength'  , [.02 .02] , ...
          'XColor'      , [.3 .3 .3], ...
          'YColor'      , [.3 .3 .3], ...
          'LineWidth'   , 1         );



%% Plot export

if strcmp(copystring,'ensemble mean'), cc = 'ens_mean'; end
if strcmp(copystring,'ensemble spread'), cc = 'spread'; end
if strcmp(copystring,'true state'), cc = ''; end
if strcmp(copystring,''), cc = ''; end


        switch variable
            case {'U','V'}
                fig_name = [run,'_',diagn,'_',cc,'_',variable,num2str(level),'_lat_lon_',month_string,'_y',year];
            case 'PS'
                fig_name = [run,'_',diagn,'_',cc,'_',variable,'_lat_lon_',month_string,'_y',year];
        end
       


exportfig(1,[plot_dir,fig_name],'width',pw,'height',ph,'fontmode','fixed', 'fontsize',fs,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');





