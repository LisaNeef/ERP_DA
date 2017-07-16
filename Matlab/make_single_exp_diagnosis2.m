% function make_single_exp_diagnosis(E,vv,hostname)
%% make_single_exp_diagnosis.m
%
% This code makes a slew of plots that compare different state-space diagnostics
% for a single DART experiment.
% Version 2 of this code looks at slightly different things.
%
% These are the diagnostics that are compared:
%1. mean error with no DA
%2. mean error with DA
%3. error reduction DA-noDA
%4. spread with no DA
%5. spread with DA
%6. Innovation
%  29 Aug 2013
%---------------------------------------------------------------------------------------------


%% temporary inputs
E_all = load_experiments;
E = E_all(3);
vv = 'U300';
hostname = 'blizzard';
%-------------------

%% Load the NoDA experiment for comparison purposes
Edum = load_experiments;
E_noDA = E(1);

%% define the diagnostic variable
[variable,level,latrange,lonrange] = diagnostic_quantities(vv);
E.variable = variable;
E.level = level;
E.latrange = latrange;
E.lonrange = lonrange;

%% Set up the different things we want to look at.
EE = [E,E,E,E];


EE(1).diagn = 'Po_minus_Tr';
EE(1).copystring = 'ensemble mean';
EE(1).plot_name = 'Error';
EE(1).clim = 6*[-1,1];
EE(1).diff_to_noDA = 0;

EE(2).diagn = 'RMSE';
EE(2).copystring = 'ensemble mean';
EE(2).plot_name = 'Error Reduction';
EE(2).clim = 6*[-1,1];
EE(2).diff_to_noDA = 1;

EE(3).diagn = 'Posterior';
EE(3).copystring = 'ensemble spread';
EE(3).plot_name = 'Spread Relative to No DA';
EE(3).clim = 6*[-1,1];
EE(3).diff_to_noDA = 1;

EE(4).diagn = 'Innov';
EE(4).copystring = 'ensemble mean';
EE(4).plot_name = 'Innovation';
EE(4).clim = 4*[-1,1];
EE(4).diff_to_noDA = 0;


%% figure setup
figure(1),clf
nX = length(EE);
nR = ceil(nX/2);
nC = 2;;
ph = 3*nR;
pw = 6*nC;
fs = 1.2;
set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])

%% Cycle through these diagnostics and make plots

for ii = 1:nX

  EE(ii)

  subplot(nR,nC,ii)

  % plotting the diff between this experiment and No-DA?
  if EE(ii).diff_to_noDA
    plot_lat_time_diff(EE(ii),E_noDA,hostname)
  else
    if EE(ii).diagn == 'Innov'
      % innovation plots are made with pcolor because innovations happen in short bursts.
      plot_lat_time_pcolor(EE(ii),hostname)
    else
      plot_lat_time(EE(ii),hostname)
    end
  end

  title([vv,' ',EE(ii).plot_name])
 % set(gca,'Clim',EE(ii).clim)

end



%% export figure
exp_name = strsplit(E(1).run_name,'/');
fig_name = [char(exp_name(1)),'_v2.eps'];
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)


