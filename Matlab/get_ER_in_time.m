function [ER_out,tt_out] = get_ER_in_time(run,noDA,variable,level,GD,latrange,hostname)
%% get_ER_bootstrap_global.m
%
% This function computes the global error reduction in a given DART run.
%
% Lisa Neef, 1 August 2012
%
% INPUTS:
%   run: the run that we are interested in.
%   noDArun: the no-assimilation run that we compare to.
%   variable: the state variable of interest - currently supporting U, V, PS
%   level: the approximate vertical level of interest, in hPa
%   GD: the array of gregorian dates over which to sample the bootstrap
%   latrange: the desired latitude range over which to compute this.
%
% OUTPUTS:
%   ER_out: a 1D timeseries of global error reduction relative to the no-DA case
%   tt_out: the corresponding vector of gregorian dates.
%
% MODS:
%
%
%-------------------------------------------------------------------------


%% temporary inputs-----------
%clear all;
%clc;
%run            = 'ERP1_2001_N64_UVPS';
%noDA           = 'ERPALL_2001_noDA';
%variable       = 'U';
%level          = 300;
%GD             = 146097:1:146100;
%latrange       = [-90,90];
%hostname       = 'blizzard';
%% temporary inputs-----------

%% Other variables needed:
diagn = 'RMSE';
CS = 'ensemble mean';
d0 = GD(1);
df = max(GD);

%% Compute the ER for the desired period.

% error in the no-DA run.
[dd_noDA,tt_out] = get_diagn_in_time(noDA,diagn,CS,level,variable,d0,df,latrange,hostname);

% error in the focus run
[dd,tt] = get_diagn_in_time(run,diagn,CS,level,variable,d0,df,latrange,hostname);

ER_out = dd-dd_noDA;


