%% plot_jeff_correl.m
% Plots time series of correlation between a given variable at a given
% time and another variable at all times in an ensemble time sequence.

%% DART software - Copyright 2004 - 2011 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/matlab/plot_jeff_correl.m $
% $Id: plot_jeff_correl.m 4947 2011-06-02 23:20:44Z thoar $
% $Revision: 4947 $
% $Date: 2011-06-03 01:20:44 +0200 (Fri, 03 Jun 2011) $

if (exist('fname','var') ~=1)
   disp('Input name of file;')
   fname = input('<cr> for Prior_Diag.nc\n','s');
   if isempty(fname)
      fname = 'Prior_Diag.nc';
   end
end

if (exist(fname,'file') ~=2 ), error('%s does not exist.',fname); end

% check to make sure they are using a file with some ensemble members.

diminfo    = nc_getdiminfo(fname,'copy');
num_copies = diminfo.Length; % determine # of ensemble members

if (num_copies <= 3) 
   error('Sorry -- %s does not have enough ensemble members to correlate.',fname)
end 

pinfo = CheckModel(fname); % also gets default values for this file.
pinfo.fname = fname;

switch lower(pinfo.model) 
   case {'9var','lorenz_63','lorenz_84','lorenz_96','lorenz_04', ...
	 'forced_lorenz_96','ikeda'}

      inputstring = input( ...
           sprintf('Input index for base variable (between %d and %d, inclusive)  ', ...
           pinfo.min_state_var, pinfo.max_state_var), 's');
      pinfo.base_var_index = str2num(deblank(inputstring));

      inputstring = input( ...
           sprintf('Input time index for base point (between 1 and %d, inclusive)  ', ...
           pinfo.time_series_length),'s');
      pinfo.base_time = str2num(deblank(inputstring));

      inputstring = input( ...
           sprintf('Input variable index for correlation (between %d and %d, inclusive)  ', ...
           pinfo.min_state_var, pinfo.max_state_var), 's');
      pinfo.state_var_index = str2num(deblank(inputstring));

      pinfo.base_var  = pinfo.def_var;
      pinfo.state_var = pinfo.def_var;

   case {'lorenz_96_2scale'}

      fprintf('Your choice of variables is ''X'' or ''Y''\n')
      fprintf('''X'' can range from %d to %d\n', pinfo.min_X_var, pinfo.max_X_var)
      fprintf('''Y'' can range from %d to %d\n', pinfo.min_Y_var, pinfo.max_Y_var)

      % parsing the result of this one is a bit tricky.
      inputstring = input('Input base variable and index i.e.  X 5\n','s');
      [pinfo.base_var, pinfo.base_var_index] = ParseAlphaNumerics(inputstring);

      inputstring = input( ...
           sprintf('Input time index for base point (between 1 and %d, inclusive) \n', ...
           pinfo.time_series_length),'s');
      pinfo.base_time = str2num(deblank(inputstring));

      % parsing the result of this one is a bit tricky.
      inputstring = input('Input variable and index for correlation \n','s');
      [pinfo.state_var, pinfo.state_var_index] = ParseAlphaNumerics(inputstring);

   case {'simple_advection'}

      disp('Your choice of variables are:')
      disp(pinfo.vars)
      fprintf('the indices (locations) can range from %d to %d, inclusive\n', ...
           pinfo.min_state_var, pinfo.max_state_var)

      str1 = sprintf('Input base variable and index i.e. %s %d\n', ...
                      pinfo.def_var,pinfo.def_state_vars(1));
      inputstring = input(str1,'s');
      [pinfo.base_var, pinfo.base_var_index] = ParseAlphaNumerics(inputstring);

      inputstring = input( ...
           sprintf('Input time index for base point (between 1 and %d, inclusive)  ', ...
           pinfo.time_series_length),'s');
      pinfo.base_time = str2num(deblank(inputstring));

      inputstring = input('Input variable and index for correlation \n','s');
      [pinfo.state_var, pinfo.state_var_index] = ParseAlphaNumerics(inputstring);

   case 'fms_bgrid'

      pinfo = GetBgridInfo(pinfo, fname, 'PlotVarVarCorrel');

   case 'wrf'

      pinfo = GetWRFInfo(pinfo, fname, 'PlotVarVarCorrel');

   case 'cam'

      pinfo = GetCamInfo(pinfo, fname, 'PlotVarVarCorrel');

   case 'pe2lyr'

      pinfo = GetPe2lyrInfo(pinfo, fname, 'PlotVarVarCorrel');

   case 'mitgcm_ocean'

      pinfo = GetMITgcm_oceanInfo(pinfo, fname, 'PlotVarVarCorrel');

   otherwise

      error('model %s not implemented yet', pinfo.model)

end

pinfo

PlotJeffCorrel( pinfo )

clear inputstring diminfo num_copies
