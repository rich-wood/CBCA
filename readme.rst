Source code for the Multi Model mean paper

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Joao Rodrigues, Konstantin Stadler
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA



In this work we present results of all the major global models and normalise the model results by looking at changes over time relative to a common base year value.  
We give an analysis of the variability across the models, both before and after normalisation in order to give insights into variance at national and regional level. 
A dataset of harmonised results (based on means) and measures of dispersion is presented, providing a baseline dataset for CBCA validation and analysis.

The dataset is intended as a goto dataset for country and regional results of consumption and production based accounts. The normalised mean for each country/region is the principle result that can be used to assess the magnitude and trend in the emission accounts. However, an additional key element of the dataset are the measures of robustness and spread of the results across the source models. These metrics give insight into the amount of trust should be placed in the individual country/region results.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Final data of interest:
cf_multimodel_normalised_results.mat &/or cf_multimodel_db.csv

Final results (mean and measures of variation) are presented in 3 forms:

1. Data structure (matlab file - A3_normalised_results.mat)

2. Data table (matlab file  - A3_normalised_results.mat)

3. Database file csv

%%

1. Data structure (matlab file) "struct_results"

a. first level fields:
 -raw (absolute value of raw model data - only regional aggregation potentially applied)
 -gr (year on year growth rates)
 -norm (absolute value of normalised model data - results normalised to a common referene year and regional aggregation potentially applied)

b. second level fields:
 - p (PBCA)
 - c (CBCA)
 - t (the level of emission transfer (PBCA-CBCA)


b. third level fields, rows correspond to time dimension (in years, see meta):
 - all (all model results (listed with dimension year, model)
 - std (standard deviation) 
 - mean (mean) 
 - rsd (relative standard deviation) 
 - n (number of model observations) 
 - mean_diff (mean absolute differences) 
 - rad (relative mean absolute differences) 


2. Data table (matlab file) "tabular results"
Same naming convention as data structure above
Excludes the "all" struct (individual model results)



3. Database file csv
As per structure, but with synonyms:
'norm'='Normalised'
'raw'='Raw'
'gr'='Growth Rates'
'p'='PBCA'
'c'='CBCA'
'g'='Global Result'
't'='Transfers'
Excludes the "all" struct (individual model results)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
