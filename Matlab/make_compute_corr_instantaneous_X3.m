%% make_compute_corr_instantanous.m
%
% Sweep over a set of days, variables, and AEFs, and compute the instantaneous 
%  correlations between state variables ad AEFs, in some DART run.
%
%  Lisa Neef, 6 June 2012


%% Inputs

clear all;
clc;
dart_run = 'ERPALL_2001_N96';
day_prefix = 'ERPALL_N96_';
N = 96;

VV = {'U','V','PS'};
XX = {'X3'};

naefs = length(XX);
nvar = length(VV);

days = 146097:1:146153;
ndays = length(days);

%% Loops:

for iday = 1:ndays
  for ivar = 1:nvar
    variable = char(VV(ivar));
    for iaef = 1:naefs
      aef = char(XX(iaef));
      compute_corr_instantaneous(dart_run,day_prefix,N,variable,aef,days)
    end % loop over AEFs
  end   % loop over variables
end     % loop over days
