function [h_out,x_out] = get_ER_global_histogram(run,variable,level,GD,hostname)
%% get_ER_global_histogram.m
%
% This function retrieves the global error reduction in a given DART run,
% and plots a histogram of the values.
% This should help us better compare different assimilations relative to one another.
%
% Lisa Neef, 1 August 2012
%
% INPUTS:
%   run: the run that we are interested in.
%   variable: the state variable of interest - currently supporting U, V, PS
%   level: the approximate vertical level of interest, in hPa
%   GD: the array of gregorian dates over which to sample the bootstrap
%   nboot: number of bootstrap samples desired.
%
% OUTPUTS:
%   h_out = the histogram
%   x_out = the corresponding ER bins on the x-axis.
%
% MODS:
%
%
%-------------------------------------------------------------------------


%% temporary inputs-----------
%clear all;
%clc;
%run            = 'ERP1_2001_N64_UVPS';
%variable       = 'U';
%level          = 300;
%GD             = 146097:1:146155;
%nboot	       = 10;
%hostname       = 'blizzard';
%% temporary inputs-----------

%% other variables needed
noDA = 'ERPALL_2001_noDA';
latrange = [-90,90];

% retrieve the global ER timeseries for the entire run

[ER,t] = get_ER_in_time(run,noDA,variable,level,GD,latrange,hostname);

% compute a histogram of these values.

[h_out,x_out] = hist(ER);
