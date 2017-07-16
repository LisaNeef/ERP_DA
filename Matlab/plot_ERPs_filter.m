function plot_ERPs_filter(E,obs_string,include_legend,hostname)
%% plot_ERPs_filter.m
%
%  Plot AEFs in DART-CAM oHutput, comparing prior and posterior and, if
%  available, truth.
%
%  This file uses the "obs_diag_output.nc" file, which is created using the
%  program obs_diag.
%
%  Lisa Neef
%  Started 7 Dec 2011
%
%  Mods:
%     16 Mar 2012: convert to a function, to be called by an external code.
%     30 Mar 2012: make it possible to run this on blizzard as well.
%     13 Feb 2013: cosmetic changes, and make it possible to export just a single plot.
%     17 Jul 2013: major overhaul to suit the new experiments
%     10 Sep 2013: remove day0 and dayf as external inputs -- these are included in the input experiment structure.
%     18 Sep 2013: cosmetic revisions
%----------------------------------------------------------------------

testplot = 0;

% -----temp inputs-----
%clear all;
%clc;
%testplot = 1;
%E_all = load_experiments;
%E = E_all(1);
%obs_string = 'ERP_PM2';
%day0 = 149020;
%dayf = day0+14;
%include_legend = 1;
%hostname = 'blizzard';
% -----temp inputs-----

%-----------------------------------------------------

%% Other paths and stuff that DART scripts want.
switch hostname
    case 'blizzard'
        datadir = '/work/scratch/b/b325004/DART_ex/';
end

%% other inputs that read_obs_netcdf.m needs:
region        = [0 360 -90 90 -Inf Inf];
QCString      = 'Quality Control';
verbose       = 1;   % anything > 0 == 'true'

%% Read in the observation diagnostics files from the assimilation run

%ff = [datadir,E.run_name,'/postprocess/','obs_diag_output.nc'];
flist = dir([datadir,E.run_name,'/postprocess/','obs_epoch*']);
nf = length(flist);
if nf == 0
  disp(['cannot find obs epoch files for',E.run_name]);
  return
end

%% initialize arrays
ff0 = [datadir,E.run_name,'/postprocess/',flist(1).name];
obs = read_obs_netcdf(ff0, obs_string, region,'observations', QCString, verbose);
time = obs.time;
nt = nf*length(time);		% assumming all epoch files have the same length.
N = E.ens_size;

Y	= zeros(1,nt)+NaN;	% observations 		
XT	= zeros(1,nt)+NaN;	% truth
T	= zeros(1,nt)+NaN;	% time
%XEpo	= zeros(N,nt)+NaN;	% analysis ensemble
XEpr	= zeros(N,nt)+NaN;	% analysis ensemble

%% translate the start and end dates to matlab datenum format
[y0,m0,d0] = gregorian_to_date(E.day0,0);
[yf,mf,df] = gregorian_to_date(E.dayf,0);
t0 = datenum(y0,m0,d0);
tf = datenum(yf,mf,df);

%% cycle through output diagnostics

k1 = 1;
for ii = 1:nf
  ff = [datadir,E.run_name,'/postprocess/',flist(ii).name];
  truth = read_obs_netcdf(ff, obs_string, region,'truth', QCString, verbose);
  disp(ff)

  % if this fits into our time window, read the obs and all the ensemble members
  if (truth.time(1) >= t0) && (truth.time(1) <= tf)
    obs = read_obs_netcdf(ff, obs_string, region,'observations', QCString, verbose);

    % fill in 
    k2 = k1+length(obs.time)-1;
    Y(k1:k2) = obs.obs';
    XT(k1:k2) = truth.obs';
    T(k1:k2) = obs.time;

    % load the individual ensemble members
    for iens = 1:N
      copystring_pri = ['prior ensemble member     ',num2str(iens)];
      dum_pri = read_obs_netcdf(ff, obs_string, region,copystring_pri, QCString, verbose);
      XEpr(iens,k1:k2) = dum_pri.obs';
    end

    % move the index forward
    k1 = k2+1;

  end
end

% load some Earth rotation constants
aam_constants_gross;
switch obs_string
    case {'ERP_PM1'}
        fac = rad2mas;
        YL = '\chi_1 (mas)';
    case {'ERP_PM2'}
        fac = rad2mas;
        YL = '\chi_2 (mas)';
    case 'ERP_LOD'
        fac = LOD0_ms;
        YL = '\chi_3 (ms)';
end



%% set colors
% observations: red
obcol = [1 0 0];
% prior: gray
prcol = 0.7*ones(1,3); %gray
% truth: blue
trcol = [0,0,1];

%% Plot!

if testplot
  figure(1),clf
end

  penspr = plot(T,fac*XEpr,'Color',prcol);
  hold on
  %penspo = plot(T,fac*XEpo,'Color',pocol);
  ppr = plot(T,fac*mean(XEpr,1),'Color',0.5*prcol,'LineWidth',2);
  %ppo = plot(T,fac*mean(XEpo,1),'Color',0.5*pocol,'LineWidth',2);
  ptr	= plot(T,fac*XT,'Color',trcol,'LineWidth',2);
  pobs = plot(T,fac*Y,'o','Color',obcol,'LineWidth',1);
 
  ylabel(YL)
  grid on
  if include_legend
     lhandle = [ptr(1), pobs(1), ppr(1), penspr(1)];
     legend(lhandle, 'Truth','Obs','Analysis' ,'Ensemble','Orientation','Horizontal','Location','South');
     legend('boxoff')
  end

  % adjuts the x limits based on tmax
  set(gca,'XLim',[T(1),max(T)])

  % set xticks to something that doesn't suck
  time_range = max(T)-min(T);
  if time_range <= 10
    set(gca,'XTick',T(1):2:max(T))
  else
    set(gca,'XTick',T(1):15:max(T))
  end
  set(gca,'XTickLabelMode','auto')
  datetick('x','dd-mmm','keepticks')

  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  dxlim = xlim(2)-xlim(1);
  dylim = ylim(2)-ylim(1);

  if testplot
    parts = regexp(obs_string,'_','split');
    text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,parts(2))
  end


%% export if this code is run standalone
if testplot
  %set(gcf,'Renderer','painters')
  runid = strsplit(E.run_name,'/');
  fig_name = [char(runid(1)),'_',obs_string,'_',num2str(E.day0),'_',num2str(E.dayf),'.eps'];
  pw = 15;
  ph = 10;
  fs = 2;
  exportfig(1,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)
  disp(['exporting figure  ',fig_name])
end

  
  
