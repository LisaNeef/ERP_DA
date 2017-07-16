%% cam_ens_error_lisa

%% DART software - Copyright � 2004 - 2010 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/models/cam/matlab/cam_ens_error.m $
% $Id: cam_ens_error.m 4266 2010-02-08 18:11:31Z thoar $
% $Revision: 4266 $
% $Date: 2010-02-08 19:11:31 +0100 (Mon, 08 Feb 2010) $

% Assumes 2 copies of data are ensemble mean and spread
% Should be checked and automated
%
% MODS by Lisa Neef:
%   17 Jun 2011: instead of loading state vectors, load individual
%   variables.
%   17 Jun 2011: change out getnc to nc_varget



% Select field to plot (ps, t, u, v)
field_name = input('Input field type, US, VS, PS, T:   ')

% Load True state
fname = 'True_State.nc';
%fname = input('Input true state name');
lon = nc_varget(fname, 'lon');
num_lon = size(lon, 1);
lat = nc_varget(fname, 'lat');
num_lat = size(lat, 1);
level = nc_varget(fname, 'lev');
num_level = size(level, 1);
state_vec = nc_varget(fname, field_name,'preserve_fvd');

% Load the ensemble file
%ens_fname = input('Input file name for ensemble');
ens_fname = 'Prior_Diag.nc'
ens_vec = nc_varget(ens_fname, field_name);

% Ensemble size is
ens_size = size(ens_vec, 2);

% Get a time level from the user
time_ind = input('Input time level');

% Extract state and ensemble for just this time
single_state = state_vec(time_ind, :);
clear state_vec;

% Get ensemble mean and spread
ens_mean = ens_vec(time_ind, 1, :);
ens_spread = ens_vec(time_ind, 2, :);
clear ens_vec


% Get level for free atmosphere fields
if field_num > 1
   field_level = input('Input level');
else
   field_level = 1;
end


% Extract one of the fields
   offset = (field_level - 1) * 4 + field_num
% Stride is number of fields in column
   stride = num_level * 4 + 1
   field_vec = single_state(offset : stride : (stride) * (num_lon * num_lat));
   ens_vec = ens_mean(offset : stride : (stride) * (num_lon * num_lat));
   spread_vec = ens_spread(offset : stride : (stride) * (num_lon * num_lat));

   field = reshape(field_vec, [num_lat, num_lon]);
   ens = reshape(ens_vec, [num_lat, num_lon]);
   spread = reshape(spread_vec, [num_lat, num_lon]);


figure(1);
[C, h] = contourf(field, 10);
clabel(C, h);

figure(2);
[C, h] = contourf(ens, 10);
clabel(C, h);

% Compute and plot the difference field
ens_err = (ens - field);
figure(3);
[C, h] = contourf(ens_err, 10);
clabel(C, h);

% Compute statistics of the error field
max_err = max(max(ens_err));
min_err = min(min(ens_err));
rms_err = mean(mean(abs(ens_err)));

% Label figure 3 with these statistics
title_string = ['Min = ', num2str(min_err), ' Max =  ', num2str(max_err), '   RMS ERROR = ', num2str(rms_err)];
title (title_string)

% Output the spread plot, too
figure(4);
[C, h] = contourf(spread, 10);
clabel(C, h);

% Compute statistics of the spread field
max_spread = max(max(ens_spread));
min_spread = min(min(ens_spread));
rms_spread = mean(mean(ens_spread));

% Label figure 4 with these statistics
title_string = ['Min = ', num2str(min_spread), ' Max =  ', num2str(max_spread), '   RMS ERROR = ', num2str(rms_spread)];
title (title_string)



