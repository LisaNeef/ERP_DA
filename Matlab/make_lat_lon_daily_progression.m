% Plot a six-day progression though some variable and some diagnostic.
%
% Lisa Neef, 28 Mar 2012.
%
% MODS:
%   17 April 2012: allow other types of steps rather than just 1 day.

clear all;
clc;

% select the run.
run             = 'ERP2_2001_N64_UVPS_V2';
%run             = 'ERP2_2001_N64_GC1p57';
%run             = 'ERP2_2001_N64_GC0p32';


% select the machine
hostname        = 'blizzard';

ndays = 6;
dd = 3;
days = 146097:dd:146095+dd*ndays
%ndays = length(days);

%plot_type       = 1;   % prior ensemble spread
%plot_type       = 2;   % RMS true error (to compare with ensemble spread)
plot_type       = 3;	% analysis increment

%% settings for this plot type
switch plot_type
    case 1
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'prior_spread_progr';
        nvar = length(VV);
        cax = [0,30];
        diagn = 'Prior';
	copystring = 'ensemble spread';
    case 2
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'rmse_progr';
        nvar = length(VV);
        cax = [0,30];
        diagn = 'RMSE';
	copystring = 'ensemble mean';
    case 3
        VV = {'U','V','PS'};
        LL = [300,300,0];
        fig_labels = {'U300','V300','PS'};
        suffix = 'incr_progr';
        nvar = length(VV);
        cax = 15*[-1,1];
        diagn = 'Innov';
	copystring = 'ensemble mean';

end


%% some plot settings
LW = 1;
ph = 14;        % paper height
pw = 24;        % paper width
fs = 16;        % fontsize

switch hostname
    case 'ig48'
        plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';
    case 'blizzard'
        plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';
end

nrows = ceil(ndays/2);


%% cycle over the main variables and make a plot for each

%for ii = 1:nvar
for ii = 1;
 
    h = zeros(1,ndays);
    variable = char(VV(ii));
    
    switch hostname
        case 'ig48'
            figH = figure(1);clf
        case 'blizzard'
            figH = figure('visible','off') ; 
    end
    
    % cycle through days and make a plot for each one
    for iday = 1:ndays
        %h(iday) = subplot(1,ndays,iday);
        h(iday) = subplot(nrows,2,iday);
        plot_lat_lon_daily(run,diagn,copystring,variable,LL(ii),days(iday),hostname);
        caxis(cax)
        colorbar
        xlim = get(gca,'Xlim');
        ylim = get(gca,'Ylim');
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);
        text(xlim(1)+.05*dxlim,ylim(1)+0.1*dylim,num2str(days(iday)),'FontSize',16,'Color',zeros(1,3))
   end
    
    % now go through panesl and make them look right
    set(gcf,'Position',[911 551 845 719])

    x0 = 0.06;                  % left position
    dy = .06;
    y0 = 0.99;                  % top of plot
    w = 1; 
    dw = .09;
    w2 = (w-3*dw-x0)/2;               % width per figure
    ht = (y0-(nrows+1)*dy)/nrows;          % height per figure

    
    kk=1;
    for irow = 1:nrows
        y = y0 - irow*dy-irow*ht;    
        set(h(kk),'Position',[x0 y w2 ht])
        set(h(kk+1),'Position',[x0+w2+dw y w2 ht])
        kk = kk+2;
    end
    

   for k = 1:ndays
   
       set( h(k)                       , ...
       'FontName'   , 'Helvetica' ,...
       'FontSize'   , 16         ,...
       'Box'         , 'off'     , ...
       'YGrid'       , 'on'      , ...
       'XGrid'       , 'on'      , ...
       'TickDir'     , 'out'     , ...
       'TickLength'  , [.02 .02] , ...
       'XColor'      , [.3 .3 .3], ...
       'YColor'      , [.3 .3 .3], ...
       'LineWidth'   , 1         );
   
       % for even numbers, take out yticklabels
       if rem(k,2) == 0
           set(h(k),'YTick',[])
       end
       
       % for top rows, take out xticklabels
        if k < ndays-1
           set(h(k),'XTick',[])
       end
  end
   
    fig_name = [run,'_',char(fig_labels(ii)),'_',suffix,'.png'];
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
    if strcmp(hostname,'blizzard')
         close(figH) ;
    end

end



 
