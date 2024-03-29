%% DART:plot_ens_time_series - time series of ensemble and truth (if available)
%                                                                               
% plot_ens_time_series    interactively queries for the needed information.
%              Since different models potentially need different pieces of 
%              information ... the model types are determined and additional 
%              user input may be queried.
%
% Example 2
% truth_file = 'True_State.nc';
% diagn_file = 'Posterior_Diag.nc';
% plot_ens_time_series

%% DART software - Copyright 2004 - 2011 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% <next few lines under version control, do not edit>
% $URL: https://proxy.subversion.ucar.edu/DAReS/DART/trunk/matlab/plot_ens_time_series.m $
% $Id: plot_ens_time_series.m 5066 2011-07-08 22:39:38Z thoar $
% $Revision: 5066 $
% $Date: 2011-07-09 00:39:38 +0200 (Sat, 09 Jul 2011) $

if (exist('diagn_file','var') ~=1)
   disp(' ')
   disp('Input name of prior or posterior diagnostics file;')
   diagn_file = input('<cr> for Prior_Diag.nc\n','s');
   if isempty(diagn_file)
      diagn_file = 'Prior_Diag.nc';
   end
end

if (exist('truth_file','var') ~= 1)
   disp(' ')
   disp('OPTIONAL: if you have the true state and want it superimposed, provide')
   disp('        : the name of the input file. If not, enter a dummy filename.')
   truth_file = input('Input name of True State file; <cr> for True_State.nc\n','s');
   if isempty(truth_file)
      truth_file = 'True_State.nc';
   end
end

pinfo = CheckModel(diagn_file); % also gets default values for this model.

if (exist(truth_file,'file')==2)

   MyInfo = CheckModelCompatibility(truth_file, diagn_file);

   % Combine the information from CheckModel and CheckModelCompatibility
   mynames = fieldnames(MyInfo);

   for ifield = 1:length(mynames)
      myname = mynames{ifield};
      if ( isfield(pinfo,myname) ), warning('plot_ens_time_series: pinfo.%s already exists\n',myname); end
      eval(sprintf('pinfo.%s = MyInfo.%s;',myname,myname));
   end
else
   truth_file = [];
end
pinfo.diagn_file = diagn_file;
pinfo.truth_file = truth_file;

clear MyInfo mynames myname ifield

%% For each model, do what needs to be done.

switch lower(pinfo.model)

   case {'9var','lorenz_63','lorenz_84','lorenz_96','lorenz_96_2scale', ...
	 'forced_lorenz_96','lorenz_04','ikeda','simple_advection'}

      varid = SetVariableID(pinfo);      % queries for variable IDs if needed.
      pinfo.var        = varid.var;
      pinfo.var_inds   = varid.var_inds;

      fprintf('Comparing %s and \n          %s\n', pinfo.truth_file, pinfo.diagn_file)
      disp(['Using State Variable IDs ', num2str(pinfo.var_inds)])
      clear varid

   case 'fms_bgrid'

      pinfo = GetBgridInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case 'cam'

      pinfo.prior_file     = [];
      pinfo.posterior_file = [];
      pinfo                = GetCamInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case 'wrf'

      pinfo = GetWRFInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case 'pe2lyr'

      pinfo = GetPe2lyrInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case 'mitgcm_ocean'

      pinfo = GetMITgcm_oceanInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   otherwise

      error('model %s not implemented yet', pinfo.model)

end

pinfo

PlotEnsTimeSeries( pinfo )
clear vars varid

