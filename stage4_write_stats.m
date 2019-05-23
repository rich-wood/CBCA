% a4_write_stats.m - script to write SI data to Excel.

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler, Joao Rodrigues
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA

% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 3 (a3_ghg_harmonise_models.m) required.
% Adidtional comments:
% script to write SI data to Excel.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load previous stage data.


load('results\cf_multimodel_normalised_results.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write out basic accounts:
writetable(summmary_mean,'Production_and_consumption_database2.xlsx','Sheet','Emission accounts harmonised')

%%
tmp_raw_p_rsd=[struct_results.raw.p(meta.regions.unique_country).rsd];
tmp_raw_c_rsd=[struct_results.raw.c(meta.regions.unique_country).rsd];
tmp_norm_p_rsd=[struct_results.norm.p(meta.regions.unique_country).rsd];
tmp_norm_c_rsd=[struct_results.norm.c(meta.regions.unique_country).rsd];
tmp_p_n=[struct_results.raw.p(meta.regions.unique_country).n];
filterx=(tmp_norm_p_rsd)>=1e-5 & (tmp_p_n>2);
tmp_raw_p_rad=[struct_results.raw.p(meta.regions.unique_country).rad];
tmp_raw_c_rad=[struct_results.raw.c(meta.regions.unique_country).rad];
tmp_norm_p_rad=[struct_results.norm.p(meta.regions.unique_country).rad];
tmp_norm_c_rad=[struct_results.norm.c(meta.regions.unique_country).rad];
tmp_p_n=[struct_results.raw.p(meta.regions.unique_country).n];



% Write out averages:
reg_rsd=table([meta.regions.name';{'Naive Average'}],'VariableNames',{'Region'}); % 

for i=1:length(meta.regions.name)
    regionname=meta.regions.regionname_clean{i};
    reg_rsd(i,1+1)=table(100*mean(tabular_results.raw.p.(['rsd_',regionname])(36:55)));
    reg_rsd(i,1+2)=table(100*mean(tabular_results.raw.c.(['rsd_',regionname])(36:54)));
    reg_rsd(i,1+3)=table(100*mean(tabular_results.norm.p.(['rsd_',regionname])(36:55)));
    reg_rsd(i,1+4)=table(100*mean(tabular_results.norm.c.(['rsd_',regionname])(36:54)));
    reg_rsd(i,1+5)=table(100*mean(tabular_results.raw.p.(['rad_',regionname])(36:55)));
    reg_rsd(i,1+6)=table(100*mean(tabular_results.raw.c.(['rad_',regionname])(36:54)));
    reg_rsd(i,1+7)=table(100*mean(tabular_results.norm.p.(['rad_',regionname])(36:55)));
    reg_rsd(i,1+8)=table(100*mean(tabular_results.norm.c.(['rad_',regionname])(36:54)));
end
% naive average over all:
reg_rsd(i+1,2)=table(100*mean(tmp_raw_p_rsd(filterx)));
reg_rsd(i+1,3)=table(100*mean(tmp_raw_c_rsd(filterx)));
reg_rsd(i+1,4)=table(100*mean(tmp_norm_p_rsd(filterx)));
reg_rsd(i+1,5)=table(100*mean(tmp_norm_c_rsd(filterx)));
reg_rsd(i+1,6)=table(100*mean(tmp_raw_p_rad(filterx)));
reg_rsd(i+1,7)=table(100*mean(tmp_raw_c_rad(filterx)));
reg_rsd(i+1,8)=table(100*mean(tmp_norm_p_rad(filterx)));
reg_rsd(i+1,9)=table(100*mean(tmp_norm_c_rad(filterx)));

reg_rsd(69,:)=[];

reg_rsd.Properties.VariableNames={'Region','PBCA_RSD_Raw','CBCA_RSD_Raw','PBCA_RSD_norm','CBCA_RSD_norm','PBCA_RAD_Raw','CBCA_RAD_Raw','PBCA_RAD_norm','CBCA_RAD_norm'}

writetable(reg_rsd,'Production_and_consumption_database2.xlsx','Sheet','RSD_average')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Write out RSD and RAD measures

p_rsd=[struct_results.raw.p(:).rsd];
c_rsd=[struct_results.raw.c(:).rsd];
p_rad=[struct_results.raw.p(:).rad];
c_rad=[struct_results.raw.c(:).rad];

xlswrite('Production_and_consumption_database2.xlsx',p_rsd(31:end,:),'P_RSD_raw','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rsd(31:end,:),'C_RSD_raw','b2')
xlswrite('Production_and_consumption_database2.xlsx',p_rad(31:end,:),'P_RMD_raw','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rad(31:end,:),'C_RMD_raw','b2')
clear p_rsd p_rad c_rsd c_rad

p_rsd=[struct_results.norm.p(:).rsd];
c_rsd=[struct_results.norm.c(:).rsd];
p_rad=[struct_results.norm.p(:).rad];
c_rad=[struct_results.norm.c(:).rad];

xlswrite('Production_and_consumption_database2.xlsx',p_rsd(31:end,:),'P_RSD_norm','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rsd(31:end,:),'C_RSD_norm','b2')
xlswrite('Production_and_consumption_database2.xlsx',p_rad(31:end,:),'P_RMD_norm','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rad(31:end,:),'C_RMD_norm','b2')
clear p_rsd p_rad c_rsd c_rad

p_rsd=[struct_results.gr.p(:).rsd];
c_rsd=[struct_results.gr.c(:).rsd];
p_rad=[struct_results.gr.p(:).rad];
c_rad=[struct_results.gr.c(:).rad];

xlswrite('Production_and_consumption_database2.xlsx',p_rsd(31:end,:),'P_RSD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rsd(31:end,:),'C_RSD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',p_rad(31:end,:),'P_RMD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rad(31:end,:),'C_RMD_gr','b2')
clear p_rsd p_rad c_rsd c_rad




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
for i=5:12+4
    xlswrite('Production_and_consumption_database2.xlsx',meta.regions.name,i,'b1')
    xlswrite('Production_and_consumption_database2.xlsx',meta.years(31:end)',i,'a2')
end

disp('finished')