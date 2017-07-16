function plot_innov_dist_to_truth(run,variable,level,GD,hostname)
%% plot_innov_dist_to_truth.m
%  make a plot of the innovation in the distance to the truth, 
%  either for a specific day, or an average over a set of days.
%
%  Lisa Neef, 31 July 2012
%
%  INPUTS:
%    run = the name of the DART run
%    variable = the variable we are interested in.  Currently only 'U','V' and 'PS' are supported.
%    level = the approximate vertical level we want, in hPa
%    GD = either a single Gregorian Date, or an array of dates that we want to average over.
%    hostname = the computer.  Presently only supporting 'blizzard'
%
%
%  OUTPUTS:
%
%  MODS:
%
%--------------------------------------------------------------------------------------------------


%% temporary inputs
%clear all;
%clc;
%run             = 'ERP1_2001_N64_UVPS';
%variable        = 'U';
%level           = 300;
%GD              = 146097:1:146100;
%hostname        = 'blizzard';

% load the arrays
[D_in,lat,lon] = get_innov_dist_to_truth(run,variable,level,GD,hostname);

if length(GD) > 1
  D = mean(D_in,3); 
else
  D = D_in;
end



%% some plot settings

% shift the lons over to get it right for the map
% (lons should go -180 to 180)
if min(lon) <= 0
  dum = find(lon > 180);
  lon2=lon;
  lon2(dum) = -(360 - lon(dum));
  [a,b] = sort(lon2);
  lon = a;
end

% load a color map
cmap = div_red_yellow_blue11;


%% plot on a map

  contourf(lon,lat,D(:,b),11,'LineStyle','none');
  hold on
  colormap(cmap)
  c = load('coast');
  plot(c.long,c.lat,'Color','black','LineWidth',1);

% make the color axis even
cax = get(gca,'Clim');
caxis(max(cax)*[-1,1]);

  box off
  colorbar

