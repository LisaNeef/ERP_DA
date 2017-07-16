function plot_lat_lon_ave(run,noDA,diagn,copystring,variable,level,GD,hostname)
%% plot_lat_lon_daily.m
%
% Make a 2-D plot of the DART-CAM state, averaged over certain days.
%
% Lisa Neef, 13 Mar 2012.
%
% INPUTS:
%   run
%   noDA: the corresponding no-DA run -- can leave blank if not ploting ER (error reduction)
%   copystring
%   diagn: Choose Prior, Posterior, RMSE (=posterior true error), or ER (=true error relative to 
%     no-DA case - we want this to be negative.)
%   variable
%   level
%   GD: array of gregorian dates over which we average.
%   hostname
%
% MODS:
%  19 March 2012: instead of ABSPo-Tr, plot RMSE, where the average is over
%  the time specified
%   4 June 2012: adjust the axis limits so that spread and RMSE have the same.
% 		also get a better set of color limits for surface pressure.
%   9 Aug 2012: make it possible to plot the prior or posterior RMSE with respect
%               to a corresponding no-DA case
%               This is done by loading those runs separately, taking the diff, and 
%               then averaging.
%   9 Aug 2012: instead of specifying gregorian day limits in the inputs, just make GD
%               and array that we average over.
%---------------------------------------------------------------------------------------
%
%clear all;
%clc;
%%run             = 'ERP1_2001_N64_UVPS';
%noDA		= 'ERPALL_2001_noDA';
%copystring      = 'ensemble mean';   % 'ensemble mean' or 'ensemble spread'
%diagn           =  'ER';           % Prior, Posterior, Innov, Truth, RMSE, or ER 
%level           = 300;      % desired vertical level in hPa (for 3d vars only)
%variable        = 'U';
%AAM_weighting   = 'none';           % apply weighting for given AAM component.
%GD		= 146097:146153;
%hostname        = 'blizzard';


%% other paths, etc.

if strcmp(diagn,'Truth')
    copystring = 'true state';
end

%% Fetch or compute the average of the desired diagnostic for the desired run.

if strcmp(diagn,'ER')
  [~,lat,lon] = get_lat_lon_daily_DART_CAM(run,'RMSE',copystring,variable,level,'none',GD(1),hostname);
  VAR_long = zeros(length(lat),length(lon),length(GD));
  for iday = 1:length(GD) 
    % get the posterior true error for the run in question, over the desired dats
    [V,lat,lon] = get_lat_lon_daily_DART_CAM(run,'RMSE',copystring,variable,level,'none',GD(iday),hostname);
    % get the posterior true error for the corresponding no-DA run
    [V_noDA,lat_noDA,lat_noDA] = get_lat_lon_daily_DART_CAM(noDA,'RMSE',copystring,variable,level,'none',GD(iday),hostname);

    % the retrieved values are actually just the error, not the RMSE.
    % here we aren't interested in averaging, just in the absolute value distance to the truth per point --
    % so take the diff between absolute values here to get a measure of error reduction.

    VAR_long(:,:,iday) = abs(V)-abs(V_noDA);
  end
  % now average this field over the desired days
  VAR = mean(VAR_long,3);

else

  % if looking at a different field, simply retrieve the average.
  [VAR,lat,lon] = get_lat_lon_ave_DART_CAM(run,diagn,copystring,variable,level,GD,hostname);

end


%---temp
%fig_name = 'temp_lat_lonplot.png';
%figH = figure('visible','off') ;
%ph = 20;
%pw = 20;
%---temp


%% Plot settings
ncontours = 11;

% also shift the lons over to get it right for the map 
% (lons should go -180 to 180)
if min(lon) <= 0
  dum = find(lon > 180);
  lon2=lon;
  lon2(dum) = -(360 - lon(dum));
  [a,b] = sort(lon2);
  lon = a;
end

cmap1 = jet(ncontours);  % straight colormap
cmap2 = cmap1;
cmap2(round(ncontours/2),:) = ones(1,3);  % colormap with center zero

cmap = cmap2;


% if looking at the spread and not innovation, dont allow for negative values
if strcmp(copystring,'ensemble spread') && ~strcmp(diagn,'Innov') 
  cmap = seq_yellow_green_blue9;
end

% same goes for if looking at the RMS error
if strcmp(diagn,'RMSE')  
  cmap = seq_yellow_green_blue9;
end


% for ER (error relative to no-DA case), want a diverging color scheme
if strcmp(diagn,'ER')
  cmap = flipud(div_red_yellow_blue11);
  cmap(6,:) = ones(1,3);
end

%% Plots!

  %ax = axesm('MapProjection','eqdcylin','grid','on',...
  %    'MeridianLabel','on','ParallelLabel','on',...
  %    'PLabelLocation',30,'MLabelLocation',90);
  contourf(lon,lat,VAR(:,b),ncontours,'LineStyle','none');
  hold on
  colormap(cmap)
  c = load('coast');
  plot(c.long,c.lat,'Color','black','LineWidth',1);

  box off



% adjust color axis and add color bar.
switch variable
  case 'U'
      cmax = 50;
    case 'V'
        cmax = 50;
  case 'PS'
      cmax = 2500;
      %clim = get(gca,'Clim');
      %cmax = max(clim);
end

if strcmp(diagn,'RMSE') 
    caxis(cmax*[0,1]);
end

if strcmp(copystring,'ensemble spread') && ~strcmp(diagn,'Innov') 
    caxis(cmax*[0,1]);
end

% for relative error reduction, for now just make the axis symmetric.
if strcmp(diagn,'ER')
  cax = get(gca,'Clim');
  set(gca,'Clim',max(cax)*[-1,1])
end

%colorbar('horiz','OuterPosition',[dx dy w hbar]);
%colorbar('horiz')
colorbar

% plot labels
ylim = get(gca,'YLim');
xlim = get(gca,'XLim');
dxlim = xlim(2)-xlim(1);
dylim = ylim(2)-ylim(1);

if strcmp(diagn,'RMSE')
    textstring = [diagn,' ',variable,num2str(level)];
else
    textstring = [diagn,' ',copystring,' ',variable,num2str(level)];
end

%if strcmp(diagn,'Truth'), textstring = 'Truth'; end
%if strcmp(run,'ERA-Interim'), textstring = 'ERA-Interim'; end
%text(xlim(1)+.05*dxlim,ylim(1)+0.1*dylim,textstring,'FontSize',16,'Color',zeros(1,3))


%% Other Plot adustments

      set( gca                       , ...
          'FontName'   , 'Helvetica' ,...
          'Box'         , 'off'     , ...
          'XGrid'        , 'on'      , ...
          'YGrid'        , 'on'      , ...
          'TickDir'     , 'out'     , ...
          'TickLength'  , [.02 .02] , ...
          'XColor'      , [.3 .3 .3], ...
          'YColor'      , [.3 .3 .3], ...
          'XTick'       , [-180:50:180], ...
          'YTick'       , [-90:30:90], ...          
          'LineWidth'   , 1         );

%---temp plot export
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp plot export




