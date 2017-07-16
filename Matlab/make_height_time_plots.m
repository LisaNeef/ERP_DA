% Umbrella code for making plots of DART-CAM output across height and time
%
% Lisa Neef, 11 Apr 2012.
%
% MODS:

clear all;
clc

year            = '2001';
AAM_weighting   = 'none';
hostname        = 'blizzard';

copystring = 'ensemble mean';
diagn = 'RMSE';
day0 = 146097;
dayf = 146153;

plot_type = 1;      % 1: compare true RMSE different observation variable configurations
%plot_type = 2;       % 2: compare different filter modifications
%plot_type = 3;       % 3: compare different localisation settings

%% choose settings for plotting case


switch plot_type
    case 1
        VV = {'U','V'};
        suffix = 'RMSE';
        nvar = length(VV);
        R = {'ERPALL_2001_noDA';'ERP1_2001_N64_UVPS';'ERP2_2001_N64_UVPS_V2';'ERP3_2001_N64_UVPS'};
        names = {'no DA';'PM1';'PM2';'LOD'};
        %fig_prefix = 'compare_DAvariable_p_time_SH_';
        %latrange = [-90,0];
        fig_prefix = 'compare_DAvariable_p_time_NH_';
        latrange = [0,90];
    case 2
        VV = {'U','V'};
        suffix = 'RMSE';
        nvar = length(VV);
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERPALL_2001_N64_SR';
        r3 = 'ERPALL_2001_N64_sortinc';
        R = {r0;r1;r2;r3};
        names = {'no DA';'Regular Filter';'Spread Restoration';'Sorting Increments'};
        fig_prefix = 'compare_filter_mods_p_time_';
        latrange = [-90,90];
    case 3
        VV = {'U','V'};
        suffix = 'RMSE';
        nvar = length(VV);
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERP2_2001_N64_GC0p32';
        R = {r0;r1;r2};
        names = {'no DA';'PM2';'PM2, Loc 0.32'};
        fig_prefix = 'compare_localization_p_time_';
        latrange = [-90,90];

end       


nruns = length(R);

%% some plot settings
LW = 1;
ph = 16;        % paper height
pw = 13;        % paper width
fs = 20;        % fontsize

switch hostname
    case 'ig48'
        plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';
    case 'blizzard'
        plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';
end


%% make the plots

for ifig = 1:nvar
   
    variable = char(VV(ifig));
    
    parts = regexp(copystring,' ','split');
    what = char(parts(2));
    fig_name = [fig_prefix,variable,'_',suffix,'.png'];

    switch hostname
        case 'ig48'
            figH = figure(ifig);
            figure(ifig),clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end

    h = zeros(1,nruns);
    
    for ii = 1:nruns
        h(ii) = subplot(4,1,ii);
        run = char(R(ii))
        plot_height_time(run,copystring,year,variable,latrange,AAM_weighting,diagn,day0,dayf,hostname)
        
        % set the color axis according to plot diagnostic and variable
        variable = char(VV(ifig));
        switch diagn
            case 'Innov'
                switch variable
                    case 'U'
                        set(gca,'Clim',[0,30])
                    case 'V'
                        set(gca,'Clim',[0,15])
                 end
        end

        % add annotation:
        ylim = get(gca,'YLim');
        xlim = get(gca,'XLim');
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);  
        text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,names(ii),'FontSize',16,'BackgroundColor',ones(1,3))  

    end 
    
    % make the axes look good
    %set(gcf,'Position',[911 551 845 719])

    x0 = 0.08;                  % left position
    dy = .05;
    y0 = 0.98;                  % top of plot
    w = 1; 
    dw = .09;
    w2 = (w-dw-x0);               % width per figure
    ht = (y0-4*dy)/4;          % height per figure

    YY = zeros(4,1);
    YY(1) = y0-ht;
    YY(2) = y0-dy-2*ht;
    YY(3) = y0-2*dy-3*ht;
    YY(4) = y0-3*dy-4*ht;
    
    for ii = 1:nruns
        set(h(ii),'Position',[x0 YY(ii) w2 ht]) 
    end

   for k = 1:nruns
      % if k < 4
      %     set(h(k),'XTick',[])
      % end
    
       set( h(k)                       , ...
       'FontName'   , 'Helvetica' ,...
       'FontSize'   , 16         ,...
       'Box'         , 'off'     , ...
       'YGrid'       , 'off'      , ...
       'XGrid'       , 'on'      , ...
       'TickDir'     , 'in'     , ...
       'TickLength'  , [.02 .02] , ...
       'XColor'      , [.3 .3 .3], ...
       'YColor'      , [.3 .3 .3], ...
       'LineWidth'   , 1         );
   end
   
    
    
    
    % export and close
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,'fontmode','fixed', 'fontsize',fs,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');

    if strcmp(hostname,'blizzard')
        close(figH) ;
    end
        

end






