function bob = Get_Field(filename,basevar,timeind,level,enssize)
%% x = Get_Field(filename,basevar,timeind,level);
% filename = '/project/dart/raeder/J/T85_3/01_04/Prior_Diag.nc';
% basevar = 'T';
% timeind = 2;
% level   = 7;

%% DART software - Copyright � 2004 - 2010 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/models/cam/matlab/Get_Field.m $
% $Id: Get_Field.m 4266 2010-02-08 18:11:31Z thoar $
% $Revision: 4266 $
% $Date: 2010-02-08 19:11:31 +0100 (Mon, 08 Feb 2010) $

% use some of the infinite numbers of options on getnc() to get only a
% hyperslab of the data in the first place rather than squeeze afterwards.

% assumes incoming data dims are: [timestep, ens_num, lat, lon, lev];

% first 2 copies are mean/var; last 2 are inflation mean/var
bl_corner = [timeind, 3,         -1, -1, level];
ur_corner = [timeind, enssize+2, -1, -1, level];
squeeze_it = 1;

bob = getnc(filename, basevar, bl_corner, ur_corner, -1,-1,-1,-1, squeeze_it);

% doc for getnc()
%   function values = getnc(file, varid, corner, end_point, stride, order, ...
%                           change_miss, new_miss, squeeze_it, rescale_opts)
 

