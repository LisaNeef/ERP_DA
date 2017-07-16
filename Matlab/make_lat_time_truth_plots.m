% Umbrella code for making plots of DART-CAM output across latitude and
% time.
%
% Lisa Neef, 27 Feb 2012

clear all;

run             = 'ERPALL_12H_2001_N64_UVPS';
year            = '2001';
AAM_weighting   = 'none';
hostname = 'blizzard';

copystring = 'ensemble mean';
diagn = 'Posterior';
day0 = 146097;
dayf = 146461;
variable        = 'PS';
level           = 0;

%% some plot settings
LW = 1;
ph = 6;        % paper height
pw = 17;        % paper width
fs = 20;        % fontsize

plot_dir = ['/work/bb0519/b325004/DART/ex/',run,'/'];


%% make the plots


% ---code to make the plot.

parts = regexp(copystring,' ','split');
what = char(parts(2));
fig_name = [run,'_',variable,num2str(level),'_',AAM_weighting,'_',diagn,'_',what,'_lat_time_y',year];

figH = figure('visible','off') ; 

plot_lat_time(run,copystring,year,variable,level,AAM_weighting,diagn,day0,dayf,hostname)

exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,'fontmode','fixed', 'fontsize',fs,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');
close(figH) ;
