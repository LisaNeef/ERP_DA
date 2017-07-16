function plot_ER_in_time(RR,run_names,noDArun,day0,dayf,variable,level,copystring,latrange,hostname)
% Make a plot of the error reduction in a certain run (integrated
% over a certain latitude range), relative to a specified no-DA run.
%
% Lisa Neef, 31 May 2012
%
%



%% temporary inputs
%clear all;
%clc;
%RR      = {'ERP1_2001_N64_UVPS_comp_time_test'};
%noDArun = 'ERPALL_2001_noDA';
%day0    = 146097;
%dayf    = 146198;
%variable = 'U';
%level 	= 300;
%copystring = 'ensemble mean';
%latrange = [-90,90];
%hostname = 'blizzard';
%run_names = 'PM1';

%% initialize arrays 

diagn   = 'RMSE';

nt = dayf-day0;
nruns = length(RR);

D = zeros(nruns,nt*3)+NaN;
T = zeros(nruns,nt*3)+NaN;

ref_day = datenum(1601,1,1,0,0,0);
t0 = day0+ref_day;
tf = dayf+ref_day;


% load the data for each run.

    % error in the no-DA run.
   [dd_noDA,tt] = get_diagn_in_time(noDArun,diagn,copystring,level,variable,day0,dayf,latrange,hostname);         
 
   for irun = 1:nruns
        mainrun = char(RR(irun));
        [dd,tt] = get_diagn_in_time(mainrun,diagn,copystring,level,variable,day0,dayf,latrange,hostname);
        T(irun,1:length(tt)) = tt+ref_day;
        D(irun,1:length(tt)) = dd-dd_noDA;
    end


col = jet(nruns);
plot_title = 'Error Reduction in Time';

switch variable
	case {'U','V'}
		y_label = 'ER (m/s)';
	case 'PS'
		y_label = 'ER (hPa)';
end

%% make the plot.


  LH = zeros(1,nruns);
  
  for irun = 1:nruns
    D2 = squeeze(D(irun,:));
    T2 = squeeze(T(irun,:));
    nt = length(D2);
    LH(irun) = plot(T2(2:nt),D2(2:nt),'o-','Color',col(irun,:),'LineWidth',2);
    hold on
  end

  % add a line at zero, since we want to be under zero
  plot(T2,T2*0,'--','LineWidth',4,'Color',0.5*ones(1,3))

  ylim = get(gca,'YLim');
  axis([t0 tf ylim(1) ylim(2)]);

  datetick('x','dd-mmm','keeplimits','keepticks')
  legend(LH,run_names,0)    
  legend('boxoff')
  ylabel(y_label)

  %title and plot labels
  title(plot_title)

