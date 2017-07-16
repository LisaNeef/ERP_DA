%% make_ERPs_filter_plots.m
% make and export a figure that compares the fit to ERPs for several
% experiments.
% The code runs over experiments defined in RR, and plots the variables in
% the concomitant directory YY.
%% User inputs

clear all;
clc;

% choose the hostname
hostname = 'blizzard';

% choose plotting case
plot_type   = 1;       % compare observation variance runs

% start and end dates, in terms of DART gregorian day count.
day0 = 146097;
dayf = 146155;

%% Choosing settings for this plot type

switch plot_type
    case 1
        RR              = {'ERP1_2001_N64_UVPS';'ERP1_2001_N64_UVPS_R2'; 'ERP3_2001_N64_UVPS';'ERP3_2001_N64_UVPS_R4'};        
        pmoid           = 'PMO_ERPALL_2001';
        YY              = {'ERP_PM1';'ERP_PM1';'ERP_LOD';'ERP_LOD'};
        TT              = {'PM1, R = 0';'PM1, R = 1E-16';'LOD, R = 0';'LOD, R = 1E-10'};
        nplots          = length(YY);
        LL              = [0,0,0,1];    % 1's for legends, 0 for none.
        fig_name        = 'compare_R_obsspace.eps';
end


%% some plot settings
LW = 2;
ph = 10;        % paper height
pw = 15;        % paper width
fs = 18;        % fontsize

switch hostname
    case 'ig48'
        plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';
    case 'blizzard'
        plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';
end


%% Cycle through variables

    switch hostname
        case 'ig48'
            figH = figure(1);clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end
    
    h = zeros(1:nplots);

for ii = 1:nplots

  obs_string = char(YY(ii))
  plot_title = TT(ii);
  leg = LL(ii);
  runid = char(RR(ii))
  
  h(ii) = subplot(2,2,ii);
  
  plot_ERPs_filter(runid,pmoid,obs_string,day0,dayf,leg,hostname);
  
  % add an extra annotation
  xlim = get(gca,'Xlim');
  ylim = get(gca,'Ylim');
  dxlim = xlim(2)-xlim(1);
  dylim = ylim(2)-ylim(1);
  text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,char(TT(ii)),'FontSize',16,'BackgroundColor',ones(1,3))  
  
 % title(char(TT(ii)));
end


%% now go through panesl and make them look right

    % now go through panesl and make them look right
    set(gcf,'Position',[911 551 845 719])

    x0 = 0.06;                  % left position
    dy = .10;
    y0 = 0.99;                  % top of plot
    w = 1; 
    dw = .09;
    w2 = (w-2*dw-x0)/2;               % width per figure
    ht = (y0-3*dy)/2;          % height per figure

    y3 = y0-dy-ht+0;
    set(h(1),'Position',[x0 y3 w2 ht])
    set(h(2),'Position',[x0+w2+dw y3 w2 ht])

    y3 = y0-2*dy-2*ht;
    set(h(3),'Position',[x0 y3 w2 ht])
    set(h(4),'Position',[x0+w2+dw y3 w2 ht])
 

%% Plot export
   for k = 1:4
    
       set( h(k)                       , ...
       'FontName'   , 'Helvetica' ,...
       'FontSize'   , 16         ,...
       'Box'         , 'on'     , ...
       'YGrid'       , 'on'      , ...
       'XGrid'       , 'on'      , ...
       'TickDir'     , 'out'     , ...
       'TickLength'  , [.02 .02] , ...
       'XColor'      , [.3 .3 .3], ...
       'YColor'      , [.3 .3 .3], ...
       'LineWidth'   , 1         );
   end
   
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','eps');
    if strcmp(hostname,'blizzard')
         close(figH) ;
    end






