%% make_spurious_correl_plots.m
%
% make various plots that show where the distance to the truth is decreased by assimiilation 
% (=good correlations), or increased by assimilation (=bad correlations).
%
% Lisa Neef, 31 July 2012
%---------------------------------------------------------------------

clear all;
clc;

% inputs
run             = 'ERP3_2001_N64_UVPS';
VV 		= {'U';'V';'PS'};
LL 		= [300,300,0];
hostname        = 'blizzard';

%% choose plot type

%plot_type = 1;		% 1: plot diff every day for first 7 days of assimilation
%plot_type = 2;		% 2: plot diff averaged over first 7 days of assimilation
plot_type = 3;		% 3: plot diff averaged over first 2 months of assimilation

%% settings for each plot type

switch plot_type
  case 1
    GD = 146097:1:146104;
    pdim = [2,4];
    plot_averages = 0;	% flag for whether we want to plot individual dates, or averages.
    pw = 35;
    ph = 18;
  case 2
    GD = 146097:1:146104;
    pdim = 1;
    plot_averages = 1;	% flag for whether we want to plot individual dates, or averages.
    pw = 20;
    ph = 20;
  case 3
    GD = 146097:1:146153;
    pdim = 1;
    plot_averages = 1;	% flag for whether we want to plot individual dates, or averages.
    pw = 20;
    ph = 20;
end

%% cycle over variables to plot and make the required figs and subplots

% how many figures / subplots do we have?
nfig = length(VV);
if length(pdim) == 1
  nplots = 1;
else
  nplots = pdim(1)*pdim(2);
end

% loop over figures
for ifig = 1:nfig

  % define figure name
  fig_pref = 'true_error_innovation_';
  v = char(VV(ifig));
  lev = num2str(LL(ifig));
  if plot_averages
    fig_name = [fig_pref,v,lev,'_ave',num2str(GD(1)),'-',num2str(max(GD)),'_',run,'.png'];
  else
    fig_name = [fig_pref,v,lev,'_evol',num2str(GD(1)),'-',num2str(max(GD)),'_',run,'.png'];
  end


  % initialize figure
  figH = figure('visible','off');

  % loop over subplots
  h = zeros(nplots);
  for ii = 1:nplots
    if nplots == 1
      h(ii) = gca;
    else
      h(ii) = subplot(pdim(1),pdim(2),ii);
    end

    if plot_averages
      plot_innov_dist_to_truth(run,v,LL(ifig),GD,hostname);
      title(['Average ',num2str(GD(1)),'-',num2str(max(GD))]);
    else
      plot_innov_dist_to_truth(run,v,LL(ifig),GD(ii),hostname);
      title([num2str(GD(ii))]);
    end
  end

  % make the axes look nicer
  nrows = pdim(1);

  x0 = 0.1;
  y0 = 0.90;
  dy = 0.05;
  dw = 0.05;
  if nplots > 1
    w = (1-pdim(2)*dw-x0)/pdim(2);               % width per figure
  else
    w = 1-dw-x0;
  end
  ht = (y0-(nrows)*dy)/nrows;          % height per figure

  row = 1;
  col = 1;
  for k = 1:nplots
    % advance the row of plots of needed
    if nplots > 1
      if k == pdim(2)+1
        row = row+1; 
        col = 1;
      end
    end
    y = y0 - row*ht - (row-1)*dy;
    x = x0 + (col-1)*w  + (col-1)*dw;
    set(h(k),'Position',[x y w ht])
    col = col+1;
  end

  
  % export this plot
  exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
  close(figH)

  % report it to the screen
  disp(['Created plot  ',fig_name])

end

