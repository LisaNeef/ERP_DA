%% make_plots_correlation.m
%
% cycle over a set of variables and aefs, and generate a pile of plots of 
% instantaneous correlation (from the ensemble)

%% inputs

clear all;
clc;
dart_run = 'ERPALL_2001_N96';
day_prefix = 'ERPALL_N96';
N = 96;

VV = {'U'}
XX = {'X1'}
LL = 300;

naefs = length(XX);
nvar = length(VV);
nlev = length(LL);
days = 146119:1:146125;
ndays = length(days);

%% plot/export settings

LW = 2;
ph = 6;        % paper height
pw = 12;        % paper width
fs = 20;        % fontsize
plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';

%% make the plots

nfigs = ndays*naefs*nvar;
fig_handles = zeros(nfigs,1)+NaN;

ifig = 1;

for ivar = 1:nvar
  variable = char(VV(ivar));
  for iday = 1:ndays
      for iaef = 1:naefs
        aef = char(XX(iaef));
        for ilev = 1:nlev
          level = char(LL(ilev));
          for iday = 1:ndays
            day = days(iday);
            fig_handles(ifig) = figure('visible','off') ;
            plot_corr_instantaneous(dart_run,day_prefix,N,variable,aef,level,day)

            % annotation.
            ylim = get(gca,'YLim');
            xlim = get(gca,'XLim');
            dxlim = xlim(2)-xlim(1);
            dylim = ylim(2)-ylim(1);
            text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,num2str(day),'FontSize',16)

            % export:
            fig_name = [dart_run,'_corr_',variable,num2str(LL(ivar)),'_',aef,'_',num2str(day),'.png'];
            exportfig(fig_handles(ivar),[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','format','png');

            close(fig_handles(ivar)) ;
            ifig = ifig+1;
         end
      end
    end
  end
end






