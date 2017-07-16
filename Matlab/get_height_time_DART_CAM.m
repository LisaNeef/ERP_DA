function [VAR_out,t_out,lev_out] = get_height_time_DART_CAM(E,hostname)
%% get_lat_time_dart_cam
%
% Compute the evolution of state variables in CAM prior,
% posterior, and truth states, as a function of latitude and time.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Then these can be plotted by the program plot_lat_time.m
%
% Lisa Neef, 30 Nov 2011
%
% INPUTS:
%  E: a structure holding all the experiment details and what we want to show.
%   these are the field names
%    run_name:
%    truth:
%    copystring:
%    variable:
%    level:
%    AAM_weighting:
%    diagn:
%    day0:
%    dayf:
%  hostname: currently only supporting 'blizzard'
%
% Mods:
%   8 Dec 2011: add ability to read Prior, Posterior, and Innovation from
%   DART runs (in addition to the true state).
%   8 Dec 2011: also adding ability to shuffle through separate files for
%   different days.
%   30 Jan 2012: added start and finish date, to make it easier to plot just
%   a part of the original data.
%   2  Feb 2012: add the option of Po-Tr as a diagnostic.  In this
%   case, copystring is automatically selected to be _______
%   3 Feb 2012: also add abs(Po-Tr) as a diagnostic, or RMSE
%   27 Feb 2012: make the code able to handle multiple obs times in one file.
%   20 Mar 2012: instead of plotting option 'ABSPo-Tr', do RMSE (where the
%   mean is over longitude in this case.)
%   25 Apr 2013: changes to file paths and inputs to accomodate my new experiments.
%   10 Jun 2013: make the input encapsulated in a simple structure array
%   10 Aug 2013: instead of looping over all available files, loop only over requested days -- makes this code faster.
%    4 Oct 2013: make it so that there are NaNs where DART output files are missing.

% temporary inputs if not running as a function:
%clear all; clf;
%clc;
%hostname	= 'blizzard';
%E_all = load_experiments;
%E = E_all(1);


%% paths and other settings

% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end


if strcmp(E.diagn,'Truth')
  rundir = [DART_output,E.truth,'/'];
else
  rundir = [DART_output,E.run_name,'/'];
end


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

switch E.diagn
  case 'Innov'
    fstring = 'Innov.nc';
  case 'RMSE'
    fstring = 'Po_minus_Tr.nc';
  case 'Prior'
    fstring = 'Prior_Diag.nc';
  case 'Posterior'
    fstring = 'Posterior_Diag.nc';
  case 'Truth'
    fstring = 'True_State.nc';
end

%% set up arrays

nt = E.dayf-E.day0;
t  = zeros(1,2*nt)+NaN;

ff0 = [rundir,'obs_0001/',fstring];
if exist(ff0,'file') ~= 2
  disp(['Cannot find the following output file: ',ff0]);
  return
end

if strcmp(E.variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end
nlat = length(lat);

lon = nc_varget(ff0,'lon');
rlon = lon*pi/180;
lev = nc_varget(ff0,'lev');

nlev = length(lev);
VAR = zeros(nlev,nt*2)+NaN;

%% find the indices of the latitude range we are interested in.
j0 = find(lat >= E.latrange(1), 1 );
jf = find(lat <= E.latrange(2), 1, 'last' );


%% Cycle through DART output files and retrieve desired field

% the loop goes to the smaller of (1) the dates considered, or (2) the
% dates available.

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
    disp('this will leave a blank in the plot...')
    if k1 > 1 
      % if this is not the first observation, we need to skip ahead in time.
      k2 = k1+nobstimes-1;
      k1=k2+1;
    end
  else

    disp(ff)
    tdum = nc_varget(ff, 'time');
    
    % record the number of obs times in one obs sequence
    if k1 == 1
      nobstimes = length(tdum);
    end

    k2 = k1+length(tdum)-1;
    t(k1:k2) = tdum';
       
    %  find the right "copy".  for Po-Tr, it's just 1.
    var0 = nc_varget(ff,var_key);
    if strcmp(E.diagn,'Po-Tr') || strcmp(E.diagn,'RMSE')
        copy = 1;
    else
        copy = get_copy_index(ff,E.copystring);
    end


    % choose the right "copy" and select the latitude range.
    % The dimensions are different for 3D and
    % 2D variables, and for single versus multiple obs times in one
    % file.
    if (length(tdum) > 1)
                if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr')|| strcmp(E.diagn,'RMSE')
                    var1 = squeeze(var0(:,j0:jf,:,:));
                else
                    var1 = squeeze(var0(:,copy,j0:jf,:,:));
                end
    else
                if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr')|| strcmp(E.diagn,'RMSE')
                    var1 = squeeze(var0(j0:jf,:,:));
                else
                    var1 = squeeze(var0(copy,j0:jf,:,:));
                end
    end

    if strcmp(E.diagn,'RMSE')
        var2 = var1.^2;
    else
        var2 = var1;
    end

       
    % integrate zonally and meridionally, or just average.
    if (length(tdum) > 1)
        switch E.AAM_weighting
            case {'X1','X2','X3'}
                var3 = squeeze(trapz(rlon,var2,3));
                VAR(:,k1:k2) = squeeze(trapz(rlat,var3,2))';
            case 'none'
                var3 = squeeze(nanmean(var2,3));
                VAR(:,k1:k2) = squeeze(nanmean(var3,2))';
         end
    else
        switch E.AAM_weighting
            case {'X1','X2','X3'}
                var3 = squeeze(trapz(rlon,var2,2));
                VAR(:,k1:k2) = squeeze(trapz(rlat,var3,1))';
            case 'none'
                var3 = squeeze(nanmean(var2,2));
                VAR(:,k1:k2) = squeeze(nanmean(var3,1))';
         end
    end

    % advance the time index after reading in this file
    k1 = k2+1;
  end
end

VAR2 = VAR;

%% if computing RMSE, still need to take the square root
if strcmp(E.diagn,'RMSE')
    VAR3 = sqrt(VAR2);
else
    VAR3 = VAR2;
end


%% Scaling the computed array:

% (1) f: convert units to equivalent ERP variations.
%     (W and f should come out as 1's if no weighting is specified)
% (2) also, look at the anomaly with respect to the annual
%      mean.


f = eam_prefactors(E.AAM_weighting,E.variable);
aam_constants_gross

switch E.AAM_weighting
    case {'X1','X2'}
        f2 = rad2mas*f;
    case 'X3'
        f2 = LOD0_ms*f;
    case 'none'
        f2 = f;
end

% to detrend or not to detrend?
switch E.AAM_weighting
    case {'X1','X2','X3'}
        VAR4 = f2*detrend(VAR3','constant')';
    case 'none'
        VAR4 = f2*VAR3;
end

%% Output
VAR_out = VAR4;
t_out = t;
lev_out = lev;

