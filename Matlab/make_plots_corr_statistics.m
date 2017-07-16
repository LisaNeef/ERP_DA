%% make_plots_corr_statistics.m
%
% cycle over a set of variables and aefs, and generate a pile of plots of 
% correlation statstics (mea, std, abs)

%% inputs

clear all;
clc;
dart_run = 'ERPALL_2001_N96';
datestring = '146097_146153';

VV = {'U','V','PS'}
XX = {'X1','X2','X3'}
SS = {'mean','std','meanabs','stdabs'};
LL = 900;

naefs = length(XX);
nvar = length(VV);
nlev = length(LL);
nstats = length(SS);

%% plot/export settings

LW = 2;
ph = 6;        % paper height
pw = 12;        % paper width
fs = 20;        % fontsize
plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';

%% make the plots

nfigs = nstats*naefs*nvar*nlev;
fig_handles = zeros(nfigs,1)+NaN;

ifig = 1;

for ivar = 1:nvar
  variable = char(VV(ivar));
  for istat = 1:nstats
    statistic = char(SS(istat));
    for iaef = 1:naefs
      aef = char(XX(iaef));
      for ilev = 1:nlev

        if (strcmp(variable,'V')+strcmp(aef,'X3') == 2)
          return
        end

        level = char(LL(ilev));
        fig_handles(ifig) = figure('visible','off') ;
        plot_corr_statistics(dart_run,variable,aef,level,statistic,datestring)

        % annotation.
        ylim = get(gca,'YLim');
        xlim = get(gca,'XLim');
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);
        %text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,statistic,'FontSize',16)
        title(['Correlation ',statistic,' ',variable,' ',aef])

         % export:
         fig_name = [dart_run,'_corr_',variable,num2str(LL(ilev)),'_',aef,'_',statistic,'_',datestring,'.png'];
         exportfig(fig_handles(ivar),[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','format','png');

        close(fig_handles(ivar)) ;
        ifig = ifig+1;
      end
    end
  end
end






