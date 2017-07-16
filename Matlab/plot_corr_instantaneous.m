 function plot_corr_instantaneous(dart_run,day_prefix,N,variable,aef,level,day)
% 
% make a 2-D plot of the correlations between model variables at a given level,
% and some given AEF.
%
% Lisa Neef, 6 June 2012


%% temp inputs
%clear all;
%clc;
%dart_run = 'ERPALL_2001_noDA';
%day_prefix = 'ERPALL_N64_noDA_';
%N = 64;
%variable = 'U';
%aef = 'X1';
%level = 300;
%day = 146097;


%% retrieve the correlation file

datadir = ['/work/bb0519/b325004/DART/ex/',dart_run];
ff = [datadir,'/correlation_',variable,'_',aef,'_',num2str(day),'.nc'];

lat = nc_varget(ff,'lat');
lon = nc_varget(ff,'lon');
if ~strcmp(variable,'PS')
  lev = nc_varget(ff,'lev');
else
 lev = NaN;
end

R = nc_varget(ff,'CORR');

%% take out the level slice that we want

if ~strcmp(variable,'PS')
  ilev = find(lev <= level, 1, 'last' );
  R2 = squeeze(R(ilev,:,:));
else 
  R2 = R;
end

%% plot settings

% also shift the lons over to get it right for the map
% (lons should go -180 to 180)
if min(lon) <= 0
  dum = find(lon > 180);
  lon2=lon;
  lon2(dum) = -(360 - lon(dum));
  [a,b] = sort(lon2);
  lon = a;
end

cmap = div_red_yellow_blue11;


%% plot on a map

  contourf(lon,lat,R2(:,b),11,'LineStyle','none');
  hold on
  colormap(cmap)
  c = load('coast');
  plot(c.long,c.lat,'Color','black','LineWidth',1);

  caxis(0.8*[-1,1])
  box off
  colorbar






