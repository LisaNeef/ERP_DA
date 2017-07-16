function plot_lat_time(E, hostname)
%% plot_lat_time.m
%
% Make a plot of a variable as a function of latitude and time.
% Right now equipped for variables U and PS, and AAM excitation functions
% X1, X2, and X3, using either ERA-Interim data or DART-CAM output.
%
%
% Lisa Neef, 30 Nov 2011.
%
%  INPUTS:
%  E: a structure holding all the experiment details and what we want to show.
%   these are the field names
%    run_name:
%    truth:
%    copystring:
%    variable:
%    level:
%    AAM_weighting:
%    diagn:
%    day0:
%    dayf:
%
%  hostname: presently only supporting 'blizzard'

% Mods:
%  30 JAN: added customizable start and finish days (using the DART gregorian day count.)
%   2  Feb 2012: add the option of Po_minus_Tr as a diagnostic.  In this
%   case, copystring is automatically selected to be _______
%   20 Mar 2012: instead of plotting option 'ABSPo-Tr', do RMSE (where the
%   mean is over longitude in this case.)
%   11 Apr 2012: several cosmetic changes
%   25 Apr 2013: add as input the experiment subdirectory name, to accommodate my new run setup
%   25 Apr 2013: add 'E.truth' as an input -- the run name where the true state for this run is.
%                can just leave blank if not plotting RMSE
%   25 Apr 2013: took out the ERA-Interim comparison stuff because it relies on files I don't have
%		 anymore -- can always add back in later.
%   26 Apr 2013: various other changes to accomodate the new file format in the runs done with Kevin, 2013
%    7 Jun 2013: simplified the input of the run identifier to a single name - this means that, given how 
%	the DART script organizes the output, this name is comprised of the main directory on scratch where
%	the run sits, and the subfolder, usually called somethingl like 'Exp1'
%   10 Jun 2013: make things simpler by making the input experiment a structure, with all the various settings
%		that we want in the plot as part of the strucutre.
%   10 Jun 2013: make it so that contour limits are set externally.
%   22 June 2013: updated path to list of true state files to suit new experiment structure/
%   19 Aug 2013: change up the colormap
%   22 Aug 2013: change to an NCL colormap
%--------------------------------------------------------------------------------------------------------------

testplot = 0;

% temporary inputs if not running as a function:
%clear all; clf;
%testplot = 1;
%hostname = 'blizzard';
%E_all = load_experiments;
%E = E_all(3);
%vv = 'U300';
%E.diagn = 'Innov';
%E.copystring = 'ensemble mean';
%[variable,level,latrange,lonrange] = diagnostic_quantities(vv);
%E.variable = variable;
%E.latrange = latrange;
%E.level = level;
%E.lonrange = lonrange;
%E.day0 = 149019;
%E.dayf = 149019+31+28+10;

%% other paths, etc.
%
% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end

% some built in checks
if ((strcmp(E.variable,'U') && E.level == 0) || (strcmp(E.variable,'V') && E.level == 0))
  disp('cannot have level 0 with wind field....abort.')
  return
end

switch E.diagn
    case 'Truth'
        rundir = [DART_output,E.run_name,'/postprocess/'];
        list = 'true_state_files';
        E.copystring = 'true state';
    case 'Prior'
        rundir = [DART_output,E.run_name,'/postprocess/'];
        list = 'prior_state_files';
    case 'Posterior'
        rundir = [DART_output,E.run_name,'/postprocess/'];
        list = 'posterior_state_files';
    case 'Innov'
        rundir = [DART_output,E.run_name,'/postprocess/'];
        list = 'innov_state_files';
    case 'RMSE'
        rundir = [DART_output,E.run_name,'/postprocess/'];
        list = 'po_minus_tr_files';
        E.copystring = ' ';
    otherwise
        disp([E.diagn,'  is not a valid diagnostic.'])
        return
end


%% Retrieve some information about this run.
if exist([rundir,list],'file') < 2
    disp(['cannot find file ',rundir,list])
    return
end


flist = textread([rundir,list],'%s');
if strcmp(E.diagn,'Truth')
  ff_sample = char(flist(1))  ;
else
  ff_sample = [rundir,char(flist(1))]  ;
end
pinfo = CheckModel(ff_sample);

ens_size = pinfo.num_ens_members;

%% Fetch the data
[VAR,t,lat] = get_lat_time_DART_CAM(E,hostname);



%% Plot settings
ncontours = 10;

% default colormap default: rainbow with center zero
cmap = read_ncl_colors('blue_white_orange_red');

% if looking at the spread, and not innovation, want a progressive colormap 
if strcmp(E.copystring,'ensemble spread') && ~strcmp(E.diagn,'Innov') 
  cmap = seq_yellow_green_blue9;
end

% same goes for if looking at the rms error 
if strcmp(E.diagn,'RMSE')  
  cmap = seq_yellow_green_blue9;
end

% compute X-ticks for the first of each month
[y0,m0,d0] = gregorian_to_date(E.day0,0);
xtick_monthly = zeros(1,12);
for m = 1:12
   xtick_monthly(m) = datenum(y0,m,1,0,0,0);
end


%% If it's DART output, convert t from Gregorian to a number that works for matlab datenum

ref_day = datenum(1601,1,1,0,0,0);
t2 = t+ref_day;

% Also get the axis limits as the input start and end dates, in Matlab
% style.
t0 = E.day0+ref_day;
tf = E.dayf+ref_day;

%% Plot settings

[X,Y] = meshgrid(t2,lat);


%% Plot!

  contourf(X,Y,VAR,ncontours,'LineColor','none')
  colormap(cmap)

  % even out the color limits for divergent plots
  if strcmp(E.diagn,'Innov') || strcmp(E.diagn,'RMSE') 
    cc = get(gca,'Clim');
    set(gca,'Clim',max(cc)*[-1,1])
  end

  
  xticks = t0:14:tf;
  set(gca,'XTick',xticks)
  datetick('x','dd-mmm','keeplimits','keepticks')
  hbar = colorbar('Location','EastOutside');
  %xlabel('time')
  ylabel('Latitude')
  grid on

%title and plot labels
ylim = get(gca,'YLim');
axis([t0 tf ylim(1) ylim(2)]);

%% export this plot

if testplot 
  
  pw = 10;
  ph = 5;

  % paper and export settings
  set(gcf, 'PaperUnits','inches')
  set(gcf, 'Units','inches')
  set(gcf, 'PaperSize', [pw ph]);
  set(gcf, 'PaperPositionMode', 'manual');
  set(gcf, 'PaperPosition', [0 0 pw ph]);
  set(gcf, 'renderer', 'painters');
  % when exporting with export_fig, the following two commands
  % determine the aspect ratio of our figure, as well as the relative
  % font size (larger paper --> smaller font)
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  dum = strsplit(E.run_name,'/');
  dum2 = strrep(E.copystring,' ','_');

  fig_name = [char(dum(1)),'_',E.diagn,'_',dum2,'_',E.variable,num2str(E.level),'_lat_time.eps'];
  fs = 1.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)
end
