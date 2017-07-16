% Umbrella code to generate daily plots of a given variable, plotting
% truth, prior mean, prior spread, posterior mean, posterior spread.
%
% Lisa Neef, 21 Dec 2011


%% User inputs
clear all;

run             = 'ERPALL_2001_N64';
year            = '2000';
variable        = 'U';
level           = 300;
AAM_weighting   = 'none';

GD_start           = 146097;
GD_stop           = 146103;



% cycle through and make the plots.

for GD = GD_start:GD_stop
    disp(GD)
    figure(1),clf
      plot_lat_lon_daily(run,'Truth','true state',year,variable,level,GD)
    figure(2),clf
      plot_lat_lon_daily(run,'Prior','ensemble mean',year,variable,level,GD)
    figure(3),clf
      plot_lat_lon_daily(run,'Prior','ensemble spread',year,variable,level,GD)
    figure(4),clf
      plot_lat_lon_daily(run,'Posterior','ensemble spread',year,variable,level,GD)    
end


