function [y, ydims] = get_varsNdims(fname);
%% Get the dimension (strings) for each atmospheric variable.
% [y, ydims] = get_vars_dims(fname);
%
% fname     a netcdf file name
%
% y       a cell array of variable names
% ydims   a cell array of the concatenated dimension names 
%
% EXAMPLE:
% 
% fname      = 'obs_seq.final.nc';
% [y, ydims] = get_varsNdims(fname);
%
% >> plotdat.allvarnames{20}  
%
%    AIRCRAFT_U_WIND_COMPONENT_guess
%
% >> plotdat.allvardims{20}
%    region plevel copy time

%% DART software - Copyright 2004 - 2011 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/diagnostics/matlab/get_varsNdims.m $
% $Id: get_varsNdims.m 4947 2011-06-02 23:20:44Z thoar $
% $Revision: 4947 $
% $Date: 2011-06-03 01:20:44 +0200 (Fri, 03 Jun 2011) $

ALLvarnames = get_varnames(fname);
Nvarnames   = length(ALLvarnames);

for i = 1:Nvarnames

   varname = ALLvarnames{i};
   varinfo = nc_getvarinfo(fname,varname);

   y{i}     = varname;
   ydims{i} = sprintf('%s ',varinfo.Dimension{:});

end
