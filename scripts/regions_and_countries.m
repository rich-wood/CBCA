function [ codes, names, conames ] = regions_and_countries( a3s, region_type, regionmbmershipFN )
% Wrapper function for regions.m so as to also report individual country
% matches, otherwise calls regions.m to match regions to individual
% countries.

tmp=strcmp(a3s,region_type);
if any(tmp)
    codes=2-tmp; %mimic behaveiour of regions function by setting matches to 1, and rest to 2.
    names={region_type};
    conames={region_type};
    return
end
try
[ codes, names, conames ] = regions( a3s, region_type, regionmbmershipFN );
catch
    codes=[];
    names=[];
    conames=[];
end