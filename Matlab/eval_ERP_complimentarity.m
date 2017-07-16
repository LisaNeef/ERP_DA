%% batch_diagnostics.m
%
% go through standard output diagnostics for baseline DART experiments and make a bunch of plots.
% Lisa Neef, 26 June 2013
%
% MODS:
%  make this more compact by turning all the make programs into functions with input exp_list, which is 
%  the list of number codes for each experiment.
%------------------------------------------------

clear all;
clc;
hostname = 'blizzard';
day0 = 149020;
dayf = day0+31+28;


exp_list = [2,7];
plot_name = 'rmse_RS';

% comparing error reduction ...this doesn't tell us much
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'PS',plot_name)
make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)

% comparing global errors
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'U300',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'UEUR',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'PS',plot_name)

% when we add ERPs, does the innovation get stronger or weaker in time? 
make_compare_lat_time(exp_list,hostname,'Innov',day0,dayf,'U300',plot_name)


