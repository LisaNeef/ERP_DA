function [variable,level,latrange,lonrange] = diagnostic_quantities(vv);
%% diagnostic_quantities.m
%
%  This function returns the definition of the various diagnostic 
%  quantities we look at to evaluate DART experiments.
%
%  INPUTS:
%   vv: the string defining the thing we want to plo
%
%  OUTPUTS:
%   variable: the DART state variable
%   level: the vertical level in hPa
%   latrange: the range of lats that this diangnostic is defined over
%   lonrange: the range of lons that this diangnostic is defined over
%
%  Lisa Neef, 26 July 2013
%-----------------------------------------

switch vv
  case 'U300'
    variable = 'U';
    level = 300;
    latrange = [-90,90];
    lonrange = [0,360];
  case 'PS'
    variable = 'PS';
    level = 0;
    latrange = [-90,90];
    lonrange = [0,360];
  case 'UEUR'
    variable = 'U';
    level = 850;
    latrange = [20,70];
    lonrange = [0,60];
  case 'V300'
    variable = 'V';
    level = 300;
    latrange = [-90,90];
    lonrange = [0,360];
end
