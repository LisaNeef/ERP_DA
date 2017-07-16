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
NODA = EE(1);
ERPALL = EE(3);
hostname = 'blizzard';

% this is the large structure of things to plot
E = [NODA, ERPALL, NODA, ERPALL, ERPALL, ERPALL];
nX = length(E);

% define the stuff that's common to all experiments:
for iX = 1:nX
  E(iX).variable = 'U';
  E(iX).dayf = E(iX).day0+31+28+30;
  E(iX).diff = 0;
end

% 1: true state
E(1).copystring = 'true state';
E(1).diagn = 'Truth';
E(1).exp_name = 'U300 Truth';


% 2. RMSE with ERP DA
E(2).copystring = 'ensemble mean';
E(2).diagn = 'RMSE';
E(2).exp_name = 'RMSE ERP DA';

% 3. state with No DA
E(3).copystring = 'ensemble mean';
E(3).diagn = 'Posterior';
E(3).exp_name = 'U300 No DA';

% 4. Innovation
E(4).diagn = 'Innov';
E(4).copystring = 'ensemble mean';
E(4).exp_name = 'Innovation';

% 5. state with ERP assimiilation
E(5).copystring = 'ensemble mean';
E(5).diagn = 'Posterior';
E(5).exp_name = 'U300 ERP DA';

% 6. error reduction relative to NoDA
E(6).diagn = 'RMSE';
E(6).diff = 1;
E(6).exp_name = 'Error Reduction ERP DA';

% 6. increment 

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
fig_name = 'eval_large_ER_in_stratosphere2.eps';
disp(['creating figure ',fig_name])

ph = 10;
pw = 15;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)


