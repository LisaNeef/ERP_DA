%% make_ERP_DA_obsspace_examples.png
%
%  Plot an example case of LOD assimilation in observation space:
%  before the assimilation, the ensemble generally gets the ERP right,
%  but not day-to-day variability.  After assimilation, the ensemble members
%  have all been forced to fit the observation.




%% settings for the plot code
hostname = 'blizzard';
runid_noDA = 'ERP3_2001_N64_UVPS';
runid_DA = 'ERP3_2001_N64_UVPS';
pmoid = 'PMO_ERPALL_2001';
obs_string = 'ERP_LOD';
day0 = 146097;
dayf = 146155;
leg = 1;

fig1 = figure('visible','off') ;
  plot_ERPs_filter(runid_DA,pmoid,obs_string,day0,dayf,leg,hostname)
  title('No Assimilation')
fig2 = figure('visible','off') ;
  plot_ERPs_filter(runid_noDA,pmoid,obs_string,day0,dayf,leg,hostname)
  title('With LOD Assimilation')




%% export
fig_name_noDA = [runid_noDA,'_',obs_string,'_',num2str(day0),'_',num2str(dayf),'.png'];
fig_name_DA = [runid_DA,'_',obs_string,'_',num2str(day0),'_',num2str(dayf),'.png'];

pw = 12;
ph = 10;
fs = 6;

exportfig(fig1,fig_name_DA,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
exportfig(fig2,fig_name_noDA,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)

