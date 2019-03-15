% a3_ghg_harmonise_models.m - script to harmonise multiple-accounts

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA

% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 2 (a2_ghg_organise_regions.m) required.
% Adidtional comments:
% Script creates a multi-model mean of carbon accounts based on the number
% of models and regions previously set up in stage 2 and earlier. The
% script indexes all data to a common 2007 value, and calculates rates of
% change and the mean rate of change from this value. Various measures of
% variability of model results are presented both prior and post indexing.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
load('A2_All_model_results.mat')


model_include=[1:5]; %define what models to include:
start_year_num=1960;
end_year_num=2016;
end_year_indx=end_year_num-start_year_num+1;

reference_year=2005-start_year_num+1;
start_year_indx=start_year_num-1960+1;
yr_length=end_year_indx-start_year_indx+1;

number_models=length(modelname);


%% multi-region average results - time series absolute values for decoupling purposes:
summmary_mean=table([start_year_num:end_year_num]','VariableNames',{'Years'}); %only the mean
tabular_results.raw.p=table([start_year_num:end_year_num]','VariableNames',{'Years'}); % raw data - production (territorial accont)
tabular_results.raw.c=table([start_year_num:end_year_num]','VariableNames',{'Years'});% raw data - consumption account
tabular_results.raw.t=table([start_year_num:end_year_num]','VariableNames',{'Years'});% raw data - transfers
tabular_results.norm.p=table([start_year_num:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007
tabular_results.norm.c=table([start_year_num:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007
tabular_results.norm.t=table([start_year_num:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007
tabular_results.gr.p=table([start_year_num+1:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007
tabular_results.gr.c=table([start_year_num+1:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007
tabular_results.gr.t=table([start_year_num+1:end_year_num]','VariableNames',{'Years'}); % re-benchmarked to harmonise to 2007

%start with original data:
% e.g. struct_results.raw.p
%next calculate growth rates:
% e.g. struct_results.gr.p(region_count).all
%end with "harmonised" data
% e.g. res_harm_p
%perform same with the spread of data
% e.g. struct_results.norm.p


for region_count=[1:size(raw_regional_results,2)]
    regionname=regions.regionname_clean{region_count};
    res_harm_p=zeros(end_year_indx,1);
    res_harm_c=zeros(end_year_indx,1);
    res_harm_g=zeros(end_year_indx,1);
    
    % create a table of data for each region, dimension years by model; and vectors of population
    for modelcounter=1:number_models
        
        %prod
        struct_results.raw.p(region_count).all(:,modelcounter)=raw_regional_results(model_include(modelcounter),region_count).reg.pbca(start_year_indx:end_year_indx);
        %cons
        struct_results.raw.c(region_count).all(:,modelcounter)=raw_regional_results(model_include(modelcounter),region_count).reg.cbca(start_year_indx:end_year_indx);
        %transfer
        struct_results.raw.t(region_count).all(:,modelcounter)=raw_regional_results(model_include(modelcounter),region_count).reg.pbca(start_year_indx:end_year_indx)-raw_regional_results(model_include(modelcounter),region_count).reg.cbca(start_year_indx:end_year_indx);
        %global
        struct_results.raw.g(region_count).all(:,modelcounter)=raw_regional_results(model_include(modelcounter),region_count).reg.glob(start_year_indx:end_year_indx);
        res_pop(:,modelcounter)=raw_regional_results(modelcounter,region_count).reg.pop(start_year_indx:end_year_indx)/1e6;
    end
    
    struct_results.raw.p=stat_funcs(struct_results.raw.p,number_models,region_count);
    struct_results.raw.c=stat_funcs(struct_results.raw.c,number_models,region_count);
    struct_results.raw.t=stat_funcs(struct_results.raw.t,number_models,region_count);
    struct_results.raw.g=stat_funcs(struct_results.raw.g,number_models,region_count);
    
    
    
    %%% MODIFYING TO GROWTH RATES
    
    % annual growth rates (next year divided by previous year)
    struct_results.gr.p(region_count).all=struct_results.raw.p(region_count).all(2:end,:)./struct_results.raw.p(region_count).all(1:end-1,:);
    struct_results.gr.c(region_count).all=struct_results.raw.c(region_count).all(2:end,:)./struct_results.raw.c(region_count).all(1:end-1,:);
    struct_results.gr.t(region_count).all=struct_results.raw.t(region_count).all(2:end,:)./struct_results.raw.t(region_count).all(1:end-1,:);
    struct_results.gr.g(region_count).all=struct_results.raw.g(region_count).all(2:end,:)./struct_results.raw.g(region_count).all(1:end-1,:);
    
    % annual de-growth rates (next year divided by previous year)
    res_dgr_p(region_count).all=struct_results.raw.p(region_count).all(1:end-1,:)./struct_results.raw.p(region_count).all(2:end,:);
    res_dgr_c(region_count).all=struct_results.raw.c(region_count).all(1:end-1,:)./struct_results.raw.c(region_count).all(2:end,:);
    res_dgr_g(region_count).all=struct_results.raw.g(region_count).all(1:end-1,:)./struct_results.raw.g(region_count).all(2:end,:);
  
    
    % average growth rates
    struct_results.gr.p(region_count).mean=nansum(struct_results.gr.p(region_count).all,2)./nansum(struct_results.gr.p(region_count).all>0,2);
    struct_results.gr.c(region_count).mean=nansum(struct_results.gr.c(region_count).all,2)./nansum(struct_results.gr.c(region_count).all>0,2);
    struct_results.gr.t(region_count).mean=nansum(struct_results.gr.t(region_count).all,2)./nansum(struct_results.gr.t(region_count).all>0,2);
    struct_results.gr.g(region_count).mean=nansum(struct_results.gr.g(region_count).all,2)./nansum(struct_results.gr.g(region_count).all>0,2);
    res_dgr_p(region_count).mean=nansum(res_dgr_p(region_count).all,2)./nansum(res_dgr_p(region_count).all>0,2);
    res_dgr_c(region_count).mean=nansum(res_dgr_c(region_count).all,2)./nansum(res_dgr_c(region_count).all>0,2);
    res_dgr_g(region_count).mean=nansum(res_dgr_g(region_count).all,2)./nansum(res_dgr_g(region_count).all>0,2);
    
    % We will now use the growth rates to index all models to a common reference year, and calculate the mean of the results
    % Set reference year results as the mean of all model observations:
    % firstly for "indexed" (keeping spread of) data
    struct_results.norm.p(region_count).all(reference_year,1:number_models)=nanmean(struct_results.raw.p(region_count).all(reference_year,:));
    struct_results.norm.c(region_count).all(reference_year,1:number_models)=nanmean(struct_results.raw.c(region_count).all(reference_year,:));
    struct_results.norm.g(region_count).all(reference_year,1:number_models)=nanmean(struct_results.raw.g(region_count).all(reference_year,:));
    % secondly for "harmonised" (mean result across all models)
    res_harm_p(reference_year,1)=nanmean(struct_results.raw.p(region_count).all(reference_year,:),2);
    res_harm_c(reference_year,1)=nanmean(struct_results.raw.c(region_count).all(reference_year,:),2);
    res_harm_g(reference_year,1)=nanmean(struct_results.raw.g(region_count).all(reference_year,:),2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %provide the spread of model results after indexing to reference year.
    %Multiply the model specific growth rate (in .all) by the model
    %specific result after indexing.
    for i=reference_year+1:end_year_num-start_year_num+1
        struct_results.norm.p(region_count).all(i,:)=struct_results.gr.p(region_count).all(i-1,:).*struct_results.norm.p(region_count).all(i-1,:);
        struct_results.norm.c(region_count).all(i,:)=struct_results.gr.c(region_count).all(i-1,:).*struct_results.norm.c(region_count).all(i-1,:);
        struct_results.norm.g(region_count).all(i,:)=struct_results.gr.g(region_count).all(i-1,:).*struct_results.norm.g(region_count).all(i-1,:);
    end
    for i=reference_year-1:-1:1
        struct_results.norm.p(region_count).all(i,:)=res_dgr_p(region_count).all(i,:).*struct_results.norm.p(region_count).all(i+1,:);
        struct_results.norm.c(region_count).all(i,:)=res_dgr_c(region_count).all(i,:).*struct_results.norm.c(region_count).all(i+1,:);
        struct_results.norm.g(region_count).all(i,:)=res_dgr_g(region_count).all(i,:).*struct_results.norm.g(region_count).all(i+1,:);
    end
    
    struct_results.norm.p(region_count).gdp_cap=raw_regional_results(1,region_count).reg.gdp_cap;
    struct_results.norm.t(region_count).all=struct_results.norm.p(region_count).all-struct_results.norm.c(region_count).all;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do stats tests on indexed results (i.e. capture the variation of
    % results after indexing to a reference year)
    struct_results.norm.p=stat_funcs(struct_results.norm.p,number_models,region_count);
    struct_results.norm.c=stat_funcs(struct_results.norm.c,number_models,region_count);
    struct_results.norm.t=stat_funcs(struct_results.norm.t,number_models,region_count);
    struct_results.norm.g=stat_funcs(struct_results.norm.g,number_models,region_count);
    
    % Do stats tests on growth rates(i.e. capture the variation in growth rates)
    struct_results.gr.p=stat_funcs(struct_results.gr.p,number_models,region_count);
    struct_results.gr.c=stat_funcs(struct_results.gr.c,number_models,region_count);
    struct_results.gr.t=stat_funcs(struct_results.gr.t,number_models,region_count);
    struct_results.gr.g=stat_funcs(struct_results.gr.g,number_models,region_count);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Create a table of results incl statistics, for raw results, of normalised
    % results, and of growth rates.
    tabular_results.raw.p.(['std_',regionname])=struct_results.raw.p(region_count).std;
    tabular_results.raw.p.(['mean_',regionname])=struct_results.raw.p(region_count).mean;
    tabular_results.raw.p.(['rsd_',regionname])=struct_results.raw.p(region_count).rsd;
    tabular_results.raw.p.(['rad_',regionname])=struct_results.raw.p(region_count).rad;
    tabular_results.raw.p.(['n_',regionname])=struct_results.raw.p(region_count).n;
    
    tabular_results.raw.c.(['std_',regionname])=struct_results.raw.c(region_count).std;
    tabular_results.raw.c.(['mean_',regionname])=struct_results.raw.c(region_count).mean;
    tabular_results.raw.c.(['rsd_',regionname])=struct_results.raw.c(region_count).rsd;
    tabular_results.raw.c.(['rad_',regionname])=struct_results.raw.c(region_count).rad;
    tabular_results.raw.c.(['n_',regionname])=struct_results.raw.c(region_count).n;
    
    tabular_results.raw.t.(['std_',regionname])=struct_results.raw.t(region_count).std;
    tabular_results.raw.t.(['mean_',regionname])=struct_results.raw.t(region_count).mean;
    tabular_results.raw.t.(['rsd_',regionname])=abs(struct_results.raw.t(region_count).rsd);
    tabular_results.raw.t.(['rad_',regionname])=abs(struct_results.raw.t(region_count).rad);
    tabular_results.raw.t.(['n_',regionname])=struct_results.raw.t(region_count).n;
    
    tabular_results.norm.p.(['std_',regionname])=struct_results.norm.p(region_count).std;
    tabular_results.norm.p.(['mean_',regionname])=struct_results.norm.p(region_count).mean;
    tabular_results.norm.p.(['rsd_',regionname])=struct_results.norm.p(region_count).rsd;
    tabular_results.norm.p.(['rad_',regionname])=struct_results.norm.p(region_count).rad;
    tabular_results.norm.p.(['n_',regionname])=struct_results.norm.p(region_count).n;
    
    tabular_results.norm.c.(['std_',regionname])=struct_results.norm.c(region_count).std;
    tabular_results.norm.c.(['mean_',regionname])=struct_results.norm.c(region_count).mean;
    tabular_results.norm.c.(['rsd_',regionname])=struct_results.norm.c(region_count).rsd;
    tabular_results.norm.c.(['rad_',regionname])=struct_results.norm.c(region_count).rad;
    tabular_results.norm.c.(['n_',regionname])=struct_results.norm.c(region_count).n;
    
    tabular_results.norm.t.(['std_',regionname])=struct_results.norm.t(region_count).std;
    tabular_results.norm.t.(['mean_',regionname])=struct_results.norm.t(region_count).mean;
    tabular_results.norm.t.(['rsd_',regionname])=abs(struct_results.norm.t(region_count).rsd);
    tabular_results.norm.t.(['rad_',regionname])=abs(struct_results.norm.t(region_count).rad);
    tabular_results.norm.t.(['n_',regionname])=struct_results.norm.t(region_count).n;
    
    tabular_results.gr.p.(['std_',regionname])=struct_results.gr.p(region_count).std;
    tabular_results.gr.p.(['mean_',regionname])=struct_results.gr.p(region_count).mean;
    tabular_results.gr.p.(['rsd_',regionname])=struct_results.gr.p(region_count).rsd;
    tabular_results.gr.p.(['rad_',regionname])=struct_results.gr.p(region_count).rad;
    tabular_results.gr.p.(['n_',regionname])=struct_results.gr.p(region_count).n;
    
    tabular_results.gr.c.(['std_',regionname])=struct_results.gr.c(region_count).std;
    tabular_results.gr.c.(['mean_',regionname])=struct_results.gr.c(region_count).mean;
    tabular_results.gr.c.(['rsd_',regionname])=struct_results.gr.c(region_count).rsd;
    tabular_results.gr.c.(['rad_',regionname])=struct_results.gr.c(region_count).rad;
    tabular_results.gr.c.(['n_',regionname])=struct_results.gr.c(region_count).n;
    
    tabular_results.gr_t.(['std_',regionname])=struct_results.gr.t(region_count).std;
    tabular_results.gr_t.(['mean_',regionname])=struct_results.gr.t(region_count).mean;
    tabular_results.gr_t.(['rsd_',regionname])=abs(struct_results.gr.t(region_count).rsd);
    tabular_results.gr_t.(['rad_',regionname])=abs(struct_results.gr.t(region_count).rad);
    tabular_results.gr_t.(['n_',regionname])=struct_results.gr.t(region_count).n;
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Taking mean of the normalised results for a summary result
    tmp_res_harm_p(:,1)=nanmean(struct_results.norm.p(region_count).all,2);
    tmp_res_harm_c(:,1)=nanmean(struct_results.norm.c(region_count).all,2);
    
    summmary_mean.(['p_',regionname])=tmp_res_harm_p;
    summmary_mean.(['c_',regionname])=tmp_res_harm_c;
    summmary_mean.(['p_cap_',regionname])=tmp_res_harm_p./raw_regional_results(1,region_count).reg.pop(start_year_indx:end_year_indx)*1e6;
    summmary_mean.(['c_cap_',regionname])=tmp_res_harm_c./raw_regional_results(1,region_count).reg.pop(start_year_indx:end_year_indx)*1e6;
    summmary_mean.(['gdp_cap_',regionname])=raw_regional_results(1,region_count).reg.gdp_cap(start_year_indx:end_year_indx);
    
    clear res_c_pop res_c_pop_share res3p_exist regionname m i res_pop tmp_res_harm_p tmp_res_harm_c
    
end



summmary_mean.(['p_global'])=nanmean(struct_results.norm.g(region_count).all,2);
summmary_mean.(['c_global'])=nanmean(struct_results.norm.g(region_count).all,2);
summmary_mean.(['pop_global'])=world.pop{1,start_year_indx+5:end_year_indx+5}';
summmary_mean.(['ppp_global'])=world.ppp{1,start_year_indx+4:end_year_indx+4}';

clear world region_count



save('A3_TimeSeriesCalcs','regions','reference_year','modelname','summmary_mean','tabular_results','struct_results')

disp('finished')



%     reg_res.mean.p.(regionname)=res_harm_p;
%     reg_res.mean.c.(regionname)=res_harm_c;
%     
%     reg_res.spread.p.(regionname)=struct_results.norm.p(region_count).all;
%     reg_res.spread.c.(regionname)=struct_results.norm.c(region_count).all;
%        
%     reg_res.spread.p_orig.(regionname)=struct_results.raw.p(region_count).all;
%     reg_res.spread.c_orig.(regionname)=struct_results.raw.c(region_count).all;