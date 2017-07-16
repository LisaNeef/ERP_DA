% Umbrella code for making plots of DART-CAM output across latitude and
% longitude, and averaged over the given days.
%
% Lisa Neef, 13 Mar 2012.
%
% MODS:
%  9 Aug 2012: updating the unputs to plot_lat_lon_ave to make it more flexible.

clear all;
clc;

run             = 'ERP3_2001_N64_UVPS';
noDA             = 'ERPALL_2001_noDA';
hostname        = 'blizzard';

GD		= 146097:146153;

%plot_type       = 1;   % true RMSE averaged over first 7 days of DA
%plot_type       = 2;   % ensemble spread averaged over first 7 days of DA
plot_type	 = 3;   % RMSE relative to the no-DA case 

%% settings for this plot type
switch plot_type
    case 1
        diagn =  'RMSE';   
        copystring      = 'ensemble mean';   
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'RMSE_lat_lon_7d_ave';
        nvar = length(VV);
    case 2
        diagn =  'Prior';   
        copystring      = 'ensemble spread';   
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'spread_lat_lon_7d_ave';
        nvar = length(VV);
    case 3
        diagn =  'ER';   
        copystring      = 'ensemble mean';   
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'ER_lat_lon_2mo_ave';
        nvar = length(VV);

end


%% some plot settings
LW = 1;
ph = 7;        % paper height
pw = 12;        % paper width
fs = 25;        % fontsize

switch hostname
    case 'ig48'
        plot_dir = ['/dsk/nathan/lisa/DART/ex/',run,'/'];
    case 'blizzard'
        plot_dir = ['/work/bb0519/b325004/DART/ex/Comparisons/'];
end


%% cycle over the main variables and make a plot for each

for ii = 1:nvar
    
    variable = char(VV(ii));
    
    switch hostname
        case 'ig48'
            figH = figure(1),clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end
    plot_lat_lon_ave(run,noDA,diagn,copystring,variable,LL(ii),GD,hostname)  
    fig_name = [run,'_',char(fig_labels(ii)),'_',suffix,'.png'];
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
    if strcmp(hostname,'blizzard')
         close(figH) ;
    end

end



 
