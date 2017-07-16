function [Diff_out,lat_out,lon_out] = get_innov_dist_to_truth(run,variable,level,GD,hostname)
%% get_innov_dist_to_truth.m
%  
%  This function retrieves the fields of difference between the Posterior/Prior and the Truth
%  (if they exist), and computes the innovation in the absolute value of these fields.
%  The output is a 2D-field of differences for some variable and at some variable.
%
%  Lisa Neef, 31 Aug 2012
%
%  INPUTS:
%    run = the name of the DART run
%    variable = the variable we are interested in.  Currently only 'U','V' and 'PS' are supported.
%    level = the approximate vertical level we want, in hPa
%    GD = array of gregorian dates that we want
%    hostname = the computer.  Presently only supporting 'blizzard'
%
%  OUTPUTS:
%    Diff_out: field(s) of diff in the absolute-value distance to the truth
%    lat_out: corresponding latitude
%    lon_out: corresponding longitude
%
%  MODS:
%-------------------------------------------------------------------------------------------


%% temporary inputs

%clear all;
%clc;
%run 		= 'ERP1_2001_N64_UVPS';
%variable 	= 'U';
%level 		= 300;
%GD		= 146097:1:146100;
%hostname 	= 'blizzard';

%% Retrieve the difference fields, take the abs-val, and difference again

% some dummy inputs:
CS = 'ensemble mean';
W  = 'none';



% get the data for the first day
[Dprior,lat,lon] = get_lat_lon_daily_DART_CAM(run,'PR_minus_Tr',CS,variable,level,W,GD(1),hostname);
[Dpost,~,~]  = get_lat_lon_daily_DART_CAM(run,'PO_minus_Tr',CS,variable,level,W,GD(1),hostname);

% if that's the only day, fine.  If there are more days, cycle over them
if length(GD) == 1
  Diff_out = abs(Dprior) - abs(Dpost);
else
  Diff_out = zeros(length(lat),length(lon),length(GD));
  Diff_out(:,:,1) = abs(Dprior) - abs(Dpost);

  for iday = 2:length(GD)
    [Dprior,~,~] = get_lat_lon_daily_DART_CAM(run,'PR_minus_Tr',CS,variable,level,W,GD(iday),hostname);
    [Dpost,~,~]  = get_lat_lon_daily_DART_CAM(run,'PO_minus_Tr',CS,variable,level,W,GD(iday),hostname);
    Diff_out(:,:,iday) = abs(Dprior) - abs(Dpost);
  end
end

lat_out = lat;
lon_out = lon;
