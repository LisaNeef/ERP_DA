%% eval_ERP_complimantarity_basic.m  
% 
% A more simple look at the ERPRS simulation relative to radiosondes only. 
% Can we idenitify any areas in the state where the ERP assimilation makes things 
% better at all?  
%
% 28 Oct 2013
%--------------------------------------------------------------------------------------------


%% define the two experiments
EE = load_experiments;
for iX = 1:length(EE)
  EE(iX).dayf = EE(iX).day0+40;
end
RS = EE(2);
ERPRS = EE(7);
hostname = 'blizzard';


%% make the plot
figure(1),clf
subplot(2,1,1)
plot_height_time_diff(ERPRS, RS, hostname)
title('Zonal Wind RMSE Difference ERPRS-RS')

subplot(2,1,2)
plot_lat_time_diff(ERPRS, RS, hostname)
title('Surface Pressyre RMSE Difference ERPRS-RS')

%% plot export
set(gcf, 'renderer', 'painters');
fig_name = 'ERP_complimentarity.eps';
disp(['creating figure ',fig_name])

ph = 12;
pw = 12;
fs = 1.5;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

