function compute_corr_instantaneous(dart_run,day_prefix,N,variable,aef,days)   
%% compute_corr_instantaneous.m
%
%  Cycle through DART no-DA run and use the ensemble to compute instantaneous correlations between state
%  variables and a global AAM component.
%  This generates a netcdf file containing the correlation between the desired state variable and AEF.
%
%  Lisa Neef, 5 June 2012
%----------------------------------------------


%% Temporary Inputs:
%clear all;
%clc;
%dart_run = 'ERPALL_2001_noDA';
%day_prefix = 'ERPALL_N64_noDA_';
%N = 64;
%variable = 'U';
%aef      = 'X1';
%day0     = 146097;
%dayf     = 146097;
%days = day0:1:dayf;

ndays = length(days);

%% Read in a sample field to get dimensions

rundir = ['/work/scratch/b/b325004/DART_ex/',dart_run];
storagedir = ['/work/bb0519/b325004/DART/ex/',dart_run];

day0 = days(1);
ff0 = [rundir,'/',day_prefix,num2str(day0),'/DART/Posterior_Diag.nc'];

if ~strcmp(variable,'PS')
  lev = nc_varget(ff0,'lev');
else
  lev = NaN;
end
lon = nc_varget(ff0,'lon');
if strcmp(variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end


nlev = length(lev);
nlat = length(lat);
nlon = length(lon);

% find the copy where the individual ensemble members start
ens_start = get_copy_index(ff0,'ensemble member 1');

switch variable
  case 'U'
    var_to_get = 'US';
  case 'V'
    var_to_get = 'VS';
  case 'PS'
    var_to_get = 'PS';
end


%% Cycle through days and compute correlations

for iday = 1:ndays

  disp(days(iday));

  %% Initialize array that holds the correlation
  if strcmp(variable,'PS')
    R = zeros(nlon,nlat)+NaN;
  else
    R = zeros(nlon,nlat,nlev)+NaN;
  end

  % define the file to be retrieved.
  ff = [rundir,'/',day_prefix,num2str(days(iday)),'/DART/Posterior_Diag.nc'];

  % retrieve N copies of the variable in question    
  vv = nc_varget(ff,var_to_get);;
  if strcmp(variable,'PS')
    VAR = vv(ens_start:N+ens_start-1,:,:);
  else
    VAR = vv(ens_start:N+ens_start-1,:,:,:);
  end

  % compute 64 samples of the desired excitation function
  X = zeros(1,N);
  for iens = 1:N
    if strcmp(variable,'PS')
      VARens = squeeze(VAR(iens,:,:));
    else
      VARens = squeeze(VAR(iens,:,:,:));
    end
    X(iens) = compute_aef_per_field(VARens,lat,lon,lev,variable,aef);
  end

  % compute the correlation between each point and the global EF
  for ilat = 1:nlat
    for ilon = 1:nlon 
      if strcmp(variable,'PS')
        R(ilon,ilat) = corr(VAR(:,ilat,ilon),X');
      else
        for ilev = 1:nlev
          R(ilon,ilat,ilev) = corr(VAR(:,ilat,ilon,ilev),X');
        end
      end
    end
  end

  %% export this correlation map in a netcdf file.
  
  % create the nc file
  foutname = [storagedir,'/correlation_',variable,'_',aef,'_',num2str(days(iday)),'.nc'];
  nc = netcdf.create(foutname,'clobber')

  % define the dimensions
  lat_dimid = netcdf.defDim(nc,'lat',nlat);
  lon_dimid = netcdf.defDim(nc,'lon',nlon);
  lev_dimid = netcdf.defDim(nc,'lev',nlev);
  t_dimid = netcdf.defDim(nc,'time',1);
  dimids = [lon_dimid,lat_dimid,lev_dimid,t_dimid];

  % define the correlation variable
  varid_R = netcdf.defVar(nc,'CORR','float',dimids);
    netcdf.putAtt(nc,varid_R,'long_name',['Correlation between local ',variable,' and ',aef])
  varid_lat = netcdf.defVar(nc,'lat','float',lat_dimid);
    netcdf.putAtt(nc,varid_lat,'long_name','Latitude')
    netcdf.putAtt(nc,varid_lat,'units','degrees_north')
  varid_lon = netcdf.defVar(nc,'lon','float',lon_dimid);
    netcdf.putAtt(nc,varid_lon,'long_name','Longitude')
    netcdf.putAtt(nc,varid_lon,'units','degrees_east')
  varid_lev = netcdf.defVar(nc,'lev','float',lev_dimid);
    netcdf.putAtt(nc,varid_lev,'long_name','Pressure Level')
    netcdf.putAtt(nc,varid_lev,'units','hPa')
  varid_t = netcdf.defVar(nc,'time','double',t_dimid);
    netcdf.putAtt(nc,varid_t,'long_name','time')
    netcdf.putAtt(nc,varid_t,'axis','T')
    netcdf.putAtt(nc,varid_t,'cartesian_axis','T')
    netcdf.putAtt(nc,varid_t,'calendar','gregorian')
    netcdf.putAtt(nc,varid_t,'units','days since 1601-01-01 00:00:00')

  % end the define mode.
  netcdf.endDef(nc);

  % write the data to the file.
  netcdf.putVar(nc,varid_R,R); 
  netcdf.putVar(nc,varid_lat,lat); 
  netcdf.putVar(nc,varid_lon,lon); 
  netcdf.putVar(nc,varid_lev,lev); 
  netcdf.putVar(nc,varid_t,days(iday)); 

  % close the file.
  netcdf.close(nc);
end
