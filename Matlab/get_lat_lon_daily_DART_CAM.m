function [VAR_out,lat_out,lon_out] = get_lat_lon_daily_DART_CAM(E,hostname)
% This function retrieves CAM-DART output fields for a given day, level, and 
% some diagnostic (prior/posterior ensemble mean, spread, or
% truth), returning a lat-lon field.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the corresponding
% mass/motion terms of AAM excitation.  
% In that case, the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Input is the structure E.  
% E.dayf gives the date where we make the plot.
%
% Lisa Neef, 16 December 2011.
%
% MODS:
%   28 Mar 2012: updating the code in line with my other developments.
%   31 Jul 2012: also make it possible to retrieve diagnostics "PO_minus_Tr" and "PR_minus_Tr"
%   28 Jun 2013: overhaul this whole thing to fit my new experiment organization
%    1 Jul 2013: adapt code to accomodate more than one day in the state
%   31 Jul 2013: some bug fixes for other diagnostics than the one (RMSE) I tested this code with.
%--------------------------------------------------------------------------------


%% temporary inputs
%clear all; clc;
%E = load_experiments;
%E = E(3);
%hostname = 'blizzard';
%E.dayf = E.start+10;
%E.diagn = 'Innov';

%-----------------------------------------

%% paths and other settings
% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end

rundir = [DART_output,E.run_name];

if strcmp(E.diagn,'Truth')
        rundir = [DART_output,E.truth];
        E.copystring = 'true state';
end

%% Define a switch for derivative diagnostics that just have 1 copy
if strcmp(E.diagn,'RMSE') || strcmp(E.diagn,'PO_minus_Tr') || strcmp(E.diagn,'PR_minus_Tr') || strcmp(E.diagn,'Truth') 
    single_copy = 1;
else
    single_copy = 0;
end

switch E.variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'VS';
end

%% Figure out which output file we need
nday = E.dayf-E.start+1;
nn = num2str(nday);
if length(nn) == 1
  obs_seq_name = ['obs_000',nn];
end
if length(nn) == 2
  obs_seq_name = ['obs_00',nn];
end

switch E.diagn
  case 'Truth'
    ff = 'True_State.nc';
  case 'Posterior'
    ff = 'Posterior_Diag.nc';
  case 'Prior'
    ff = 'Prior_Diag.nc';
  case 'RMSE'
    ff = 'Po_minus_Tr.nc';
  case 'Innov'
    ff = 'Innov.nc';
end


ff = [rundir,'/',obs_seq_name,'/',ff];



%% load the desired field
time = nc_varget(ff, 'time');
var0 = nc_varget(ff,var_key);

if length(time) > 1
  more_times = 1;
else
  more_times = 0;
end

if single_copy
  copy = 1;
else
  copy = get_copy_index(ff,E.copystring); 
end

%% weighting - just ones if AAM_weighting is 'none'
if strcmp(E.variable,'U')
    lat = nc_varget(ff,'slat');
else
    lat = nc_varget(ff,'lat');
end
lon = nc_varget(ff,'lon');
lev = nc_varget(ff,'lev');
W = eam_weights(lat,lon,E.AAM_weighting,E.variable);

% reshape the weights array to fit the dimensions of the variable
nt = length(time);
nlat = length(lat);
nlon = length(lon);
W2 = zeros(nt,nlat,nlon);
for ii = 1:nt
  W2(ii,:,:) = W';
end
W2 = squeeze(W2);

%% select the desired level and apply weighting, if desired.  
if strcmp(E.variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= E.level, 1, 'last' );
end

switch E.variable
  case {'U','V'}
    if single_copy
      if more_times
        var1 = W2.*squeeze(var0(:,:,:,ilev));
      else
        var1 = W2.*squeeze(var0(:,:,ilev));  
      end
    else
      if more_times
        var1 = W2.*squeeze(var0(:,copy,:,:,ilev));
      else
        var1 = W2.*squeeze(var0(copy,:,:,ilev));                     
      end
    end
  case 'PS'
    if single_copy
      var1 = W2.*var0;  
    else
      if more_times
        var1 = W2.*squeeze(var0(copy,:,:,:));
        disp('applying AAM weights to array with multiple times -- run get_lat_lon_daily_DART_CAM.m manually and check that this is done right!')
      else
        var1 = W2.*squeeze(var0(copy,:,:));
      end
    end
end
       

%% this is the output

if strcmp(E.diagn,'RMSE')
  VAR_out = abs(var1);
else
  VAR_out = var1;
end

lat_out = lat;
lon_out = lon;

