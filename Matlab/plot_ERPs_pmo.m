%% plot_PMO_obs_truth.m
%
%  For PMO experiments, compare the obs and truth evolving in time.
%
%  Started 17 Nov 2011
%----------------------------------------------------------------------

clear all;

%% User inputs
obs_file        = 'obs_epoch_001.nc';
rundir          = '/dsk/nathan/lisa/DART/ex/PMO_ERPALL_2001/';
fname           = [rundir,obs_file];
run_name        = 'Year 2001 Perfect Model Simulation';
 
ObsTypeString = 'ERP_LOD';
region        = [0 360 -90 90 -Inf Inf];
QCString      = 'Quality Control';
maxgoodQC     = 2;
verbose       = 1;   % anything > 0 == 'true'

%% Read shit in

obs = read_obs_netcdf(fname, ObsTypeString, region, ...
                    'observations', QCString, verbose);

truth = read_obs_netcdf(fname, ObsTypeString, region, ...
                    'observations', QCString, verbose);



%% Conversion to equivalent Earth rotation units

aam_constants_gross;

switch ObsTypeString
    case {'ERP_PM1'}
        fac = rad2mas;
        YL = '\chi_1 (mas)';
    case {'ERP_PM2'}
        fac = rad2mas;
        YL = '\chi_2 (mas)';
    case 'ERP_LOD'
        fac = LOD0_ms;
        YL = '\chi_3 (ms)';
end

pmo = fac*detrend(obs.obs,'constant');

%% if desired, load a real AAM series for comparison

[Xw,Xm,mjd] = read_EFs('aam','ERAinterim',1);  
[y_ERA,m_ERA,d_ERA] = mjd2date(mjd);
t_era = zeros(1,length(mjd));
for ii = 1:length(mjd)
   t_era(ii) = datenum(y_ERA(ii),m_ERA(ii),d_ERA(ii)); 
end

X = Xw+Xm;
switch ObsTypeString
    case {'ERP_PM1'}
        era = rad2mas*X(1,:);
         ylim = 150*[-1 1];
   case {'ERP_PM2'}
        era = rad2mas*X(2,:);
        ylim = 150*[-1 1];
    case 'ERP_LOD'
        X3 = squeeze(X(3,:));
        era = LOD0_ms*detrend(X3);
        ylim = [-1 1];
end
    
% compute interannual mean and standard deviation
y_era_min = min(y_ERA);
y_era_max = max(y_ERA);
n_years_era = y_era_max - y_era_min;
era_yearly = zeros(n_years_era,366)+NaN;
years = y_era_min+1:y_era_max;

for iy = 1:n_years_era
    pp = find(y_ERA == years(iy));
    era_yearly(iy,1:length(pp)) = era(pp) ;   
end
era_mean = nanmean(era_yearly);
era_std  = nanstd(era_yearly);

% also, select the year that we are interested in

dum = obs.timestring(1,:);
year = dum(8:11);

Y = y_era_min:1:y_era_max;
selyear = find(Y == eval(year));
era_select = squeeze(era_yearly(selyear,:));

%% Plot that shit!

LW = 2;
eracolor =     [0.3922    0.6555    0.1712];
obscol = zeros(1,3);

tmin = datenum(2000,01,01);
tmax = tmin+365;
t_year = tmin:tmax;

transparency = 0.3;

figure(1),clf
set(gcf,'Position',[54 554 1064 406])
  era_spread = jbfill(t_year,era_mean+era_std,era_mean-era_std,eracolor,ones(1,3),1,transparency);
  hold on
 % eraplot = plot(t_year,era_mean,'LineWidth',LW,'Color',eracolor);
  eraselect = plot(t_year,era_select,'LineWidth',LW,'Color',eracolor);
  pmoplot = plot(obs.time,pmo,'LineWidth',LW,'Color',obscol);
 % ylim = get(gca,'YLim');
  ylabel(YL)
  axis([tmin tmax ylim(1) ylim(2)])
  grid on
  lhandle = [pmoplot(1), eraselect(1),  era_spread(1)];
  legend(lhandle, 'CAM','ERA-Int 2000','ERA-Interim')
  datetick('x','dd-mmm','keeplimits')
  title(run_name)  

%% Plot export

fig_name = [rundir,'PMO_',ObsTypeString,'_compERA.png'];

LW = 2;
ph = 6;        % paper height
pw = 17;        % paper width
fs = 20;        % fontsize

exportfig(1,fig_name,'width',pw,'height',ph,'fontmode','fixed', 'fontsize',fs,'color','cmyk','LineMode','fixed','LineWidth',LW,'format','png');





  
  