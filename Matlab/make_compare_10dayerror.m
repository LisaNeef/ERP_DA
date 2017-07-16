function make_compare_10dayerror(exp_list,hostname,vv,diagn,plot_name)
%
% Make plots of the true error at 10 days in the main assimilation experiments.
%
% Lisa Neef,  1 July 2013
%
% Mods: 
%  31 Jul 2013:  adapting code to new diagnostic variable protocol
%  31 Jul 2013:  make it possible to externally specify the diagnostic to be plotted
%----------------------------------------------------------------------


%% define the experiments we want to compare as structures
E_all = load_experiments;
E = E_all(exp_list);
nX = length(E);

%% variable settings
[variable,level,latrange,lonrange] = diagnostic_quantities(vv);

for iX = 1:nX
  E(iX).variable = variable;
  E(iX).level = level;
  E(iX).latrange = latrange;
  E(iX).lonrange = lonrange;
  E(iX).diagn = diagn;
end


%% loop over the experiments and make the plot
figure(1),clf
nR = 2;
nC = ceil(nX/2);
h = zeros(1,nX);
clim = zeros(nX,2);

for iX = 1:nX
  E(iX).dayf = E(iX).start+9;

  h(iX) = subplot(nR,nC,iX);
  plot_lat_lon_daily(E(iX),'blizzard')
  title(E(iX).exp_name)
  colorbar

  clim(iX,:) = get(gca,'Clim');
end

%% unify the color limits
cc = [min(min(clim)),max(max(clim))];
for iX = 1:nX
  set(h(iX),'Clim',cc)
end

%% make the axes suck less


x0 = 0.1;
y0 = 0.99;
dx = 0.1;
dy = 0.05;
dbar = 0.6;
width = (1-x0-nC*dx)/nC;
height = (y0-nR*dy-dbar)/nR;

ii = 1;
for iC = 1:nC
  for iR = 1:nR
    if ii <= nX
      x = x0+(iC-1)*(width+dx);
      y = y0-iR*(height+dy);
      set(h(ii),'Position',[x y width height])
      ii = ii+1;
    end
  end
end


% export it!
ph = 8*nR;
pw = 5*nC;
fs = 1;

set(gcf,'units','inches')
pos = get(gcf,'Position');
set(gcf, 'Position',[pos(1),pos(2),pw,ph])
set(gcf, 'renderer', 'painters');
fig_name = ['compare_',variable,num2str(level),plot_name,'_10dayerror.eps'];

disp(['Exporting figure ',fig_name])


exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

