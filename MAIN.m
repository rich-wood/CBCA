% Contents script for data on 
% Variation in trends of consumption based carbon accounts
% Richard Wood , Daniel Moran, Konstantin Stadler



% Note there are some issues with matlab versions for some scripts - it is
% now tested and working with Matlab 2018b.
% Otherwise, if functions missing, ensure relevant toolboxes or more recent versions are installed.
%

addpath('.\scripts\')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load raw data, sort out ISO country codes:
a1_GHG_Load

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create structure of accounts for specified countries/regions.
%add in population and gdp variables
a2_ghg_organise_regions

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%harmonise results across different models, apply statistical tests
a3_ghg_harmonise_models

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write out supporting information for paper
a4_write_stats

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot model results before and after indexing.
a5_scatter_with_rsd_EU

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot figure scatter
a5_fig_scatterplots
