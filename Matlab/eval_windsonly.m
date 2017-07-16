%% batch_diagnostics.m
%
% examine how the increment changes if we only have winds as the control variablew
% 17 Aug 2013
%
% MODS:
%------------------------------------------------

clear all;
clc;
hostname = 'blizzard';
day0 = 149020;
dayf = day0+10;

%% compare the assimilation of ERPs to no assimilation at all - where do the ERPs lead to improvement?
exp_list = [3,9];
plot_name = 'winds_only';

make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_lat_time([1,3,9],hostname,'RMSE',day0,dayf,'U300',plot_name)
make_compare_lat_time(exp_list,hostname,'ER',day0,dayf,'V300',plot_name)

make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'U300',plot_name)
make_compare_p_time(exp_list,hostname,'ER',day0,dayf,'V300',plot_name)

make_compare_global(exp_list,hostname,diagn,day0,dayf,'U300',plot_name)
make_compare_global(exp_list,hostname,diagn,day0,dayf,'V300',plot_name)



