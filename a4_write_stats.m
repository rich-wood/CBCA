% a4_write_stats.m - script to write SI data to Excel.

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler
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

load('A3_TimeSeriesCalcs.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write out basic accounts:
writetable(summmary_mean(:,[1:6,9:18,21:30,33:52,55:end]),'Production_and_consumption_database2.xlsx','Sheet','Emission accounts')


% Write out averages:
reg_rsd=table(regions.name','VariableNames',{'Region'}); % 

for i=1:49
    regionname=regions.regionname_clean{i};
    reg_rsd(i,1+1)=table(100*mean(tabular_results.raw.p.(['rsd_',regionname])(36:55)));
    reg_rsd(i,1+2)=table(100*mean(tabular_results.raw.c.(['rsd_',regionname])(36:54)));
    reg_rsd(i,1+3)=table(100*mean(tabular_results.norm.p.(['rsd_',regionname])(36:55)));
    reg_rsd(i,1+4)=table(100*mean(tabular_results.norm.c.(['rsd_',regionname])(36:54)));
    reg_rsd(i,1+5)=table(100*mean(tabular_results.raw.p.(['rad_',regionname])(36:55)));
    reg_rsd(i,1+6)=table(100*mean(tabular_results.raw.c.(['rad_',regionname])(36:54)));
    reg_rsd(i,1+7)=table(100*mean(tabular_results.norm.p.(['rad_',regionname])(36:55)));
    reg_rsd(i,1+8)=table(100*mean(tabular_results.norm.c.(['rad_',regionname])(36:54)));
end
reg_rsd.Properties.VariableNames={'Region','PBCA_RSD_Raw','CBCA_RSD_Raw','PBCA_RSD_ind','CBCA_RSD_ind','PBCA_RAD_Raw','CBCA_RAD_Raw','PBCA_RAD_ind','CBCA_RAD_ind'}

writetable(reg_rsd,'Production_and_consumption_database2.xlsx','Sheet','RSD')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Write out RSD and RAD measures

p_rsd=[struct_results.raw.p(:).rsd];
c_rsd=[struct_results.raw.c(:).rsd];
p_rad=[struct_results.raw.p(:).rad];
c_rad=[struct_results.raw.c(:).rad];

xlswrite('Production_and_consumption_database2.xlsx',p_rsd(21:end,:),'P_RSD','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rsd(31:end-1,:),'C_RSD','b2')
xlswrite('Production_and_consumption_database2.xlsx',p_rad(21:end,:),'P_RAD','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rad(31:end-1,:),'C_RAD','b2')
clear p_rsd p_rad c_rsd c_rad

p_rsd=[struct_results.gr.p(:).rsd];
c_rsd=[struct_results.gr.c(:).rsd];
p_rad=[struct_results.gr.p(:).rad];
c_rad=[struct_results.gr.c(:).rad];

xlswrite('Production_and_consumption_database2.xlsx',p_rsd(31:55,:),'P_RSD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rsd(31:55,:),'C_RSD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',p_rad(31:55,:),'P_RAD_gr','b2')
xlswrite('Production_and_consumption_database2.xlsx',c_rad(31:55,:),'C_RAD_gr','b2')
clear p_rsd p_rad c_rsd c_rad

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('finished')