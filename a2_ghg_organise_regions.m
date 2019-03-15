% a2_ghg_organise_regions.m - script to harmonise multiple-accounts

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA

% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 1 (a1_GHG_Load.m) required.
% Adidtional comments:
% Script organises common regions between all the models


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
%%
bench_year=31+5;

%%
% TimeSeriesCalcs_Load
load('A1_Raw_data','pbca_emis','cbca_emis','modelname')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define regions manually:
region_counter=0;

region_counter=region_counter+1;regions.name(region_counter)={'EU27'}; %1
region_counter=region_counter+1;regions.name(region_counter)={'EU15'}; %2
region_counter=region_counter+1;regions.name(region_counter)={'OECD'}; %3
region_counter=region_counter+1;regions.name(region_counter)={'BRICS'}; %4
region_counter=region_counter+1;regions.name(region_counter)={'Annex I'}; %5
region_counter=region_counter+1;regions.name(region_counter)={'G8'}; %6
region_counter=region_counter+1;regions.name(region_counter)={'EU12'}; %7
region_counter=region_counter+1;regions.name(region_counter)={'North America'}; %8
region_counter=region_counter+1;regions.name(region_counter)={'EU28'}; %9
%include individual countries common to ICIO
regions.name=[regions.name,pbca_emis.ICIO.ISO3(1:end-1)'];
regions.unique_country=ones(size(regions.name,2),1);
regions.unique_country(1:region_counter)=0;
regions.unique_country=logical(regions.unique_country);
number_models=numel(fieldnames(pbca_emis));


n_regions=size(regions.name,2)


%% Load basic macro population and GDP data:
load('source/pop.mat')
load('source/gdp_ppp_extrapolate.mat')
world.pop=poptab(strcmp('WLD',poptab.CountryCode),:);
world.ppp=ppptab(strcmp('WLD',ppptab.CountryCode),:);

%set all NaN to zero, stop at 2016 data:
poptab(:,63:end)=[];
tmp=table2array(poptab(:,6:62));
tmp(isnan(tmp))=0;
poptab(:,6:end)=num2cell(tmp);

ppptab(:,62:end)=[];
tmp=table2array(ppptab(:,5:61));
tmp(isnan(tmp))=0;
ppptab(:,5:end)=num2cell(tmp);
clear tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate basic results for each model, benchmark against population etc.


for region_count=1:n_regions
    
    % NAMING
    % Need to keep original region name for string matching
    regionname_orig=regions.name{region_count};
    % Need to remove punctuation for variable handling in matlab    
    regionname=regionname_orig;
    disp(regionname)
    dash_indx=strfind(regionname,'-');
    regionname(dash_indx)='_';
    dash_indx=strfind(regionname,' ');
    regionname(dash_indx)='_';
    dash_indx=strfind(regionname,'.');
    regionname(dash_indx)='';
    dash_indx=strfind(regionname,'&');
    regionname(dash_indx)='';
    regions.regionname_clean{region_count}=regionname;
    clear dash_indx

    
    %establish gdp and pop variables
    [indx_of_reg_poptab,regions_match_pop,~]=regions_and_countries(poptab.CountryCode,regionname_orig,'regionmembership.csv');
    regions_match_indx_pop=find(strcmp(regionname_orig,regions_match_pop));    
    [indx_of_reg_ppptab,regions_match_ppp,~]=regions_and_countries(ppptab.CountryCode,regionname_orig,'regionmembership.csv');
    regions_match_indx_ppp=find(strcmp(regionname_orig,regions_match_ppp));
    
    for modelcounter=1:number_models
        % SET UP TABLE
        raw_regional_results(modelcounter,region_count).reg=table([1960:2016]','VariableNames',{'Years'});
        raw_regional_results(modelcounter,region_count).reg.pop=sum(poptab{indx_of_reg_poptab==regions_match_indx_pop,6:end},1)';
        raw_regional_results(modelcounter,region_count).reg.gdp=sum(ppptab{indx_of_reg_ppptab==regions_match_indx_ppp,5:end},1)';
        raw_regional_results(modelcounter,region_count).reg.gdp_cap=raw_regional_results(modelcounter,region_count).reg.gdp./raw_regional_results(modelcounter,region_count).reg.pop/1000;
        
        raw_regional_results(modelcounter,region_count).regionmodname=[modelname{modelcounter},'_',regionname];
        raw_regional_results(modelcounter,region_count).regionname=regionname;
        %plus additional table for scaling for missing countries
        %(modification based on macro data)
        tmp_mod_macro=table([1960:2016]','VariableNames',{'Years'});
    end
    clear indx_of_reg_poptab 
    
  
    for modelcounter=1:number_models
        %%
        
        clear regrate
        %%%%%%%%%%%%%%%%%%%%%%
        %this section gets the correct indices for matching the emission data
        
        %production account
        [indx_of_reg_pbca,regions_match_pbca,~]=regions_and_countries(pbca_emis.(modelname{modelcounter}).ISO3,regionname_orig,'regionmembership.csv');
        reg_match_indx_pbca=find(strcmp(regionname_orig,regions_match_pbca));
        %consumption account:
        [indx_of_reg_cbca,regions_match_cbca,~]=regions_and_countries(cbca_emis.(modelname{modelcounter}).ISO3,regionname_orig,'regionmembership.csv');
        reg_match_indx_cbca=find(strcmp(regionname_orig,regions_match_cbca));
        
        %%%%%%%%%%%%%%%%%%%%%%
        % then adjusts population and GDP data for incomplete country
        % coverage
        % firstly for production accounts:
        clear reg_matches  matchvals
        
        [reg_matches,~,~]=intersect(pbca_emis.(modelname{modelcounter}).ISO3(indx_of_reg_pbca==reg_match_indx_pbca),ppptab.CountryCode(indx_of_reg_ppptab==regions_match_indx_ppp));
        [~,~,matchvals]=intersect(reg_matches,ppptab.CountryCode);
        tmp_mod_macro.gdpt=sum(ppptab{matchvals,5:end},1)';
        
        % secondly for cbcaumption accounts:


        [reg_matches,~,~]=intersect(cbca_emis.(modelname{modelcounter}).ISO3(indx_of_reg_cbca==reg_match_indx_cbca),ppptab.CountryCode(indx_of_reg_ppptab==regions_match_indx_ppp));
        [~,~,matchvals]=intersect(reg_matches,ppptab.CountryCode);
        tmp_mod_macro.gdpc=sum(ppptab{matchvals,5:end},1)';
        %%%%%%%%%%%%%%%%%%%%%%
        clear reg_matches  matchvals
        
        %calculate % coverage for population and gdp for what is available
        %both in pbca and cbca accounts
        tmp_mod_macro.gdpt_percent=tmp_mod_macro.gdpt./raw_regional_results(modelcounter,region_count).reg.gdp;
        tmp_mod_macro.gdpc_percent=tmp_mod_macro.gdpc./raw_regional_results(modelcounter,region_count).reg.gdp;
        
        
        %report the missing countries:
        missing_countries=setxor(cbca_emis.(modelname{modelcounter}).ISO3(indx_of_reg_cbca==reg_match_indx_cbca),ppptab.CountryCode(indx_of_reg_ppptab==regions_match_indx_ppp))';
        if ~isempty(missing_countries)
            % note - fails for Taiwan, which is in the emissions data,
            % but not Population or GDP data
            if length(indx_of_reg_cbca)>1
                disp([modelname{modelcounter} ,' missing these countries from the regional aggregation: ', strjoin(missing_countries(:))])
                disp(['     Percent missing in gdp: ', num2str(100*(1-mean(tmp_mod_macro.gdpt_percent))),'%'])
            else
                
            disp([modelname{modelcounter} ,' missing this country :',missing_countries{:},''])
            end
        end

        % We now report the regional result, adjusted by the % of GDP that
        % was missing (e.g. if NZL is missing from the OECD region for
        % WIOD, and NZL is 1% of the GDP of the OECD, we inflate WIOD's
        % emission account by 1%
%         tmp_emis=nansum(pbca_emis.(modelname{modelcounter}){indx_of_reg_pbca==reg_match_indx_pbca,3:end},1)';
        tmp_emis=pbca_emis.(modelname{modelcounter}){indx_of_reg_pbca==reg_match_indx_pbca,3:end};
        tmp_emis_nan=pbca_emis.(modelname{modelcounter}){indx_of_reg_pbca==reg_match_indx_pbca,3:end};
        % find how many nans there are:
        numbers_nans=sum(isnan(tmp_emis_nan),1);
%       find years that have NaN values:
        for i=1:size(tmp_emis_nan,2)
            if (numbers_nans(i)>0) && (numbers_nans(i)<size(tmp_emis,1))
                %get benchmark year % of emissions, and if more than 5%
                %then disregard the data for this region for these years
                if sum(tmp_emis_nan(isnan(tmp_emis_nan(:,i)),bench_year),1)/sum(tmp_emis_nan(:,bench_year),1) >0.05
                    tmp_emis(:,i)=NaN;
                end
            end
        end
        clear i tmp_emis_nan
        tmp_emis=nansum(tmp_emis,1)';                
            
        raw_regional_results(modelcounter,region_count).reg.pbca(1:length(tmp_emis),1)=tmp_emis.*tmp_mod_macro.gdpt_percent(1:length(tmp_emis));
        
        tmp=nansum(cbca_emis.(modelname{modelcounter}){indx_of_reg_cbca==reg_match_indx_cbca,3:end},1)';
        raw_regional_results(modelcounter,region_count).reg.cbca(1:length(tmp),1)=tmp.*tmp_mod_macro.gdpc_percent(1:length(tmp));
        clear tmp_emis tmp
        %%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        %set zeros to NaN
        tmp=table2array(raw_regional_results(modelcounter,region_count).reg);
        tmp(raw_regional_results(modelcounter,region_count).reg{:,:}==0)=NaN;
        for i=1:6 % 6 columns (types) worth of data reported
            raw_regional_results(modelcounter,region_count).reg(:,i)=table(tmp(:,i));
        end
        clear tmp
        
        %create per-cap and per-gdp
        raw_regional_results(modelcounter,region_count).reg.pbca_cap=raw_regional_results(modelcounter,region_count).reg.pbca./raw_regional_results(modelcounter,region_count).reg.pop*1e6;
        raw_regional_results(modelcounter,region_count).reg.cbca_cap=raw_regional_results(modelcounter,region_count).reg.cbca./raw_regional_results(modelcounter,region_count).reg.pop*1e6;
        raw_regional_results(modelcounter,region_count).reg.cbca_gdp=raw_regional_results(modelcounter,region_count).reg.cbca./raw_regional_results(modelcounter,region_count).reg.gdp;        %%
        
        %global emissions - only GCP has regions in it which prevent
        %summing over all.
        if strcmp(modelname(modelcounter),'GCP')
            raw_regional_results(modelcounter,region_count).reg.glob(1:size(pbca_emis.(modelname{modelcounter}),2)-2,1)=sum(pbca_emis.(modelname{modelcounter}){end,3:end},1)';
        else
            raw_regional_results(modelcounter,region_count).reg.glob(1:size(pbca_emis.(modelname{modelcounter}),2)-2,1)=sum(pbca_emis.(modelname{modelcounter}){:,3:end},1)';
        end
        raw_regional_results(modelcounter,region_count).reg.glob(raw_regional_results(modelcounter,region_count).reg.glob==0)=NaN;
        
    end
end

save('A2_All_model_results.mat','raw_regional_results','regions','world','modelname')


