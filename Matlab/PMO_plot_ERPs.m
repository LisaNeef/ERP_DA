%% PMO_plot_ERPs.m
%
%  Make a plot of the ERPs produced from DART-PMO.
%
%  started 6 Oct 2011


%% Inputs, etc.

clear all;

datadir = '/dsk/nathan/lisa/DART/ex/ERP_PMO_Feb1979/PMO/obs_0001/';
ff = dir([datadir,'obs_epoch*']);


ObsTypeString= 'ERP_PM1';
region= [0 360 -90 90 -Inf Inf];

aam_constants_gross

%% Initialize Arrays.

X1 = zeros(365,1)+NaN;
X2 = X1;
X3 = X1;
GD = X1;

%% The meat.

nf = length(ff);
k1 = 1;

if nf == 0, disp('cant find the obs epoch files!'), return, end

for ii = 1:nf
    
    % retrieve observations as a structure
    fname = ff(ii).name;
    dum1 = read_obs_netcdf(fname, 'ERP_PM1', region, 'observations', 'Quality Control', 0);
    dum2 = read_obs_netcdf(fname, 'ERP_PM2', region, 'observations', 'Quality Control', 0);
    dum3 = read_obs_netcdf(fname, 'ERP_LOD', region, 'observations', 'Quality Control', 0);
    n = length(dum1.obs);
    k2 = k1+n;
    X1(k1:k2) = rad2mas*dum1.obs;
    X2(k1:k2) = rad2mas*dum2.obs;
    X3(k1:k2) = LOD0_ms*dum3.obs;
    GD(k1:k2) = dum1.time;
    
    % set counter forward.
    k1 = k2+1;
end

X1 = X1(isfinite(X1));
X2 = X2(isfinite(X2));
X3 = X3(isfinite(X3));
GD = GD(isfinite(GD));

%% Plot settings

LW = 2;

%% Plot!

figure(1),clf
subplot(1,3,1)
    plot(GD,X1,'o-','LineWidth',LW,'Color',rand(1,3))
    xlabel('Gregorian Date')
    ylabel('\chi_1 (mas)')
    
    
subplot(1,3,2)
    plot(GD,X2,'o-','LineWidth',LW,'Color',rand(1,3))
    xlabel('Gregorian Date')
    ylabel('\chi_2 (mas)')
    
subplot(1,3,3)
    plot(GD,X3,'o-','LineWidth',LW,'Color',rand(1,3))
    xlabel('Gregorian Date')
    ylabel('\chi_3 (ms)')
    
   
    


