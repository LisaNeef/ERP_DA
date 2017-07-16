% Umbrella code for making plots of DART-CAM output across latitude and
% time.
%
% Lisa Neef, 21 Dec 2011.
%
% MODS:
%   20 Mar 2012: instead of plotting option 'ABSPo-Tr', do RMSE (where the
%   mean is over longitude in this case.)
%   11 Apr 2012: some cosmetic changes

clear all;
clc;

year            = '2001';
AAM_weighting   = 'none';
hostname        = 'blizzard';


% choose color axis limits - divergent for things that can be negative, sequential for 
% diagnostics that are absolute value
cax_div = 20*[-1,1];
cax_seq = 20*[0,1];


day0 = 146097;
dayf = 146153;

plot_type = 1;      % 1: compare true RMSE different observation variable configurations
%plot_type = 2;      % 2: compare different filter modifications
%plot_type = 3;       % 3: compare different localisation settings
%plot_type = 4;       % 4: compare RMSE, increment, and spread for a single run - ens. mean
%plot_type = 5;       % 5: compare RMSE, increment, and spread for a single run - one member

%% choose settings for plotting case

switch plot_type
    case 1
        copystring = {'ensemble mean','ensemble mean','ensemble mean','ensemble mean'};
        %diagn = {'Innov','Innov','Innov','Innov'};
        diagn = {'RMSE','RMSE','RMSE','RMSE'};
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'RMSE';
        nvar = length(VV);
        R = {'ERPALL_2001_noDA';'ERP1_2001_N64_UVPS';'ERP2_2001_N64_UVPS_V2';'ERP3_2001_N64_UVPS'};
        run_names = {'no DA';'PM1';'PM2';'LOD'};
        fig_prefix = 'compare_DAvariable_lat_time_';
        cax = [cax_seq;cax_seq;cax_seq;cax_seq];
    case 2
        copystring = {'ensemble mean','ensemble mean','ensemble mean'};
        diagn = {'Innov','Innov','Innov'};
        VV = {'U','V','PS'};
        LL = [300,300,0];
        suffix = 'RMSE';
        nvar = length(VV);
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERPALL_2001_N64_SR';
        r3 = 'ERPALL_2001_N64_sortinc';
        R = {r0;r1;r2;r3};
        names = {'no DA';'Regular Filter';'Spread Restoration';'Sorting Increments'};
        fig_prefix = 'compare_filter_mods_lat_time_';
    case 3
        copystring = {'ensemble mean','ensemble mean','ensemble mean'};
        diagn = {'Innov','Innov','Innov'};
        VV = {'U','V','PS'};
        LL = [300,300,0];
        suffix = 'RMSE';
        nvar = length(VV);
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERP2_2001_N64_UVPS_V2';
        r2 = 'ERP2_2001_N64_GC0p32';
        r3 = 'ERP2_2001_N64_GC0p58';
        r4 = 'ERP2_2001_N64_GC1p57';
        R = {r0;r1;r2;r3;r4};
        run_names = {'no DA';'PM2';'PM2, Loc 0.32';'PM2, Loc 0.58';'PM2, Loc \pi/2'};
        fig_prefix = 'compare_localization_lat_time_';
    case 4
        copystring = {'ensemble mean','ensemble mean','ensemble spread'};
        diagn = {'RMSE','Innov','Posterior'};
        VV = {'U','V','PS'};
        LL = [300,300,0];
        suffix = 'RMSE';
        nvar = length(VV);
        %r0 = 'ERPALL_2001_noDA';
        %r0 = 'ERPALL_2001_N64_UVPS_V2';
        %r0 = 'ERP2_2001_N64_UVPS_V2';
        r0 = 'ERP2_2001_N64_GC1p57';
        R = {r0;r0;r0};
        run_names = {'True Error','Increment','Posterior Spread'};
        fig_prefix = [r0,'_lat_time_'];
        cax = [cax_seq;cax_div;cax_seq];
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
    level = LL(ifig);
    
    fig_name = [fig_prefix,variable,num2str(level),'_',suffix,'.png'];

    switch hostname
        case 'ig48'
            figH = figure(ifig);
            figure(ifig),clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end

    h = zeros(1,nruns);
    
    for ii = 1:nruns
        h(ii) = subplot(nruns,1,ii);
        run = char(R(ii));
        CS = char(copystring(ii));
        D = char(diagn(ii));
        plot_lat_time(run,CS,year,variable,level,AAM_weighting,D,day0,dayf,hostname)
        if plot_type == 4|plot_type == 5
            caxis(cax(ii,:))
        else
            if ii == 1
                cax = get(gca,'clim');
            end
            caxis(cax);
        end
        colorbar 

        % add annotation:
        ylim = get(gca,'YLim');
        xlim = get(gca,'XLim');
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);  
        text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,run_names(ii),'FontSize',16,'BackgroundColor',ones(1,3))  

    end 
    

    % unify the color axis for the plot types where each plot shows the same thing.
    linkaxes(h)

    % make the axes look good
    %set(gcf,'Position',[911 551 845 719])

    x0 = 0.08;                  % left position
    dy = .05;
    y0 = 0.98;                  % top of plot
    w = 1; 
    dw = .09;
    w2 = (w-dw-x0);               % width per figure
    ht = (y0-nruns*dy)/nruns;          % height per figure

    for ii = 1:nruns
        y = y0-(ii-1)*dy-ii*ht;
        set(h(ii),'Position',[x0 y w2 ht])
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






