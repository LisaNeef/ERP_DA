function plot_ensemble_in_time(E,hostname,special_diagnostic)
%% plot_ensemble_in_time.m
%
% Plot the evolution of the posterior ensemble in state space, averaged
% over some region, in time, along with the truth
% and the ensemble mean.
%
% INPUTS:
%  E: the assimilation experiment and posssible lat/lon/lev ranges
%  hostname: currently only supporting blizzard
%  special_diagnostic: special quantities to look at.  Currently only supporting:
%	NAO: the NAO station index (ps difference between Lisbon and Reykjavik)
%	none: just use the specified lat/lon/lev ranges and variables
%
% Lisa Neef, 9 Oct 2013
%
% MODS:
%  10 Oct 2013: add the option of plotting NAO index
%-----------------------------------------------------------------------------

testplot = 0;
%---temporary inputs
%EE = load_experiments;
%E = EE(3);
%E.variable = 'PS';
%hostname = 'blizzard';
%E.diagn = 'Posterior';
%testplot = 1;
%special_diagnostic = 'NAO';
%---temporary inputs

%% Retrieve the ensemble and the true state
Etr = E;
Etr.diagn = 'Truth';
switch special_diagnostic
  case 'none' 
    [Ens,t] = get_ensemble_in_time(E,hostname);
    [Tr,ttr] = get_ensemble_in_time(Etr,hostname);
    YL = E.variable		% y-axis label
  case 'NAO' 
    [Ens,t] = get_NAOindex_ensemble(E,hostname);
    [Tr,ttr] = get_NAOindex_ensemble(Etr,hostname);
    YL = 'NAO Index'
end

Em = mean(Ens,1);


%% make a matlan datenum time axis
ref_day = datenum(1601,1,1,0,0,0);
t2 = t+ref_day;
ttr2 = ttr+ref_day;


%% Initialize plot
if testplot
  figure(1),clf
end
gray = 0.7*ones(1,3);
coltr = [0,0,1];
LW = 2;




%% Plot!
h = zeros(1,3);
dum = plot(t2,Ens,'Color',gray,'LineWidth',1);
h(3) = dum(1);
hold on
h(2) = plot(t2,Em,'Color',0.5*gray,'LineWidth',LW);
h(1) = plot(ttr2,Tr,'Color',coltr,'LineWidth',LW);
ylabel(YL)
set(gca,'Xlim',[t2(1),max(t2)])
datetick('x','dd-mmm','keeplimits','keepticks')
legend(h,'Truth','Analysis','Ensemble','Orientation','Horizontal','Location','South')
legend('boxoff')


%% export if this is a testplot
if testplot
  title(E.exp_name)

  ph = 5;
  pw = 7;
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  dum = strsplit(E.run_name,'/');
  fig_name = 'test_.eps';
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)

end

