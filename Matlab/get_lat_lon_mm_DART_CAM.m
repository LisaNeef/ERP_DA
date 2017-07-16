function [VAR_out,lat_out,lon_out] = get_lat_lon_mm_DART_CAM(exp,diagn,copystring,variable,level,AAM_weighting,month)
%% get_lat_lon_mm_CAM_DART
% This function retrieves CAM-DART output fields and computes the monthly
% mean of some diagnostic (prior/posterior ensemble mean, spread, or
% truth), returning a lat-lon field.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the corresponding
% mass/motion terms of AAM excitation.  
% In that case, the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Lisa Neef, 16 December 2011.
%
% INPUTS:
%exp             = 'ERPALL_2000';
%copystring      = 'ensemble mean';   % 'ensemble mean' or 'ensemble spread'
%diagn           =  'Prior';           % Prior, Posterior, Innov, Truth
%level           = 300;      % desired vertical level in hPa (for 3d vars only)
%variable        = 'U'
%AAM_weighting   = 'none';           % apply weighting for given AAM component.
%month           = 2;         % number of desired month.

%% paths and other settings

DART_output = '/dsk/nathan/lisa/DART/ex/';


switch diagn
    case 'Truth'
        rundir = [DART_output,'PMO_',exp,'/'];
        list = 'true_state_files';
    case 'Prior'
        rundir = [DART_output,exp,'/'];
        list = 'prior_state_files';
    case 'Posterior'
        rundir = [DART_output,exp,'/'];
        list = 'posterior_state_files';
    case 'Innov'
        rundir = [DART_output,exp,'/'];
        list = 'innov_state_files';
end



switch variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'V';
end

% read in the list of needed files

if ~exist([rundir,list],'file')
    disp(['Cant find the file list ',rundir,list])
    return
else
    flist = textread([rundir,list],'%s');
end
nf = length(flist);

%% Deduce Gregorian dates in desired month.

parts = regexp(exp,'_','split');
year  = eval(char(parts(2)));

refday_mjd = date2mjd(1601,1,1,0,0,0);
day0 = date2mjd(year,month,1,0,0,0)-refday_mjd;

% the final day of this month of course depends on the length of the
% month...
switch month
    case {1,3,5,7,8,10,12}
        dayf = date2mjd(year,month,31,0,0,0)-refday_mjd;
    case {4,6,9,11}
        dayf = date2mjd(year,month,30,0,0,0)-refday_mjd;
    case {2}
        % ignoring 29 Feb since NO_LEAP calendar was used in CAM.
        dayf = date2mjd(year,month,28,0,0,0)-refday_mjd;
end
   
ndays = dayf-day0+1;


%% set up arrays

t  = zeros(1,ndays)+NaN;

ff0 = [rundir,char(flist(1))];

if strcmp(variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end

lon = nc_varget(ff0,'lon');
rlon = lon*pi/180;
lev = nc_varget(ff0,'lev');

nlat = length(lat);
nlon = length(lon);

VAR = zeros(nlat,nlon,ndays)+NaN;

% select the desired level.  Nonexistent for 2d variables.
if strcmp(variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= level, 1, 'last' );
end

%% Cycle through DART output files, and for the ones that fit the desired month, retrieve desired field

% weighting - just ones is AAM_weighting is 'none'
W = eam_weights(lat,lon,AAM_weighting,variable);
ii = 1;

for ifile = 1:nf
   ff = [rundir,char(flist(ifile))];
   tdum = nc_varget(ff, 'time');

   % is the file part of the month we are interested in?
   if isfinite(tdum)
     if (tdum >= day0 && tdum <= dayf)
   
       t(ii) = tdum;
       
       % load the variables.
       var0 = nc_varget(ff,var_key);
       copy = get_copy_index(ff,copystring);         

       % get the horizontal variable field at the desired level.
       % note that for prior and posterior, they have an extra dimension,
       % the "copy"
       switch variable
           case {'U','V'}
               if strcmp(diagn,'Truth')
                   var1 = W'.*squeeze(var0(:,:,ilev));  
               else
                   var1 = W'.*squeeze(var0(copy,:,:,ilev));                     
               end
           case 'PS'
               if strcmp(diagn,'Truth')
                   var1 = W'.*var0;  
               else
                   var1 = W'.*squeeze(var0(copy,:,:));
               end
       end
       
       
       VAR(:,:,ii) = var1;
       ii = ii+1 ;     
     end
   end
end

%% now the output is the mean over this month.

VAR_out = nanmean(VAR,3);
lat_out = lat;
lon_out = lon;

