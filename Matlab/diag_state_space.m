%% Collection of code calls for various state-space diagnostics.

clear all;

%% set file paths and stuff.

addpath('/home/ig/neef/MFiles/DART/')
addpath('/home/ig/neef/MFiles/utilities/')
addpath('/home/ig/neef/MFiles/netcdf/mexcdf/snctools/')
addpath('/home/ig/neef/MFiles/netcdf/mexcdf/mexnc/','-BEGIN')
addpath('/home/ig/neef/DART/trunk/matlab')




%% Compare the evolution of the ensemble and the ensemble mean.
% truth_file = 'True_State.nc';
diagn_file = 'Posterior_Diag.nc';
plot_ens_time_series



%% Plot state variable trajectories with emphasis on the increments.

% truth_file = 'True_State.nc';
diagn_file = 'Posterior_Diag.nc';
plot_ens_time_series

LW = 1;
ph = 12;        % paper height
pw = 8;        % paper width
FS = 12;        % fontsize
fig_name = 'snapshot_ens_time_series.png';
exportfig(1,fig_name,'width',pw,'height',ph,'fontmode','fixed', 'fontsize',FS,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');




%% -------------the below codes require a true state-----------------------


%% Compare evolution of error and ensemble spread in all variables.

 truth_file = 'True_State.nc';
diagn_file = 'Posterior_Diag.nc';
plot_total_err

%% Plot rank histograms of the state variables.

 truth_file = 'True_State.nc';
 diagn_file = 'Prior_Diag.nc';
 plot_bins
