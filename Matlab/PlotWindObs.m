%% PlotWindObs ... a function in progress ... not for general use.

%% DART software - Copyright 2004 - 2011 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/diagnostics/matlab/PlotWindObs.m $
% $Id: PlotWindObs.m 4947 2011-06-02 23:20:44Z thoar $
% $Revision: 4947 $
% $Date: 2011-06-03 01:20:44 +0200 (Fri, 03 Jun 2011) $

for periods = 2:37;

   fname = sprintf('wind_vectors.%03d.dat',periods);
   ncname = 'obs_diag_output.nc';
   platform = 'SAT';
   level = -1;

   obs = plot_wind_vectors(fname,ncname,platform,level);

   disp('Pausing, hit any key to continue ...')
   pause

end

