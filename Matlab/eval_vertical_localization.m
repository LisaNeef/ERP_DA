% eval_large_ER_in_stratosphere.m
%
% When we compare ERPALL with NoDA, there is huge error reduction at upper levels, 
% at least for the first few assimilation days.  
%%
%1. Why do we happen to swing into the right direction?
%
%2. Does this persist throughout the DA period?
%
%3. Is this an interesting result for the paper?
%
% 10 Sep 2013
%-----------------------------------------------------------------------------------------

clear all;
clc;

%% Define what we want to plot

% load experiments 
EE = load_experiments;
hostname = 'blizzard';

% this is the large structure of things to plot
E = EE([3,10])
nX = length(E);

% define the stuff that's common to all experiments:
for iX = 1:nX
  E(iX).variable = 'U';
  E(iX).dayf = E(iX).day0+10;
  E(iX).diff = 0;
  E(iX).diagn = 'Innov';
  E(iX).copystring = 'ensemble mean';
end

E(1).exp_name = 'No cutoff';
E(2).exp_name = '200 mb cutoff';

%% make the plots
kk = 1;
figure(1),clf
set(1,'visible','off')

for iX = 1:nX

  subplot(3,2,kk) 
    if E(iX).diff
      NODA.variable = E(iX).variable
      NODA.copystring = E(iX).copystring
      NODA.diagn = E(iX).diagn
      NODA.dayf = E(iX).dayf
      plot_height_time_diff(E(iX),NODA,hostname)
    else
      if strcmp(E(iX).diagn,'Innov')
        plot_height_time_pcolor(E(iX),hostname)
      else
        plot_height_time(E(iX),hostname)
      end
    end

  % add a title 
  title(E(iX).exp_name)

  % even out the color limits
  cc = get(gca,'clim');
  cmax = max(abs(cc));
  set(gca,'Clim',cmax*[-1,1])
 
  % advance the plot index
  kk = kk+1;
       
end



%% export this plot

set(gcf, 'renderer', 'painters');
fig_name = 'eval_vertical_localization.eps';
disp(['creating figure ',fig_name])

ph = 10;
pw = 15;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)


