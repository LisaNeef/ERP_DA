%% paper figure showing as an example the error reduction in zonal wind  
% as a function of space and time, when we assimilate ERPs.  
%
% 21 Jan 2014
%-------------------------------------------------------------------------------

hostname = 'blizzard';

%% define the experiments we want to compare as structures
E_all = load_experiments;
P = [E_all(3),E_all(3),E_all(3)];
EnoDA = E_all(1);

P(1).variable = 'PS';
P(2).variable = 'U';
P(2).level = 300;
P(3).variable = 'U';

P(1).plot_type = 'lat_time_diff';
P(2).plot_type = 'lat_time_diff';
P(3).plot_type = 'lev_time_diff';

P(1).title = 'Surface Pressure Error Reduction'  
P(2).title = 'U(300hPa) Error Reduction'  
P(3).title = 'U Error Reduction'  

%% define overall plot settings
nP = length(P);
for iP = 1:nP
  P(iP).day0 = 149020;
  P(iP).dayf = 149020+31+28;
  P(iP).cbar = 1;
end

%% make the plots

figure(1),clf

% cycle over the different plot types and make a column of plots

for iP = 1:nP

  subplot(nP,1,iP)
  switch P(iP).plot_type
    case 'lat_time_diff'
      plot_lat_time_diff(P(iP),EnoDA,hostname)
    case 'lev_time_diff'
      plot_height_time_diff(P(iP),EnoDA,hostname)
  end

  title(P(iP).title)
 

  xlim = get(gca,'Xlim');
  set(gca,'XTick',[xlim(1):14:xlim(2)])
  datetick('x','dd-mmm','keeplimits','keepticks')
  %set(gca,'Clim',clim)


end

%% export this plot

  pw = 8;
  ph = 10;

  %pos = get(gcf,'Position');
  %set(gcf, 'Position',[pos(1),pos(2),pw,ph])

fig_name = 'error_red_in_space_and_time.eps';
fs = 1.5;
exportfig(1,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)

