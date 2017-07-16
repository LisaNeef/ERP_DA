function [VAR_out,lat_out,lon_out] = get_lat_lon_ave_DART_CAM(run,diagn,copystring,variable,level,GD,hostname)
%% get_lat_lon_mm_CAM_DART
% This function retrieves CAM-DART output fields and computes the 
% mean over a specified set of days, 
% of some diagnostic (prior/posterior ensemble mean, spread, or
% truth), returning a lat-lon field.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the corresponding
% mass/motion terms of AAM excitation.  
% In that case, the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Lisa Neef, 13 March 2011.
%
% MODS:
%  19 March 2012: instead of ABSPo-Tr, plot RMSE, where the average is over
%                 the time specified
%  20 March 2012: fix the way it flips through the files, so that only the dates
%                 we are interested in are counted.
%   9 Aug 2012: instead of specifying gregorian day limits in the inputs, just make GD
%               and array that we average over.
%
%--------------------------------------------------------------------------------------------


% INPUTS:
%clear all;
%run             = 'ERPALL_2001_noDA';
%copystring      = 'ensemble mean';   % 'ensemble mean' or 'ensemble spread'
%diagn           =  'RMSE';           % Prior, Posterior, Innov, Truth
%level           = 300;      % desired vertical level in hPa (for 3d vars only)
%variable        = 'U';
%GD		 = 146097:146100;
%hostname        = 'blizzard';


%% paths and other settings

% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
        % true state files are found on group storage.
	    if strcmp(diagn,'Truth')
           DART_output = '/work/bb0519/b325004/DART/ex/';
        end
    otherwise
      disp(['the filepaths and everything for hostname ',hostname,'  are not yet set.'])
      return
end


switch diagn
    case 'Truth'
        rundir = [DART_output,run,'/'];
        list = 'true_state_files';
        copystring = 'true state';
    case 'Prior'
        rundir = [DART_output,run,'/'];
        list = 'prior_state_files';
    case 'Posterior'
        rundir = [DART_output,run,'/'];
        list = 'posterior_state_files';
    case 'Innov'
        rundir = [DART_output,run,'/'];
        list = 'innov_state_files';
    case {'Po-Tr'}
        rundir = [DART_output,run,'/'];
        list = 'po_minus_tr_files';
        copystring = 'ensemble mean';
    case {'RMSE'}
        rundir = [DART_output,run,'/'];
        list = 'po_minus_tr_files';
        copystring = 'ensemble mean';
end



switch variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'VS';
end


% read in the list of needed files

if ~exist([rundir,list],'file')
    disp(['Cant find the file list ',rundir,list])
    return
else
    flist = textread([rundir,list],'%s');
end
nf = length(flist);

% load the first file to figure out the observation frequency
ff0 = [rundir,char(flist(1))];
tdum = nc_varget(ff0, 'time');
obs_per_day = length(tdum);
ndays = length(GD);
nt = ndays*obs_per_day;

%% set up arrays

t  = zeros(1,nt)+NaN;

ff0 = [rundir,char(flist(1))];

if strcmp(variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end

lon = nc_varget(ff0,'lon');
lev = nc_varget(ff0,'lev');

nlat = length(lat);
nlon = length(lon);

VAR = zeros(nlat,nlon);

% select the desired level.  Nonexistent for 2d variables.
if strcmp(variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= level, 1, 'last' );
end

%% Cycle through DART output files, and for the ones that fit the desired month, retrieve desired field

% weighting - just ones is AAM_weighting is 'none'
%W = eam_weights(lat,lon,AAM_weighting,variable);

k1 = 1;

for ifile = 1:nt
   ff = [rundir,char(flist(ifile))];
   tdum = nc_varget(ff, 'time');
   disp(tdum')
   if (tdum >= min(GD)) + (tdum <= max(GD))  + isfinite(tdum) == 3
       k2 = k1+length(tdum)-1;
       t(k1:k2) = tdum';
   
     
       %  find the right "copy".  for Po-Tr, it's just 1.
       var0 = nc_varget(ff,var_key);
       if strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE')
           copy = 1;
       else
           copy = get_copy_index(ff,copystring);
       end


       % choose the right "copy".  The dimensions are different for 3D and
       % 2D variables, and for single versus multiple obs times in one
       % file.
       if (length(tdum) > 1)
           switch variable
               case {'U','V'}
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr')|| strcmp(diagn,'RMSE')
                       var1 = squeeze(var0(:,:,:,ilev));  
                   else
                       var1 = squeeze(var0(:,copy,:,:,ilev));                     
                   end
               case 'PS'
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE')
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(:,copy,:,:));
                   end
           end           
       else
           switch variable
               case {'U','V'}
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr')|| strcmp(diagn,'RMSE')
                       var1 = squeeze(var0(:,:,ilev));  
                   else
                       var1 = squeeze(var0(copy,:,:,ilev));                     
                   end
               case 'PS'
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE')
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(copy,:,:));
                   end
           end
       end
       
       if strcmp(diagn,'RMSE')
           var2 = var1.^2;
       else
           var2 = var1;
       end
       
       if length(size(var2)) == 3
         for nn = 1:size(var2,1)
           VAR = VAR + (1/nt)*squeeze(var2(nn,:,:));
         end
       else
         VAR = VAR + (1/nt)*var2;
       end
       
       k1 = k2+1;
   end
end


%% if computing RMSE, still need to take the square root
if strcmp(diagn,'RMSE')
    VAR2 = sqrt(VAR);
else
    VAR2 = VAR;
end

%% output

VAR_out = double(VAR2);
lat_out = lat;
lon_out = lon;

