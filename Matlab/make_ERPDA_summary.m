%% batch_summary_plots.m
% make  plots that summarize DART ERP assimilation.
% this is what we want to show:
%	1. RMSE with no DA (error growth)
%	2. RMSE with DA (slowed down error growth)
%	3. Error reduction (diff between the above)
%	4. Innovation (where the obs had the most impact)
%
% The goal is to illustrate in the paper that we get substantial error reduction,
% but that it doesn't really last beyond the first month.
%
% 7 Oct 2013
%-------------------------------------------------------------------------------

clear all;
clc;

%% define the experiments to plot

EE = load_experiments;
E = EE([1,3,3,3]);

E(1).diagn = 'RMSE';
E(2).diagn = 'RMSE';
E(3).diagn = 'RMSE';
E(4).diagn = 'Innov';

E(1).diff = 'none';
E(2).diff = 'none';
E(3).diff = 1;
E(4).diff = 'none';

E(1).exp_name = 'RMSE, No DA';
E(2).exp_name = 'RMSE, ERP DA';
E(3).exp_name = 'Error Reduction';
E(4).exp_name = 'Innovation';

plot_name = 'ERP_DA';
hostname = 'blizzard';


%% pressure-time slices of zonal wind with and without DA
plot_name = 'ERP_DA_U';
make_compare_p_time(E,hostname,plot_name)

%% 300hPa zonal wind with and without DA
make_compare_lat_time(E,hostname,plot_name)

%% surface pressure with and without DA
nX = length(E);
for iX = 1:nX
  E(iX).variable = 'PS';
end

plot_name = 'ERP_DA_PS';
make_compare_lat_time(E,hostname,plot_name)


