function make_compare_10dayerror_PS(exp_list,hostname)
%
% Make plots of the true error at 10 days in the main assimilation experiments.
%
% Lisa Neef,  1 July 2013
%
%----------------------------------------------------------------------


%% define the experiments we want to compare as structures
E_all = load_experiments;
E = E_all(exp_list);
nX = length(E);

%% some figure settings 
ph = 2*7;
pw = 2*15;
fs = 1.5;

%% loop over the experiments and make the plot
figure(1),clf

for iX = 1:nX
  E(iX).dayf = E(iX).start+10;
  E(iX).variable = 'PS';

  subplot(2,ceil(nX/2),iX)
  plot_lat_lon_daily(E(iX),'blizzard')
  title([E(iX).exp_name, ': 10-day Error U(300hPa)'])
%  set(gca,'Clim',[-30,30])
  colorbar

end

% export it!
fig_name = 'compare_PS_10dayerror.png';
disp(fig_name)
exportfig(1,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
