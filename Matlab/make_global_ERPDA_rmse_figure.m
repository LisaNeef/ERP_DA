%% make_global_ERP_figure.m
%
% Make a paper-quality figure showing the global benefit (or lack thereof) 
% of assimilating Earth rotation observations.
%
% Lisa Neef, 7 Feb 2014
%---------------------------------------------------------------------------


%% basic inputs
clear all;
clc;
hostname = 'blizzard';


%% define the plots that we want to make   
Eall = load_experiments;
Eua = Eall([1,3]);
Eub = Eall([1,3]);
Eps = Eall([1,3]);

% load a colormap that suits the number of experiments
nX = length(Eua);
col = jet(nX);

dayf = Eall(1).day0+28+30;

for ii = 1:length(Eua)
  Eua(ii).variable = 'U';
  Eua(ii).level = 300;
  Eua(ii).linestyle = '-';
  Eua(ii).panel = 1;
  Eua(ii).color = col(ii,:);
  Eua(ii).dayf = dayf;
  Eua(ii).exp_name = [Eua(ii).exp_name,num2str(Eua(ii).level),' hPa']

  Eub(ii).variable = 'U';
  Eub(ii).level = 1000;
  Eub(ii).linestyle = '--';
  Eub(ii).panel = 1;
  Eub(ii).color = col(ii,:);
  Eub(ii).dayf = dayf;
  Eub(ii).exp_name = [Eub(ii).exp_name,num2str(Eub(ii).level),' hPa']

  Eps(ii).variable = 'PS';
  Eps(ii).level = 0;
  Eps(ii).linestyle= '-';
  Eps(ii).panel = 2;
  Eps(ii).color = col(ii,:);
  Eps(ii).dayf = dayf;
end


%% put the experiments together by what panel they will go into
E1 = [Eua,Eub];
E2 = Eps;

T1 = 'Zonal Wind RMSE';
T2 = 'Surface Pressure RMSE';

%% initialize the figure
figure(1),clf


%% plots!

subplot(2,1,1)
    plot_diagn_in_time(E1,hostname)
    title(T1)

subplot(2,1,2)
    plot_diagn_in_time(E2,hostname)
    title(T2)


%% export

pw = 8;
ph = 10;
fig_name = 'global_ERPDA_rmse.eps';
fs = 1.2;
exportfig(1,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)

disp(['exporting figure ',fig_name])


