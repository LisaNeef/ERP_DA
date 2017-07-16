%% plot_ens_spread_evolution.m
%  
%  Make a plot of the evolution of the ens spread in an ERP assimilation
%  experiment.

% Started 8 Oct 2011.

%% Define Inputs

datadir = '/work/bb0519/b325004/DART/ex/ERP_19790115-19790131_ENSRF8/FILTER/DART/';
fname = [datadir,'obs_diag_output.nc'];

%copystring = 'spread';                 % spread of the ensemble
%copystring = 'rmse';
%copystring = 'bias';
%copystring = 'totalspread';            % pooled spread of the observation (knowing its observational error) and the ensemble.
%copystring = 'ens_mean';
copystring = 'observation';

obsstring = 'ERP_LOD';
%obsstring = 'ERP_PM1';
%obsstring = 'ERP_PM2';


%% Call DART matlab code.

plotdat = plot_evolution(fname, copystring, obsstring);

%% Now remake a nice plot.

figure(2),clf


ylim = [0,3]*10e-6;

set(gca,'YLim',ylim);

