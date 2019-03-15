%Plot figure with all data points as a scatter plot


load('A3_TimeSeriesCalcs.mat','struct_results','regions')


clear figure
fig = figure;
ax = axes;

% if you want to select a single year, do it here - note for these figures,
% only years between 36 and 56 make sense (there are more than 2 model
% observations)
year_select=logical(zeros(57,1)); %init
year_select(:)=1; % all years
% year_select(56)=1; % one year
%%%
% if you want to select a single country, do it here - note for these figures,
% only countries >9 are individual countries
country_select=logical(zeros(1,70)); %init
% country_select(:)=1; % all countries
country_select(11)=1; % one country


% transform representation to log form
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')

%obtain rsd, mean and number of observations
%regions.unique_country - logical to extract individual country observations and not country aggregates:
plot_norm_p_rsd=[struct_results.raw.p(regions.unique_country).rsd];
plot_p_mean=[struct_results.raw.p(regions.unique_country).mean];
plot_p_n=[struct_results.raw.p(regions.unique_country).n];

%only plot sensible values (log transformation will occur) and when 3 data
%points
filterx=(plot_norm_p_rsd)>=1e-5 & (plot_p_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;

plot_p_y1=plot_norm_p_rsd(filterx);
plot_p_x1=plot_p_mean(filterx);

% plot_p_y1=plot_p_rsd.*filterx;
% plot_p_x1=plot_p_mean.*filterx;

hold all
plot_c_rsd=[struct_results.raw.c(regions.unique_country).rsd];
plot_c_mean=[struct_results.raw.c(regions.unique_country).mean];
plot_c_n=[struct_results.raw.c(regions.unique_country).n];

filterx=(plot_c_rsd)>=1e-5 & (plot_c_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_c_y2=plot_c_rsd(filterx);
plot_c_x2=plot_c_mean(filterx);

% set up x-values (on a log-spaced vector for plotting)
MIN_VALUE = 0.1;
MAX_VALUE = 1e5;
NUM_POINTS = 200;
xspace = logspace(log10(MIN_VALUE), log10(MAX_VALUE), NUM_POINTS);

% plot the values, (axis is log-transformed above)
h1=scatter((plot_p_x1),(plot_p_y1)','.')
h2=scatter((plot_c_x2),(plot_c_y2)','x')
% linear fit on log transformed data:
[pfit,gofp]=polyfit(log10(plot_p_x1),log10(plot_p_y1),1);
[ccit,gofc]=polyfit(log10(plot_c_x2),log10(plot_c_y2),1);
% obtain fitted line, based on log-spaced x values
pY=(pfit(1).*((xspace)))+pfit(2);
cY=(ccit(1).*((xspace)))+ccit(2);
 %plot exponents, as axis is transformed
h3=plot(10.^(xspace),10.^(pY),'b')
h4=plot(10.^(xspace),10.^(cY),'r')
hold on


hleg1=legend([h1,h2,h3,h4],[{'PBCA (raw)'}',{'CBCA (raw)'},{'PBCA  (raw)'},{'CBCA  (raw)'}])
xlabel('CO_2 (Gg)')
ylabel('Relative standard deviation')
axis square
grid on

xlim([1,max(plot_c_x2+2000)])
ylim([0.001,1])


%%
% Replot but this time with normalised results as well.
fig3 = figure;
ax3 = axes;

%obtain rsd, mean and number of observations
%regions.unique_country - logical to extract individual country observations and not country aggregates:
plot_norm_p_rsd=[struct_results.norm.p(regions.unique_country).rsd];
plot_norm_p_mean=[struct_results.norm.p(regions.unique_country).mean];

hold on
% transform representation to log form
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')

%only plot sensible values (log transformation will occur) and when 3 data
%points
filterx=(plot_norm_p_rsd)>=1e-5 & (plot_p_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_p_y3=plot_norm_p_rsd(filterx);
plot_p_x3=plot_norm_p_mean(filterx);

%CBCA values:
plot_norm_c_rsd=[struct_results.norm.c(regions.unique_country).rsd];
plot_norm_c_mean=[struct_results.norm.c(regions.unique_country).mean];

filterx=(plot_norm_c_rsd)>=1e-5;
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_c_y4=plot_norm_c_rsd(filterx);
plot_c_x4=plot_norm_c_mean(filterx);


[pfit,gofp]=polyfit(log10(plot_p_x3),log10(plot_p_y3),1);
[ccit,gofc]=polyfit(log10(plot_c_x4),log10(plot_c_y4),1);
pYnormalised=(pfit(1).*((xspace)))+pfit(2);
cYnormalised=(ccit(1).*((xspace)))+ccit(2);



h1=scatter((plot_p_x1),(plot_p_y1)','.');
h2=scatter((plot_c_x2),(plot_c_y2)','x');
h5=scatter((plot_p_x3),(plot_p_y3),'+');
h6=scatter((plot_c_x4),(plot_c_y4),'*');


h3=plot(10.^xspace,10.^(pY),'b')
h4=plot(10.^xspace,10.^(cY),'r')
h7=plot(10.^xspace,10.^pYnormalised,'b--')
h8=plot(10.^xspace,10.^(cYnormalised),'r--')


ylim([0.001,1])
xlim([1,max(plot_c_x2+2000)])

hleg1=legend([{'PBCA (raw)'}',{'CBCA (raw)'},{'PBCA (normalised)'}',{'CBCA (normalised)'},...
{'PBCA  (raw)'},{'CBCA (raw)'},{'PBCA (normalised)'},{'CBCA (normalised)'}])
xlabel('CO_2 (Gg)')
ylabel('Relative standard deviation ')
axis square
grid on
