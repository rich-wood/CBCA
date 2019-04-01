% a5_scatter_with_rsd_EU.m - script for generating plots used in paper.

% Manuscript Title: Variation in trends of consumption based carbon accounts
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler, Joao Rodrigues
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA


% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 3 (a3_ghg_harmonise_models.m) required
% Adidtional comments:
%plot figure with time on x and all model results.
%plot both raw and normalised results
%include measure of RSD in plot.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%load data:
load('A3_normalised_results.mat') %


% set colours as desired:
colourindx1=[0,0.447058823529412,0.741176470588235];
colourindx2=[0.850980392156863,0.325490196078436,0.0980392156862745];


unitconversion=1e-3; %change from Mt to Gt, (manual labelling)

set_region_manually=1;
if set_region_manually==1
    istop=3;
else
    istop=length(region_list);
end
for i=1:istop
    
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
    % Plot normalised data first:
    %establish and plot figure:
    
    
    fig=figure
    set(gca,'fontsize',14)
    set(gcf,'units','points','position',[100,100,650,550])
    % set(gca,'DefaultAxesLineStyleOrder','-x|-*|:|-.|-*|:|o')
    set(gca,'LineStyleOrder',{'-+','-*','-x','->','-o',})
    yyaxis left
    hold on
    ylim([0,ylim2])
    xlim([1995,2016])
    ax1=plot([1960:2016],struct_results.norm.p(region_count).all*unitconversion)
    ax2=plot([1960:2016],struct_results.norm.c(region_count).all.*unitconversion,'Color',colourindx2)
    
    ax = gca;
    ax.YColor = 'black';
    ylabel('Gt CO2')
    if iflgd==1
        lgd=legend([strcat('PBCA: ',modelname(1:5)),strcat('CBCA: ',modelname(1:5))],'location','southoutside','Orientation','horizontal')
        lgd.NumColumns=5
    end
    title([regionname,' emissions: normalised to ', num2str(meta.reference_year)])
    
    
    
    
    yyaxis right
    ax = gca;
    ax.YColor = 'black';
    ylabel('Relative standard deviation, %')
    ylim([0,40])
    ax=axes('Position',get(gca,'Position'),'Visible','Off');
    ylim([0,40])
    hold all
    xlim([1995,2016])
    ax3=plot([1996:2016],100*struct_results.norm.p(region_count).rsd(36:56),'-.','Color','b')
    ax4=plot([1996:2016],100*struct_results.norm.c(region_count).rsd(36:56),'-.','Color','r')
    
    legend([ax],[{'RSD PBCA'},{'RSD CBCA'}],'location','east')
    savefig(['figs\LinePlotsIndexed_',regionname])
    print(['figs\LinePlotsIndexed_',regionname],'-djpeg')
    
    %%
    % Plot raw data only:
    
    figure
    set(gca,'fontsize',14)
    set(gcf,'units','points','position',[100,100,650,550])
    set(gca,'LineStyleOrder',{'-+','-*','-x','->','-o',})
    yyaxis left
    ax = gca;
    ax.YColor = 'black';
    hold on
    ylim([0,ylim2])
    xlim([1995,2016])
    ax1=plot([1960:2016],struct_results.raw.p(region_count).all*unitconversion)
    ax2=plot([1960:2016],struct_results.raw.c(region_count).all*unitconversion,'Color',colourindx2)
    
    ylabel('Gt CO2')
    title([regionname,' emissions: raw'])
    if iflgd==1
        lgd=legend([strcat('PBCA: ',modelname(1:5)),strcat('CBCA: ',modelname(1:5))],'location','southoutside','Orientation','horizontal')
        lgd.NumColumns=5
    end
    yyaxis right
    ax.YColor = 'none';
    
    yyaxis right
    ax = gca;
    ax.YColor = 'black';
    ylabel('Relative standard deviation, %')
    ylim([0,40])
    ax=axes('Position',get(gca,'Position'),'Visible','Off');
    ylim([0,40])
    hold all
    xlim([1995,2016])
    ax5=plot([1995:2016],100*struct_results.raw.p(region_count).rsd(36:57),'-.','Color','b')
    ax6=plot([1995:2016],100*struct_results.raw.c(region_count).rsd(36:57),'-.','Color','r')
    
    legend([ax],[{'RSD PBCA'},{'RSD CBCA'}],'location','east')
    
    savefig(['figs\LinePlotsRAW_',regionname])
    print(['figs\LinePlotsRAW_',regionname],'-djpeg')
    
end