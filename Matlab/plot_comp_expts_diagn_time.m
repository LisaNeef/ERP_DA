%% plot_comp_expts_diagn_time.m
%
%  Make a plot comparing the change in some diagnostic as the assimilation progresses, for 
%  two or more experiments.
%
%  Started 13 Feb 2011
%


%% Inputs:
clear all;
hostname = 'blizzard';
%plot_type = 1;			% 1 = compare algorithm mods.
%plot_type = 2;			% 2 = compare ensemble sizes.
%plot_type = 3;			% 3 = compare winds at different model levels.
%plot_type = 4;			% 4 = compare the DART default to the (U,V,Ps) control vector.
%plot_type = 5;			% 5 = the most basic comparison: baseline run versus noDA + tobs
%plot_type = 6;			% 6 = compare various PMO simulations
%plot_type = 7;			% 7 = compare different code versions (for testing)
plot_type = 8;			% 8 = compare assimilation variable configurations
%plot_type = 9;			% 9 = compare assumed obs error, ERP1
%plot_type = 10;		% 10 = compare assumed obs error, ERP3
%plot_type = 11;		% 11 = compare different localization settings
%plot_type = 12;			% 12 = compare different obs inflation settings

        day0    = 146097;
        dayf    = 146153;


%% Define the properties for a specific plot type:

