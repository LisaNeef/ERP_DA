%% make_radiosonde_grid_plot.m
%
%  Make  plot of the locations of the radiosonde obseervations, vertically and horizontally
%  radiosonde observations.
%
%  Lisa Neef, 24 April 2013
%
%------------------------------------------

%% file paths and stuff
rundir = '/work/scratch/b/b325004/DART_ex/RADIOSONDE_SYNTHETIC_2009/Exp2/';

%% inputs to the plotting function:
obs 		= 'RADIOSONDE_U_WIND_COMPONENT';
fname         = [rundir,'/postprocess/obs_epoch_002.nc'];
region        = [0 360 -90 90 -Inf Inf];
CopyString    = 'observations';
QCString      = 'Quality Control';
maxgoodQC     = 0;
verbose       = 0;   % > 0 means 'print summary to command window'

% plot here
figure(1),clf
  plot_obs_netcdf2(fname, obs, region, CopyString, QCString, maxgoodQC, verbose, 0);


% export this figure
pw = 15;
ph = 6;
set(gcf, 'PaperUnits','inches')
set(gcf, 'Units','inches')
set(gcf, 'PaperSize', [pw ph]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 pw ph]);
set(gcf, 'renderer', 'painters');
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])

fig_name = 'radiosondes_horizgrid.png';
fs = 1.5;
exportfig(1,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)

