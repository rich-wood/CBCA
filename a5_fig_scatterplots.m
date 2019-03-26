%Plot figure with all data points as a scatter plot


load('A3_normalised_results.mat','struct_results','meta')



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
country_select(:)=1; % all countries
% country_select(11)=1; % one country

% there are 4 types of data intersted in here, PBCA, CBCA, both normalised and raw.
% Extract that data and arrange:

%obtain rsd, mean and number of observations
%meta.regions.unique_country - logical to extract individual country observations and not country aggregates:
tmp_norm_p_rsd=[struct_results.raw.p(meta.regions.unique_country).rsd];
tmp_p_mean=[struct_results.raw.p(meta.regions.unique_country).mean];
tmp_p_n=[struct_results.raw.p(meta.regions.unique_country).n];

%only plot sensible values (log transformation will occur) and when 3 data
%points
filterx=(tmp_norm_p_rsd)>=1e-5 & (tmp_p_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;

plot_p_y_raw=tmp_norm_p_rsd(filterx);
plot_p_x_raw=tmp_p_mean(filterx);
clear tmp*

tmp_raw_c_rsd=[struct_results.raw.c(meta.regions.unique_country).rsd];
tmp_raw_c_mean=[struct_results.raw.c(meta.regions.unique_country).mean];
tmp_raw_c_n=[struct_results.raw.c(meta.regions.unique_country).n];
filterx=(tmp_raw_c_rsd)>=1e-5 & (tmp_raw_c_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_c_y_raw=tmp_raw_c_rsd(filterx);
plot_c_x_raw=tmp_raw_c_mean(filterx);

clear tmp*
% set up x-values (on a log-spaced vector for plotting)
MIN_VALUE = 0.1;
MAX_VALUE = 1e5;
NUM_POINTS = 200;
xspace = logspace(log10(MIN_VALUE), log10(MAX_VALUE), NUM_POINTS);


% linear fit on log transformed data:
[pfit,gofp]=fit(log10(plot_p_x_raw),log10(plot_p_y_raw),'poly1');
[cfit,gofc]=fit(log10(plot_c_x_raw),log10(plot_c_y_raw),'poly1');
% obtain fitted line, based on log-spaced x values
pYraw=(pfit.p1.*((xspace)))+pfit.p2;
cYraw=(cfit.p1.*((xspace)))+cfit.p2;
pYraw_caption = [sprintf('y = %.2f x %.2f', pfit.p1, pfit.p2),sprintf(' R^{%d}',2),sprintf(': %.2f', gofp.rsquare)];
cYraw_caption = [sprintf('y = %.2f x %.2f', cfit.p1, cfit.p2),sprintf(' R^{%d}',2),sprintf(': %.2f', gofc.rsquare)];


% this time with normalised results as well.

%obtain rsd, mean and number of observations
%meta.regions.unique_country - logical to extract individual country observations and not country aggregates:
tmp_norm_p_rsd=[struct_results.norm.p(meta.regions.unique_country).rsd];
tmp_norm_p_mean=[struct_results.norm.p(meta.regions.unique_country).mean];
tmp_norm_p_n=[struct_results.norm.p(meta.regions.unique_country).n];
% tmp_norm_p_mean(1,:)=[];
% tmp_norm_p_n(1,:)=[];

%only plot sensible values (log transformation will occur) and when 3 data
%points
filterx=(tmp_norm_p_rsd)>=1e-5 & (tmp_norm_p_n>2);
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_p_y_norm=tmp_norm_p_rsd(filterx);
plot_p_x_norm=tmp_norm_p_mean(filterx);

%CBCA values:
tmp_norm_c_rsd=[struct_results.norm.c(meta.regions.unique_country).rsd];
tmp_norm_c_mean=[struct_results.norm.c(meta.regions.unique_country).mean];
% tmp_norm_c_mean(1,:)=[];

filterx=(tmp_norm_c_rsd)>=1e-5;
filterx(~year_select,:)=0;
filterx(:,~country_select)=0;
plot_c_y_norm=tmp_norm_c_rsd(filterx);
plot_c_x_norm=tmp_norm_c_mean(filterx);
clear tmp*

[pfit,gofp]=fit(log10(plot_p_x_norm),log10(plot_p_y_norm),'poly1');
[cfit,gofc]=fit(log10(plot_c_x_norm),log10(plot_c_y_norm),'poly1');
pYnormalised=(pfit.p1.*((xspace)))+pfit.p2;
cYnormalised=(cfit.p1.*((xspace)))+cfit.p2;
pYnormalised_caption = [sprintf('y = %.2f x %.2f', pfit.p1, pfit.p2),sprintf(' R^{%d}',2),sprintf(': %.2f', gofp.rsquare)];
cYnormalised_caption = [sprintf('y = %.2f x %.2f', cfit.p1, cfit.p2),sprintf(' R^{%d}',2),sprintf(': %.2f', gofc.rsquare)];

%%
for which_plot=0:4
    fig3 = figure;
    hold on
    % transform representation to log form
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')
    xtop=max(plot_c_x_raw+2000);
    ylim([0.001,1])
    xlim([1,xtop])
    
    
    if which_plot==0
        h1=scatter((plot_p_x_raw),(plot_p_y_raw)','.');
        h5=scatter((plot_p_x_norm),(plot_p_y_norm),'+');
        h3=plot(10.^xspace,10.^(pYraw),'b')
        h7=plot(10.^xspace,10.^pYnormalised,'b--')
        h2=scatter((plot_c_x_raw),(plot_c_y_raw)','x');
        h6=scatter((plot_c_x_norm),(plot_c_y_norm),'*');
        h4=plot(10.^xspace,10.^(cYraw),'r')
        h8=plot(10.^xspace,10.^(cYnormalised),'r--')
    end
    if which_plot==1 
        h1=scatter((plot_p_x_raw),(plot_p_y_raw)','.');
        h5=scatter((plot_p_x_norm),(plot_p_y_norm),'x');
        h3=plot(10.^xspace,10.^(pYraw),'b')
        h7=plot(10.^xspace,10.^pYnormalised,'r')
    end
    if which_plot==2 
        h2=scatter((plot_c_x_raw),(plot_c_y_raw)','.');
        h6=scatter((plot_c_x_norm),(plot_c_y_norm),'x');
        h4=plot(10.^xspace,10.^(cYraw),'b')
        h8=plot(10.^xspace,10.^(cYnormalised),'r')
    end
    if which_plot==3
        % plot the values, (axis is log-transformed above)
        h1=scatter((plot_p_x_raw),(plot_p_y_raw)','.')
        h2=scatter((plot_c_x_raw),(plot_c_y_raw)','x')
        %plot exponents, as axis is transformed
        h3=plot(10.^(xspace),10.^(pYraw),'b')
        h4=plot(10.^(xspace),10.^(cYraw),'r')
    end
    
    if which_plot==4
        % plot the values, (axis is log-transformed above)
        h1=scatter((plot_p_x_norm),(plot_p_y_norm)','.')
        h2=scatter((plot_c_x_norm),(plot_c_y_norm)','x')
        %plot exponents, as axis is transformed
        h3=plot(10.^(xspace),10.^(pYnormalised),'b')
        h4=plot(10.^(xspace),10.^(cYnormalised),'r')
    end
    
    
    
    if which_plot==0
        hleg1=legend([{'PBCA (raw)'}',{'CBCA (raw)'},{'PBCA (normalised)'}',{'CBCA (normalised)'},...
            {'PBCA  (raw)'},{'CBCA (raw)'},{'PBCA (normalised)'},{'CBCA (normalised)'}])
        
    end
    if which_plot==1
        htit1=title([{'PBCA'}])
%         hleg1=legend([{'Raw'}',{'Normalised'}',...
%             {['Raw ',pYraw_caption]},{['Normalised ',pYnormalised_caption]}],'Location','northoutside','NumColumns',2)
        hleg1=legend([{'Raw'}',{'Normalised'}',...
            {['Raw ']},{['Normalised ']}],'Location','Northeast','NumColumns',2)
%         
        annotation('textbox',[0.6, 0.6, 0.2, 0.1],'String', pYraw_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6);
        annotation('textbox',[0.5, 0.35, 0.2, 0.1],'String', pYnormalised_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6);
%         text(10e2,plot_p_y_raw(600), pYraw_caption, 'FontSize', 9, 'Color', 'b');
%         text(10e2,plot_p_y_norm(600), pYnormalised_caption, 'FontSize', 9, 'Color', 'r');
    end
    if which_plot==2
        hleg1=title([{'CBCA'}])
        hleg1=legend([{'Raw'}',{'Normalised'}',...
            {['Raw ']},{['Normalised ']}],'Location','Northeast','NumColumns',2)
%         hleg1=legend([{'CBCA (raw)'}',{'CBCA (normalised)'}',...
%             {'CBCA  (raw)'},{'CBCA (normalised)'},])
        annotation('textbox',[0.6, 0.62, 0.2, 0.1],'String', cYraw_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6);
        annotation('textbox',[0.5, 0.4, 0.2, 0.1],'String', cYnormalised_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6)
%         text( cYraw_caption, 'FontSize', 12, 'Color', 'b');
%         text( cYnormalised_caption, 'FontSize', 12, 'Color', 'b');
    end
    if which_plot==3
        hleg1=title([{'Normalised'}])
        hleg1=legend([h1,h2,h3,h4],[{'PBCA'}',{'CBCA'},{'PBCA'},{'CBCA'}])
%         hleg1=legend([h1,h2,h3,h4],[{'PBCA (raw)'}',{'CBCA (raw)'},{'PBCA  (raw)'},{'CBCA  (raw)'}])
        
        annotation('textbox',[0.5, mean(plot_p_y_raw)*5.5, 0.2, 0.1],'String', pYraw_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6);
        annotation('textbox',[0.6, mean(plot_c_y_raw)*5.5, 0.2, 0.1],'String', cYraw_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6)
        
%         text( pYraw_caption, 'FontSize', 12, 'Color', 'b');
%         text( cYraw_caption, 'FontSize', 12, 'Color', 'b');
    end
    if which_plot==4
        hleg1=title([{'Normalised'}])
%         hleg1=legend([h1,h2,h3,h4],[{'PBCA (normalised)'}',{'CBCA (normalised)'},{'PBCA  (normalised)'},{'CBCA  (normalised)'}])
        hleg1=legend([h1,h2,h3,h4],[{'PBCA'}',{'CBCA'},{'PBCA'},{'CBCA'}])
        annotation('textbox',[0.6, 0.3, 0.2, 0.1],'String', pYnormalised_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6);
        annotation('textbox',[0.6, 0.55, 0.2, 0.1],'String', cYnormalised_caption, 'FontSize', 9, 'Color', 'k','BackgroundColor','w','EdgeColor','none','FaceAlpha',0.6)
%         text( pYnormalised_caption, 'FontSize', 12, 'Color', 'b');
%         text( cYnormalised_caption, 'FontSize', 12, 'Color', 'b');
    end
    
    xlabel('CO_2 (Gg)')
    ylabel('Relative standard deviation ')
    axis square
    grid on
    set(gcf,'color','w');
    
    savefig(['figs\aScatter_',num2str(which_plot)])
    print(['figs\aScatter_',num2str(which_plot)],'-djpeg')
end