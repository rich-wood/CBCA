% a5_scatter_with_rsd_EU.m - script for generating plots used in paper.

% Manuscript Title: Variation in trends of consumption based carbon accounts
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler, Joao Rodrigues
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA


% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 3 (stage3_cf_harmonise_models.m) required
% Adidtional comments:
%plot figure with time on x and all model results.
%plot both raw and normalised results
%include measure of RSD in plot.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%load data:
load('results\cf_multimodel_normalised_results.mat') %


% set colours as desired:
colourindx1=[0,0.447058823529412,0.741176470588235];
colourindx2=[0.850980392156863,0.325490196078436,0.0980392156862745];


unitconversion=1e-3; %change from Mt to Gt, (manual labelling)

set_region_manually=1;
if set_region_manually==1
    number_or_regions_to_plot=3;
else
    number_or_regions_to_plot=length(region_list);
end

for i=1:number_or_regions_to_plot
    
    if set_region_manually==1
        %Choose region to plot:
        if i==1
            regionname='OECD'
        elseif i==2
            regionname='BRICS'
        elseif i==3
            regionname='EU28'
            % regionname='G8'
            % regionname='Annex_I'
            % regionname='USA'
        end
    else
        regionname=meta.regions.regionname_clean{i};
    end
    
    region_count=find(strcmp(regionname,meta.regions.name))
    
    %establish resonable estimate for y-axis limit:
    ylim2=ceil(max(max([struct_results.raw.p(region_count).all,struct_results.raw.c(region_count).all])+300)/1000);
    
    
    iflgd=0 %if print legend
    
    %%
    
    
    %%
    % Plot raw data only:
    
%     f1=figure
    subplot(number_or_regions_to_plot,2,2*(i-1)+1)
    set(gca,'fontsize',14)
    set(gcf,'units','points','position',[100,100,400,350])
    set(gca,'LineStyleOrder',{'-+','-*','-x','->','-o',})
    yyaxis left
    ax = gca;
    ax.YColor = 'black';
    ylabel('Gt CO2')
    title([char(96+2*(i-1)+1),') ',regionname,': raw'])
    hold on
    ylim([0,ylim2])
    xlim([1995,2016])
    plot([1960:2016],struct_results.raw.p(region_count).all*unitconversion)
    plot([1960:2016],struct_results.raw.c(region_count).all*unitconversion,'Color',colourindx2)
       
    yyaxis right
    ax = gca;
    ax.YColor = 'black';
    ylabel('RSD, %')
    ylim([0,40])
%     ax=axes('Position',get(gca,'Position'),'Visible','Off');
    ylim([0,40])
%     hold all
    xlim([1995,2016])
    plot([1995:2016],100*struct_results.raw.p(region_count).rsd(36:57),'-.','Color','b')
    plot([1995:2016],100*struct_results.raw.c(region_count).rsd(36:57),'-.','Color','r')
    
%     savefig(['figs\LinePlotsRAW_',regionname])
%     saveas(gcf,['figs\LinePlotsRAW_',regionname],'epsc')
%     print(['figs\LinePlotsRAW_',regionname],'-djpeg')
    
    
    %% Plot normalised data second:
    %establish and plot figure:
    
    
%     fig=figure
    subplot(number_or_regions_to_plot,2,2*i)
    set(gca,'fontsize',14)
    set(gcf,'units','points','position',[100,100,400,350])
    % set(gca,'DefaultAxesLineStyleOrder','-x|-*|:|-.|-*|:|o')
    set(gca,'LineStyleOrder',{'-+','-*','-x','->','-o',})
    yyaxis left
    ax = gca;
    ax.YColor = 'black';
    ylabel('Gt CO2')
    title([char(96+2*i),') ',regionname,': normalised to ', num2str(meta.reference_year)])
    
    hold on
    ylim([0,ylim2])
    xlim([1995,2016])
    ax1=plot([1960:2016],struct_results.norm.p(region_count).all*unitconversion)
    ax2=plot([1960:2016],struct_results.norm.c(region_count).all.*unitconversion,'Color',colourindx2)
    
    
    yyaxis right
    ax = gca;
    ax.YColor = 'black';
    ylabel('RSD, %')
    ylim([0,40])
%     ax=axes('Position',get(gca,'Position'),'Visible','Off');
    hold on
    ylim([0,40])
    xlim([1995,2016])
    ax3=plot([1996:2016],100*struct_results.norm.p(region_count).rsd(36:56),'-.','Color','b')
    ax4=plot([1996:2016],100*struct_results.norm.c(region_count).rsd(36:56),'-.','Color','r')
    
    if iflgd==1
    legend([ax],[{'RSD PBCA'},{'RSD CBCA'}],'location','east')
    end
%     savefig(['figs\LinePlotsIndexed_',regionname])
%     saveas(gcf,['figs\LinePlotsIndexed_',regionname],'epsc')
%     print(['figs\LinePlotsIndexed_',regionname],'-djpeg')
    
    ax1 = gca;
    
    
    

    
end



% lgd=legend([strcat('PBCA: ',meta.modelname(1:5)),strcat('CBCA: ',meta.modelname(1:5)),{'RSD PBCA'},{'RSD CBCA'}],'location','southoutside','Orientation','horizontal')
% lgd.NumColumns=6
% lgd.Orientation='vertical'
% break 
% % you must manually resize and move the axis here...
% % image 
% savefig('results\Figure1')
% saveas(gcf,'results\Figure1','epsc')

    