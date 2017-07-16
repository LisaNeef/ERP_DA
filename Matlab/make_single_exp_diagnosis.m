% function make_single_exp_diagnosis(E,vv,hostname)
%% make_single_exp_diagnosis.m
%
% This code makes a slew of plots that compare different state-space diagnostics
% for a single DART experiment.
%
% These are the diagnostics that are compared:
%1. truth
%2. ens mean without DA
%3. ens mean with DA
%4. ens spread 
%5. innovation
%6. error reduction
%  22 Aug 2013
%---------------------------------------------------------------------------------------------


%% temporary inputs
E_all = load_experiments;
E = E_all(3);
vv = 'U300';
hostname = 'blizzard';
%-------------------

%% Load the NoDA experiment for comparison purposes
Edum = load_experiments;
E_noDA = Edum(1);

%% define the diagnostic variable
[variable,level,latrange,lonrange] = diagnostic_quantities(vv);
E.variable = variable;
E.level = level;
E.latrange = latrange;
E.lonrange = lonrange;

%% Set up the different things we want to look at.
EE = [E,E_noDA,E,E,E,E];

EE(1).diagn = 'Truth';
EE(1).copystring = 'true state';
EE(1).plot_name = 'Truth';
EE(1).clim = [-40,40];

EE(2).diagn = 'Posterior';
EE(2).copystring = 'ensemble mean';
EE(2).plot_name = 'Ensemble Mean / No Assimilation';
EE(2).clim = [-40,40];

EE(3).diagn = 'Posterior';
EE(3).copystring = 'ensemble mean';
EE(3).plot_name = 'Ensemble Mean with Assimilation';
EE(3).clim = [-40,40];

EE(4).diagn = 'Posterior';
EE(4).copystring = 'ensemble spread';
EE(4).plot_name = 'Ensemble Spread';
EE(4).clim = [-15,15];

EE(5).diagn = 'Innov';
EE(5).copystring = 'ensemble mean';
EE(5).plot_name = 'Innovation';
EE(5).clim = 4*[-1,1];

EE(6).diagn = 'ER';
EE(6).copystring = 'ensemble mean';
EE(6).plot_name = 'Error Reduction';



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

break
for ii = 1:nX

  subplot(nR,nC,ii)
  if strcmp(EE(ii).diagn,'ER')
    EE(ii).diagn = 'RMSE';
    plot_lat_time_diff(EE(ii),E_noDA,hostname)
  else
    plot_lat_time(EE(ii),hostname)
  end

  title([vv,' ',EE(ii).plot_name])
  set(gca,'Clim',EE(ii).clim)

end



%% export figure
exp_name = strsplit(E(1).run_name,'/');
fig_name = [char(exp_name(1)),'.eps'];
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)


