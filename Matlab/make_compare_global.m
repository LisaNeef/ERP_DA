%function make_compare_global(E,hostname,plot_name)
%% 
%
% Compare the reduction in RMS error in the U and V fields, for 
% perfect-model experiments assimilating radiosondes and assimilating 
% ERPs
%
%
% Lisa Neef, 17 June 2013
%
% MODS:
%  29 Jul 2013: make the input variable more simple -- their codes to the 
%     read by diagnostic_quantities.m
%  15 Aug 2013: export an eps image instead of png%
%   4 oct 2013: instead of making exp_list an input, make it a large structure E,
%		which contains all the desired experiments
%		Also simplify the rest of the input
%----------------------------------------------------------------------

%--inputs if not running as a function------
EE = load_experiments;
E = EE([1,3]);
for ii = 1:length(E)
  E(ii).diff = 0;
  E(ii).dayf = E(ii).day0+80;
end
hostname = 'blizzard';
plot_name = 'U300_global_error_ERPALL';
%--------------------------------------------

nX = length(E);

%% various plot settings
C = colormap(lines(nX));
C(1,:) = zeros(1,3);

%% make the plots

figure(1),clf
h = zeros(1,nX);
hold on

for ii = 1:nX
  h(ii) = plot_diagn_in_time(E(ii),hostname,C(ii,:));
end

title([E(ii).copystring,' ',E(ii).diagn,', ',E(ii).variable,', ',num2str(E.level),'hPa'])


legend(h,E.exp_name,'Location','SouthEast')
xlim = get(gca,'Xlim');
set(gca,'XTick',[xlim(1):14:xlim(2)])
datetick('x','dd-mmm','keeplimits','keepticks')



%% export this plot

  pw = 10;
  ph = 10;

  % paper and export settings
  % when exporting with export_fig, the following two commands
  % determine the aspect ratio of our figure, as well as the relative
  % font size (larger paper --> smaller font)
  pos = get(gcf,'Position');
  set(gcf, 'Position',[pos(1),pos(2),pw,ph])

  fig_name = [plot_name,'.eps'];
  disp(['Creating figure  ',fig_name])
  fs = 2.5;
  exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs)

