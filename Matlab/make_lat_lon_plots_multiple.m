% Umbrella code for making plots of DART-CAM output across latitude and
% longitude, and averaged over the given days.
% This version of the code goes over several runs and makes nx2 tiles of their plots.
%
% Lisa Neef, 19 April 2012.

clear all;
clc;
hostname        = 'blizzard';

day0            = 146097;
dayf            = 146150;

%diagn =  'RMSE';   
%copystring      = 'ensemble mean';   
diagn = 'Prior';
copystring = 'ensemble spread';

plot_type       = 1;   % compare different localization settings

%% settings for this plot type
switch plot_type
    case 1
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        prefix = 'compare_loc_';
        suffix = '_RMSE_lat_lon_7d_ave';
        nvar = length(VV);
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERP2_2001_N64_GC0p32';
        r3 = 'ERP2_2001_N64_GC0p46';
        r4 = 'ERP2_2001_N64_GC0p58';
        r5 = 'ERP2_2001_N64_GC0p68';
        R = {r0;r1;r2;r3;r4;r5};
        run_names = {'no DA';'PM2';'Loc 0.32';'Loc 0.46';'Loc 0.58';'Loc 0.68'};
end

%% some plot settings
LW = 1;
ph = 12;        % paper height
pw = 12;        % paper width
fs = 18;        % fontsize

switch hostname
    case 'ig48'
        plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';
    case 'blizzard'
        plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';
end

nruns = length(R);
nrows = ceil(nruns/2);

%% cycle over the main variables and make a plot for each

for ii = 1:1
    variable = char(VV(ii));
    h = zeros(1,nruns);
 
    switch hostname
        case 'ig48'
            figH = figure(1);clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end

    for irun = 1:nruns
        h(irun) = subplot(nrows,2,irun);
	plot_lat_lon_ave(char(R(irun)),diagn,copystring,variable,LL(ii),day0,dayf,hostname)  

        % add annotation:
        ylim = get(gca,'YLim');
        xlim = get(gca,'XLim');
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);
        text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,run_names(irun),'FontSize',16,'BackgroundColor',ones(1,3))
        %text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,run_names(irun),'Color',zeros(1,3))
    end

    % adjust the axes.
    x0 = 0.08;                  % left position
    dy = .07;
    y0 = 0.98;                  % top of plot
    w = 1;
    dw = .15;
    w2 = (w-1.5*dw-x0)/2;               % width per figure
    ht = (y0-nrows*dy)/nrows;          % height per figure

    kk = 1;
    for iplot = 1:nrows
        y = y0-(iplot-1)*dy-iplot*ht;
        set(h(kk),'Position',[x0 y w2 ht])
        if nruns >= kk+1
            set(h(kk+1),'Position',[x0+w2+dw y w2 ht])
        end
        kk = kk+2;
    end



    fig_name = [prefix,variable,suffix,'.png'];
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');

    if strcmp(hostname,'blizzard')
         close(figH) ;
    end

end



 
