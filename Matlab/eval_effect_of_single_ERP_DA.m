%% batch_diagnostics.m
%
% go through standard output diagnostics for baseline DART experiments and make a bunch of plots.
% Lisa Neef, 29 July 2013
%
% MODS:
%------------------------------------------------

clear all;
clc;
hostname = 'blizzard';
day0 = 149020;
dayf = day0+31+28;

%% compare the assimilation of ERPs to no assimilation at all - where do the ERPs lead to improvement?
exp_list = [3];
plot_name = 'ER_ERPs';
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'PS',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'UEUR',plot_name)

%% look at the effect of assimilating the single ERPs
exp_list = [1,3,4,5,6];
plot_name = 'rmse_ERPs';
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'U300',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'PS',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'UEUR',plot_name)

%% comparison of horizontal localization
dayf = day0+10;
exp_list = [3,11];
plot_name = 'test_horiz_localization';
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_10dayerror(exp_list,hostname,'U300','Innov',plot_name)

%% what happens if we only adjust U and not the other variables?
dayf = day0+10;
exp_list = [3,9];
plot_name = 'Uonly';
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'UEUR',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'U300',plot_name)
