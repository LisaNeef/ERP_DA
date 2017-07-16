% Some code bits to perfrom basic observation-space diagnostics in DART.

clear all;

%---set file paths and stuff.

addpath('/home/ig/neef/MFiles/DART/')
addpath('/home/ig/neef/MFiles/utilities/')
addpath('/home/ig/neef/MFiles/netcdf/mexcdf/snctools/')
addpath('/home/ig/neef/MFiles/netcdf/mexcdf/mexnc/','-BEGIN')
addpath('/home/ig/neef/DART/trunk/matlab')


%---choose which thing to plot ('copystring')
%copystring = 'Nposs';
%copystring = 'Nused';
%copystring = 'NbigQC';
%copystring = 'NbadIZ';
%copystring = 'NbadUV';
%copystring = 'NbadLV';
%copystring = 'rmse';
%copystring = 'bias';
%copystring = 'spread';
%copystring = 'totalspread';
%copystring = 'NbadDARTQC';
%copystring = 'observation';
%copystring = 'ens_mean';
%copystring = 'N_DARTqc_0';
%copystring = 'N_DARTqc_1';
%copystring = 'N_DARTqc_2';
%copystring = 'N_DARTqc_3';
%copystring = 'N_DARTqc_4';
%copystring = 'N_DARTqc_5';
%copystring = 'N_DARTqc_6';
%copystring = 'N_DARTqc_7';


%% plot vertical profiles of biases compared to something else, prior and posterior.
copystring = 'ens_mean';  
fname = 'obs_diag_output.nc';
plot_bias_xxx_profile(fname,copystring);

% plot the spatial and temporal coverage for an observation type
%---not available-----plot_coverage('obs_diag_output.nc');

%% plot the locations and values of the observations
fname = 'obs_epoch_043.nc';
ObsTypeString = 'ALL';
region        = [0 360 -90 90 -Inf Inf];
CopyString    = 'observation';
QCString      = 'DART quality control';
maxgoodQC     = 0;
verbose       = 1;   % anything > 0 == 'true'
twoup         = 1;   % anything > 0 == 'true'

plot_obs_netcdf(fname, ObsTypeString, region, CopyString, QCString, maxgoodQC, verbose, twoup);
LW = 1;
ph = 12;        % paper height
pw = 8;        % paper width
FS = 12;        % fontsize
fig_name = [fname(1:13),'_',ObsTypeString,'.png'];
exportfig(1,fig_name,'width',pw,'height',ph,'fontmode','fixed', 'fontsize',FS,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');



%% plot the difference between the ensemble mean of the prior and the actual observation value
fname = 'obs_epoch_045.nc';
ObsTypeString = 'RADIOSONDE_U_WIND_COMPONENT';
region        = [0 360 -90 90 -Inf Inf];
CopyString1   = 'observation';
CopyString2   = 'prior ensemble mean';
QCString      = 'DART quality control';
maxQC         = 1;   % max QC to consider when taking differences.
verbose       = 1;   % anything > 0 == 'true'
twoup         = 1;   % anything > 0 == 'true'

plot_obs_netcdf_diffs(fname, ObsTypeString, region, CopyString1, CopyString2, QCString, maxQC, verbose, twoup);
LW = 1;
ph = 12;        % paper height
pw = 8;        % paper width
FS = 12;        % fontsize
fig_name = [fname(1:13),'_',ObsTypeString,'_diffs.png'];
exportfig(1,fig_name,'width',pw,'height',ph,'fontmode','fixed', 'fontsize',FS,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');


%% plot the vertical profiles of the observations
fname = 'obs_diag_output.nc';  
copystring = 'observation'; 
plot_profile(fname,copystring);

%% plot the vertical profiles of the ensemble means
fname = 'obs_diag_output.nc';  
copystring = 'ens_mean';  
plot_profile(fname,copystring);


%% plot the vertical profiles of the ensemble spread
fname = 'obs_diag_output.nc';  
copystring = 'totalspread'; 
plotdat = plot_profile(fname,copystring);

%% plot rank histograms.

fname     = 'obs_diag_output.nc'; 
timeindex = -1;                    % all available timesteps. 
plot_rank_histogram(fname, timeindex);

%% plot the evolution of the RMSE and something else.
fname      = 'obs_diag_output.nc';   
copystring = 'totalspread';          
plot_rmse_xxx_evolution(fname,copystring);

copystring = 'spread';          
plot_rmse_xxx_evolution(fname,copystring);

%% plot vertical profiles of the RMSE and something else.
fname      = 'obs_diag_output.nc';   
copystring = 'spread';          
plot_rmse_xxx_profile(fname,copystring);