switch plot_type
    case 1
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERPALL_2001_N64_SR';
        r3 = 'ERPALL_2001_N64_sortinc';
        R = {r0;r1;r2;r3};
        run_names = {'no DA';'N64';'Spread Restoration';'Sorting Increments'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_filter_mods';
        plot_title = 'Distance to True State';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
    case 2
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N16';
        r2 = 'ERPALL_2001_N32';
        r3 = 'ERPALL_2001_N64_UVPS_V2';
        r4 = 'ERPALL_2001_N96';
        R = {r0;r1;r2;r3;r4};
        run_names = {'noDA';'N16';'N32';'N64';'N96'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_ens_size';
        plot_title = 'Distance to True State';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
    case 3
        r1 = 'ERPALL_2001_N64';
        r2 = 'ERPALL_2001_N64';
        r3 = 'ERPALL_2001_N64';
        r4 = 'ERPALL_2001_N64';
        r5 = 'ERPALL_2001_N96';
        r6 = 'ERPALL_2001_N96';
        R = {r1;r2;r3;r4;r5;r6};
        run_names = {'100 hPa';'200 hPa';'300 hPa';'500 hPa';'700 hPa';'900 hPa'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [100,200,300,500,700,900];
        V  = {'U','V'};
        fig_labels = {'U','V'};
        y_labels = {'m/s';'m/s'};
        fig_name_pref = 'compare_levels';
        plot_title = 'Distance to True State';
        nruns = length(R);
        col = jet(nruns);
    case 4
        r1 = 'ERPALL_2001_N64';
        r2 = 'ERPALL_2001_N64_UVPS';
        r3 = 'ERPALL_2001_noDA';
        R = {r1;r2;r3};
        run_names = {'DART CV';'U,V,Ps CV';'No DA'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [900,900,0];
        V  = {'U','V','PS'};
        fig_labels = {'U900','V900','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_control_vector';
        plot_title = 'Distance to True State';
        nruns = length(R);
        col = jet(nruns);
        col(3,:) = zeros(1,3);
    case 5
        r1 = 'ERPALL_2001_noDA';
        r2 = 'ERPALL_2001_N64_UVPS_V2';
        r3 = 'ERPALL_12H_2001_N64_UVPS';
        R = {r1;r2;r3};
        run_names = {'no DA';'24H DA';'12H DA'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_baseline';
        plot_title = '';
        nruns = length(R);
        col = flipud(summer(nruns));
        col(1,:) = zeros(1,3);
    case 6
        r1 = 'PMO_ERPALL_2001';
        r2 = 'PMO_ERPALL_12H_2001';
        R = {r1;r2};
        run_names = {'PMO 24H';'PMO 12H'};
        diagn        = 'Truth';
        copystring   = 'true state'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'(m/s)';'(m/s)';'(hPa)'};
        fig_name_pref = 'compare_PMO';
        plot_title = 'True State Sample Variable';
        nruns = length(R);
        col = cool(nruns);
        col(1,:) = zeros(1,3);
    case 7
        r1 = 'ERP3_2001_N64_UVPS';
        r2 = 'ERP2_2001_N64_UVPS_V2';
        R = {r1;r2};
        run_names = {'ERP 3';'ERP2 new'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_ERP2_versions';
        plot_title = 'Global-Average Distance to True State';
        nruns = length(R);
        col = flipud(summer(nruns));
        col(1,:) = zeros(1,3);
    case 8
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERPALL_2001_N64_UVPS_V2';
        r2 = 'ERP1_2001_N64_UVPS';
        r3 = 'ERP2_2001_N64_UVPS_V2';
        r4 = 'ERP3_2001_N64_UVPS';
        R = {r0;r1;r2;r3;r4};
        run_names = {'no DA';'ALL ERPs';'PM1 Only';'PM2 Only';'LOD Only'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300hPa','V300hPa','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_DAvariable';
        plot_title = '';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
        latrange = [-90,90];        
    case 9
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERP1_2001_N64_UVPS';
        r2 = 'ERP1_2001_N64_UVPS_R5';
        r3 = 'ERP1_2001_N64_UVPS_R1';
        r4 = 'ERP1_2001_N64_UVPS_R2';
        r5 = 'ERP1_2001_N64_UVPS_R3';
        r6 = 'ERP1_2001_N64_UVPS_R4';
        r7 = 'ERP1_2001_N64_UVPS_R6';
        % R = {r0;r1;r2;r3;r4;r5;r6;r7};
        %run_names = {'no DA';'R = 0';'R = 1E-20';'R = 1E-18';'R = 1e-16';'R = 1e-14';'R = 1e-12';'R = 1e-10'};
        % take out all the runs that result in obs rejection
        R = {r0;r1;r2;r3;r4;r5};
        run_names = {'no DA';'R = 0';'R = 1E-20';'R = 1E-18';'R = 1e-16';'R = 1e-14'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_R_ERP1';
        plot_title = 'PM1 effect of Observation Variance';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
    case 10 
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERP3_2001_N64_UVPS';
        r2 = 'ERP3_2001_N64_UVPS_R1';
        r3 = 'ERP3_2001_N64_UVPS_R2';
        r4 = 'ERP3_2001_N64_UVPS_R3';
        r5 = 'ERP3_2001_N64_UVPS_R4';
        r6 = 'ERP3_2001_N64_UVPS_R5';
        r7 = 'ERP3_2001_N64_UVPS_R6';
        %R = {r0;r1;r7;r2;r3;r4;r5;r6};
        %run_names = {'no DA';'R = 0';'R = 1e-18';'R = 1E-16';'R = 1e-14';'R = 1e-12';'R = 1e-10';'R = 1e-8'};
        % take out all the runs that result in obs rejection
        R = {r0;r1;r7;r2};
        run_names = {'no DA';'R = 0';'R = 1e-18';'R = 1E-16'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_R_ERP3';
        plot_title = '';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
    case 11 
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERP2_2001_N64_UVPS_V2';
        r2 = 'ERP2_2001_N64_GC0p32';
        r3 = 'ERP2_2001_N64_GC0p46';
        r4 = 'ERP2_2001_N64_GC0p58';
        r5 = 'ERP2_2001_N64_GC0p68';
        r6 = 'ERP2_2001_N64_GC1p57';
        r7 = 'ERP2_2001_N64_GC3p14';
        R = {r0;r1;r2;r3;r4;r5;r6;r7};
        run_names = {'no DA';'PM2';'PM2, Loc 0.32';'PM2, Loc 0.46';'PM2, Loc 0.58';'PM2, Loc 0.68';'PM2, Loc 1.57';'PM2, Loc 3.14'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_localization';
        plot_title = '';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
        latrange = [30,60];        
    case 12 
        r0 = 'ERPALL_2001_noDA';
        r1 = 'ERP2_2001_N64_UVPS_V2';
        r2 = 'ERP2_2001_N64_UVPS_obsinfl_adap_sd0p1';
        r3 = 'ERP2_2001_N64_UVPS_obsinfl_adap_sd0p5';
        R = {r0;r1;r2};
        %run_names = {'no DA';'PM2';'Obs. Infl. \sigma = 0.1';'Obs. Infl. \sigma = 0.5'};
        run_names = {'no DA';'PM2';'Obs. Infl. \sigma = 0.1'};
        diagn        = 'RMSEtrue';
        copystring   = 'ensemble mean'; 
        LL = [300,300,0];
        V  = {'U','V','PS'};
        fig_labels = {'U300','V300','PS'};
        y_labels = {'RMSE (m/s)';'RMSE (m/s)';'RMSE (hPa)'};
        fig_name_pref = 'compare_adap_obsinfl_ERP2';
        plot_title = '';
        nruns = length(R);
        col = jet(nruns);
        col(1,:) = zeros(1,3);
        latrange = [30,90];        

end


%% initialize arrays 

nt = dayf-day0;
nvar = length(V);

D = zeros(nvar,nruns,nt*3)+NaN;
T = zeros(nvar,nruns,nt*3)+NaN;

ref_day = datenum(1601,1,1,0,0,0);
t0 = day0+ref_day;
tf = dayf+ref_day;


%% loop through runs and load the data

for ivar = 1:nvar
    variable = char(V(ivar));
    if plot_type ~= 3
      level = LL(ivar);
    end

    for irun = 1:nruns
         run = char(R(irun))
         if plot_type == 3, level = LL(irun); end
         [dd,tt] = get_diagn_in_time(run,diagn,copystring,level,variable,day0,dayf,latrange,hostname);
         
         T(ivar,irun,1:length(tt)) = tt+ref_day;
         D(ivar,irun,1:length(tt)) = dd;

    end

    title(plot_title)

end



%% plot settings
LW = 2;
ph = 6;        % paper height
pw = 17;        % paper width
fs = 20;        % fontsize

switch hostname
    case 'blizzard'
        plot_dir = '/work/bb0519/b325004/DART/ex/Comparisons/';
    case 'ig48'
        plot_dir = '/home/ig/neef/Documents/Plots/ERP_DA/';
end
    

%% make the plot.

fig_handles = zeros(1,nvar)+NaN;

for ivar = 1:nvar
  LH = zeros(1,nruns);
  if strcmp(hostname,'blizzard')
      fig_handles(ivar) = figure('visible','off') ;
  else
      fig_handles(ivar) = figure(ivar);clf
  end
  for irun = 1:nruns
    D2 = squeeze(D(ivar,irun,:));
    T2 = squeeze(T(ivar,irun,:));
    LH(irun) = plot(T2,D2,'o-','Color',col(irun,:),'LineWidth',2);
    variable = char(V(ivar));
    if strcmp(variable,'PS')
        set(gca,'YLim',[50 175])
    end

    hold on
  end
  datetick('x','dd-mmm','keeplimits')
  %legend(LH,run_names,'Location','SouthEast')    
  legend(LH,run_names,0)    
  legend('boxoff')
  ylabel(y_labels(ivar))

  %title and plot labels
  title(plot_title)
  ylim = get(gca,'YLim');
  axis([t0 tf ylim(1) ylim(2)]);
  xlim = get(gca,'XLim');

  dxlim = xlim(2)-xlim(1);
  dylim = ylim(2)-ylim(1);

  text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,char(fig_labels(ivar)),'FontSize',16)


end


%% export

latstring = [num2str(latrange(1)),'_',num2str(latrange(2))];


for ivar = 1:nvar
  
    if plot_type == 3
        fig_name = [fig_name_pref,'_',char(V(ivar)),'_',latstring,'.png'];
    else
        fig_name = [fig_name_pref,'_',char(V(ivar)),num2str(LL(ivar)),'_',latstring,'.png'];
    end
    exportfig(fig_handles(ivar),[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');

    if strcmp(hostname,'blizzard')
        close(fig_handles(ivar)) ;
    end

end
