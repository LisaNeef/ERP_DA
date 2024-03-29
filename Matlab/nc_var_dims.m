function vdims = nc_var_dims(ncfname,varname);
%% Get the names of the coordinate variables for each 
% of the dimensions of the variable.
%
% vdims = nc_var_dims(ncfname,varname);
%
% ncfname    file name of a netcdf file
% varname    a variable names
% vdims      a cell array of the coordinate variables
%
% EXAMPLE:
% 
% ncfname = 'obs_seq.final.nc';
% varname = 'RADIOSONDE_TEMPERATURE_guess';
% vdims   = nc_var_dims(ncfname,varname);
% for i = 1:length(vdims)
%    disp(sprintf('variable %s dimension %d is %s',varname,i,vdims{i}))
% end

%% DART software - Copyright 2004 - 2011 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/diagnostics/matlab/nc_var_dims.m $
% $Id: nc_var_dims.m 4947 2011-06-02 23:20:44Z thoar $
% $Revision: 4947 $
% $Date: 2011-06-03 01:20:44 +0200 (Fri, 03 Jun 2011) $

if ( nc_isvar(ncfname, varname) )
   varinfo = nc_getvarinfo(ncfname,varname);
   vdims   = varinfo.Dimension;
else
   fprintf('%s does not have a %s variable.\n',ncfname, varname)
   fprintf('It does have the following:\n')
   nc_dump(ncfname)
   error('%s does not have a %s variable.',ncfname, varname)
end
