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
dayf = day0+20;

%% compare the assimilation of ERPs to no assimilation at all - where do the ERPs lead to improvement?
exp_list = [3,12];
plot_name = 'ER_ERPs';
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'V300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'PS',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'UEUR',plot_name)

make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'V300',plot_name)


exp_list = [1,3,12];
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'U300',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'V300',plot_name)
make_compare_global(exp_list,hostname,'RMSE',day0,dayf,'PS',plot_name)

%% looking more closely at the innovation
plot_name = 'Innov_ERPs';
%make_compare_lat_time([3,12],hostname,'Innov',day0,dayf,'U300',plot_name)
%make_compare_lat_time([3,12],hostname,'Innov',day0,dayf,'PS',plot_name)
