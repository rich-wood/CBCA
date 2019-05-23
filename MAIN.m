% Contents script for data on 
% Variation in trends of consumption based carbon accounts
% Richard Wood , Daniel Moran, Konstantin Stadler, Joao Rodrigues



% Note there are some issues with matlab versions for some scripts - it is
% now tested and working with Matlab 2018b.
% Otherwise, if functions missing, ensure relevant toolboxes or more recent versions are installed.
%

addpath('.\scripts\')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load raw data, sort out ISO country codes:
stage1_cf_load_raw_data

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create structure of accounts for specified countries/regions.
%add in population and gdp variables
stage2_cf_organise_regions

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%harmonise results across different models, apply statistical tests
stage3_cf_harmonise_models

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write out supporting information for paper
stage4_write_db
stage4_write_stats

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot model results before and after indexing.
stage5_fig_line_with_rsd

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot figure scatter
stage5_fig_scatterplots
