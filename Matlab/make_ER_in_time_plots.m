%% make_ER_in_time_plots.m
%
% Make various plots comparing different experiment settings in terms of 
% error reduction in time.
%
% Lisa Neef, 1 June 2012

clear all;
clc;


%% choose plot type    

hostname = 'blizzard';
%plot_type = 1;		% 1: compare different obs types and loop over all three control variables.
plot_type = 2;		% 2: compare different control vector configurations
%plot_type = 3;		% 3: look at error reduction in temp for cases where it's part of the CV.


%% plot settings

switch plot_type
    case 1
	RR      = {'ERPALL_2001_N64_UVPS_V2';'ERP1_2001_N64_UVPS_comp_time_test';'ERP2_2001_N64_UVPS_V2';'ERP3_2001_N64_UVPS'};
	noDArun = 'ERPALL_2001_noDA';
	day0    = 146097;
	dayf    = 146298;
	V       = {'U','V','PS'};
	LL       = [300,300,0];
	copystring = 'ensemble mean';
	latrange = [-90,90];
	run_names = {'Obs. all','Obs. \chi_1','Obs. \chi_2','Obs. \chi_3'};
	fig_name_pref = 'compare_ER_DAvariable';
        fig_labels = V;
    case 2
	RR      = {'ERP1_2001_N64_UVPS_comp_time_test';'ERP1_2001_N64_UVPST'};
	noDArun = 'ERPALL_2001_noDA';
	day0    = 146097;
	dayf    = 146171;
	V       = {'U','V','PS'};
	LL       = [300,300,0];
	copystring = 'ensemble mean';
	latrange = [-90,90];
	run_names = {'u,v,p_s','u,v,p_s,T'};
	fig_name_pref = 'compare_ER_ctrlvector';
        fig_labels = V;

end

%% make the plot

nvar = length(V);
fig_handles = zeros(nvar,1)+NaN;

for ivar = 1:nvar
	variable = char(V(ivar));
	level = char(LL(ivar));

        fig_handles(ivar) = figure('visible','off') ;
	plot_ER_in_time(RR,run_names,noDArun,day0,dayf,variable,level,copystring,latrange,hostname)

        % annotation.
  	ylim = get(gca,'YLim');
  	xlim = get(gca,'XLim');
  	dxlim = xlim(2)-xlim(1);
  	dylim = ylim(2)-ylim(1);
        text(xlim(1)+.02*dxlim,ylim(1)+0.9*dylim,char(fig_labels(ivar)),'FontSize',16)

end

%% add annotation, fix the axes, etc.


%% plot/export settings
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


%% export.

%% EXPORT -- eventually move this out into a wraparound code.

latstring = [num2str(latrange(1)),'_',num2str(latrange(2))];


for ivar = 1:nvar

    fig_name = [fig_name_pref,'_',char(V(ivar)),num2str(LL(ivar)),'_',latstring,'.png'];
    exportfig(fig_handles(ivar),[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','format','png');

    if strcmp(hostname,'blizzard')
        close(fig_handles(ivar)) ;
    end

end


