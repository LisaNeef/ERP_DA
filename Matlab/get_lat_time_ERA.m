function [VAR_out,t_out,lat_out] = get_lat_time_ERA(dataset,year,variable,level,AAM_weighting)
%
% Compute the evolution of state variables in ERA data 
% as a function of latitude and time.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Then these can be plotted by the program plot_lat_time.m
%
% Lisa Neef, 30 Nov 2011
%
% sample inputs
%dataset         = 'ERAinterim';
%year            = '2000';
%level           = 300;      % desired vertical level in hPa (for 3d vars only)
%variable        = 'U';
%AAM_weighting   = 'none';           % apply weighting for given AAM component.
%----------------------------------------------------------------------



%% Other Path Names

datadir = '/dsk/nathan/lisa/ERAinterim/nc/uvps/';

%% Initialize Arrays

switch variable
    case 'U'
        file_key = '131';
        var_key  = 'var131';
    case 'PS'
        file_key = '152';
        var_key  = 'var152';
end

if strcmp(year,'ALL')
    flist = dir([datadir,'eia6_*',file_key,'*.nc']);
else
    flist = dir([datadir,'eia6_',year,'.',file_key,'*.nc']);    
end

nf = size(flist,1);

ff0 = [datadir,flist(1).name];
lat = nc_varget(ff0,'lat');
lon = nc_varget(ff0,'lon');
lev = nc_varget(ff0,'lev');

rlon = lon*pi/180;

var0  = nc_varget(ff0,var_key);

nlev = length(lev);
nlat = length(lat);
nlon = length(lon);

nt = size(var0,1);
VAR = zeros(nlat,nf*nt)+NaN;
t_era = zeros(1,nf*nt)+NaN;

ilev = find(lev <= level*100, 1, 'last' );  % factor 100 here bc ERA levels are in Pa.



%% Cycle through datasets and collect zonal wind and time arrays


W = eam_weights(lat,lon,AAM_weighting,variable);

k1 = 1;

for ii = 1:nf
    ff = [datadir,flist(ii).name];
    tdum = nc_varget(ff, 'time');
    k2 = k1+length(tdum)-1;
    t_era(k1:k2) = tdum;
    
    var0 = nc_varget(ff,var_key);
    var1 = zeros(length(tdum),nlat,nlon);

    switch variable
        case 'U'
            for kk = 1:length(tdum)
                var1(kk,:,:) = W'.*squeeze(var0(kk,ilev,:,:));
            end
        %VAR(:,k1:k2) = squeeze(nanmean(var1,3))';
        case 'PS'
            for kk = 1:length(tdum)
               var1(kk,:,:) = W'.*squeeze(var0(kk,:,:));
            end
    end
    
    % choose whether to integrate zonally, or just average.
    switch AAM_weighting
        case {'X1','X2','X3'}
            VAR(:,k1:k2) = squeeze(trapz(rlon,var1,3))';
        case 'none'
            switch variable
                case {'U','V'}
                    VAR(:,k1:k2) = nanmean(var1,3)';
                case {'PS'}
                    % (convert PS from ???? to hPa)
                    VAR(:,k1:k2) = 1000*nanmean(var1,3)';
            end
    end
    
    k1 = k2+1;
end

top = find(isfinite(t_era) == 1, 1, 'last' );
VAR = VAR(:,1:top);

%% Scaling the computed array:

% (1) f: convert units to equivalent ERP variations.
%     (W and f should come out as 1's if no weighting is specified)
% (2) for surface pressure, look at the anomaly with respect to the annual
%      mean.  Also convert to hPa.


f = eam_prefactors(AAM_weighting,variable);

aam_constants_gross
switch AAM_weighting
    case {'X1','X2'}
        f2 = rad2mas*f;
    case 'X3'
        f2 = LOD0_ms*f;
    case 'none'
        f2 = f;
end

% to detrend or not to detrend?
switch AAM_weighting
    case {'X1','X2','X3'}
        VAR3 = f2*detrend(VAR','constant')';
    case 'none'
        switch variable
            case {'U','V'}
                VAR3 = f2*VAR;
            case 'PS'
                VAR3 = f2*detrend(VAR','constant')';
        end
end




%% Adjust the time to something Matlab can deal with.

% note that ERA-Interim time is hours since 1989-01-01

t_era_days = t_era(1:top)/24;     
t   =  t_era_days+datenum(eval(year),1,1,0,0,0);


%% prepare outputs

VAR_out = VAR3;
t_out = t;
lat_out = lat;
  
  
  