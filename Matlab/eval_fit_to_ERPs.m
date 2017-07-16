%% diagnostics_obs_space.m
%
% Comparing how well the different experiments are able to fit the
% three Earth rotation parameters
%
% 9 Aug 2013
%---------------------------------------------------------------------


exp_list = [1,3,2,7];
plot_name = 'baseline_expts';
day0 = 149019;
dayf = day0+31;
hostname = 'blizzard';

% load the experiments

E_all = load_experiments;
E = E_all(exp_list)
for ii = 1:length(exp_list)
  E(ii).day0 = day0;
  E(ii).dayf = dayf;
end


% run the plotting codes

make_compare_ERPs(E,hostname,{'ERP_PM1'},plot_name)
make_compare_ERPs(E,hostname,{'ERP_PM2'},plot_name)
make_compare_ERPs(E,hostname,{'ERP_LOD'},plot_name)

