function [ENS_out,t_out,lat,lon,lev] = get_ensemble_in_time(E,hostname,ave_over_region)
%
% Retrieve the entire ensemble for some experiment and state space range
% defined in the structure E (see load_experiments.m)
%
% Note that if E.diagn = Truth, we retrieve the truth state rather than the ensemble
%
% Lisa Neef, 8 Oct 2013
%
% INPUTS:
%  E: structure defining the experiments (see load_experiments.m)
%  hostname: currently only 'blizzard'
%  ave_over_region: set to 1 to average over the region specified in E,
%	zero to return the state over that region
% MODS:
%  18 Oct 2013: add the option of returning either an average over the 
%	specified region, or just the entire state over that region.
%  21 Oct 2013: make the lat, lon and lev arrays output variables as well
%-----------------------------------------------------------------------------


%% temporary inputs if not running as a function:
%clear all; clf;
%EE = load_experiments;
%E = EE(3);
%E.latrange = [-90,90];
%E.lonrange = [0,360];
%E.levrage = [1000,0];
%E.variable = 'U';
%hostname = 'blizzard';
%E.diagn = 'Posterior';
%E.dayf = E.day0;
%ave_over_region = 0;

%% where to find DART output
%switch hostname
%    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
%end

if strcmp(E.diagn,'Truth')
  rundir = [DART_output,E.truth,'/'];
else
  rundir = [DART_output,E.run_name,'/'];
end

%% which variables to look for
switch E.variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'VS';
    case 'T'
        var_key = 'T';
    case 'Q'
        var_key = 'Q';
    case 'CLDIQ'
        var_key = 'CLDIQ';
    case 'CLDICE'
        var_key = 'CLDICE';
end

%% change the diagnostic if it was left at RMSE, which doesn't work
if strcmp(E.diagn,'RMSE')
  disp('Dont currently have ensemble copies of the RMSE, just the ensemble mean.')
  disp('Loading the posterior instead of the error.')
  E.diagn = 'Posterior';
end

%% which files to look in
switch E.diagn
  case 'Innov'
    fstring = 'Innov.nc';
  case 'Prior'
    fstring = 'Prior_Diag.nc';
  case 'Posterior'
    fstring = 'Posterior_Diag.nc';
  case 'Truth'
    fstring = 'True_State.nc';
end


%% load the first file to get the right grid
ndays = E.dayf-E.day0+1;

ff0 = [rundir,'obs_0001/',fstring];
if exist(ff0,'file') ~= 2
  disp(['Cannot find the following output file: ',ff0]);
  return
end


%% figure out the desired latitude, longitude, and level ranges to average over
if strcmp(E.variable,'U')
    lat2 = nc_varget(ff0,'slat');
else
    lat2 = nc_varget(ff0,'lat');
end
lon2 = nc_varget(ff0,'lon');
lev2 = nc_varget(ff0,'lev');

y1 = find(lat2 >= E.latrange(1),1,'first');
y2 = find(lat2 <= E.latrange(2),1,'last');
x1 = find(lon2 >= E.lonrange(1),1,'first');
x2 = find(lon2 <= E.lonrange(2),1,'last');
z1 = find(lev2 >= E.levrange(2),1,'first');
z2 = find(lev2 <= E.levrange(1),1,'last');

%% query the ensemble size and observations per file
pinfo = CheckModel(ff0);
tobs = pinfo.time_series_length;
if strcmp(E.diagn,'Truth')
  N = 1;
else
  N = pinfo.num_ens_members-2;      % (not sure why it's off by 2)
end

%% initialize the output array
t  = zeros(1,ndays*tobs)+NaN;
if ave_over_region
  ENS = zeros(N,ndays*tobs)+NaN;
  lat = NaN;
  lev = NaN;
  lon = NaN;
else
  lat = lat2(y1:y2);
  lon = lon2(x1:x2);
  lev = lev2(z1:z2); 
  nlat = length(lat);
  nlon = length(lon);
  nlev = length(lev);
  if strcmp(E.variable,'PS')
    ENS = zeros(ndays*tobs,N,nlat,nlon)+NaN;
  else
    ENS = zeros(ndays*tobs,N,nlat,nlon,nlev)+NaN;
  end
end

%% Cycle through DART output files and retrieve the ensemble of the desired field

k1 = 1;
for iday = E.day0:E.dayf

  %% find the obs sequence that corresponds to this day
  obs_seq_no = iday-E.start+1;
  if obs_seq_no < 10
    ff = [rundir,'obs_000',num2str(obs_seq_no),'/',fstring];
  else
    ff = [rundir,'obs_00',num2str(obs_seq_no),'/',fstring];
  end

  if exist(ff,'file') ~= 2
    disp(['Cannot find the following output file: ',ff]);
    disp(['filling in NaNs here'])
    k2 = k1+tobs-1;

  else

    disp(ff)
    tdum = nc_varget(ff, 'time');
    k2 = k1+tobs-1;
    t(k1:k2) = tdum';

    % load the desired variable field
    var0 = nc_varget(ff,var_key);
       
    % if not plotting truth, find copies corresponding to ensemble members.
    if (strcmp(E.diagn,'Truth') ~= 1) && (iday == E.day0)
      ens_copies = zeros(1,N)+NaN;
      for iens = 1:N
        if iens < 10
          spaces = '      ';
        else
          spaces = '     ';
        end
        ens_member_string = ['ensemble member',spaces,num2str(iens)];
        ens_copies(iens) = get_copy_index(ff,ens_member_string);
      end
    end

    % cycle over ensemble members and retrieve the desired variable
    for iens = 1:N
      if strcmp(E.diagn,'Truth')
        switch E.variable
          case {'U','V','T','Q','CLDIQ','CLDICE'}
            var1 = squeeze(var0(:,y1:y2,x1:x2,z1:z2));                     
          case 'PS'
            var1 = squeeze(var0(:,y1:y2,x1:x2));
        end
      else
        copy = ens_copies(iens); 
        % choose the right copy and region of the variable
        switch E.variable
          case {'U','V','T','Q','CLDIQ','CLDICE'}
            var1 = squeeze(var0(:,copy,y1:y2,x1:x2,z1:z2));                     
          case 'PS'
            var1 = squeeze(var0(:,copy,y1:y2,x1:x2));
        end
      end

      % now either average or just store the state
      if ave_over_region
        var2 = mean(var1,2);
        var3 = mean(var2,3);
        if strcmp(E.variable,'PS') 
          var4 = squeeze(var3);
        else
          var4 = squeeze(mean(var3,4));
        end 
        ENS(iens,k1:k2) = var4;
      else
        if strcmp(E.diagn,'Truth'),copy=1;end
        switch E.variable
          case {'U','V','T','Q','CLDIQ','CLDICE'}
            if strcmp(E.diagn,'Truth')
              ENS(k1:k2,iens,:,:,:) = var0(:,:,:,:);
            else
              ENS(k1:k2,iens,:,:,:) = var0(:,copy,:,:,:);
            end
          case 'PS'
            if strcmp(E.diagn,'Truth')
              ENS(k1:k2,iens,:,:) = var0(:,:,:);
            else
              ENS(k1:k2,iens,:,:) = var0(:,copy,:,:);
            end
        end
      end % if loop over whether or not to average  
     
    end	% loop over ensemble members
  end % loop over whether the file exists

  % advance the index      
  k1 = k2+1;
end


%% Output

ENS_out = ENS;
t_out = t;
