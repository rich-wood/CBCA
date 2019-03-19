% a4_write_db.m - script for generating plots used in paper.

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA


% Master script:
% MAIN.m
% Dependencies:
% compiled data from stage 3 (a3_ghg_harmonise_models.m) required
% Adidtional comments:
% crude script to dump out all data to a csv and xlsx file
% excludes all individual model observations (available in
% struct_results variable)


clear 

%load data:
load('A3_TimeSeriesCalcs.mat') % 


db_counter=0;

i_fields=fields(struct_results);
for i=1:length(i_fields)
    i_struct=struct_results.(i_fields{i});
    j_fields=fields(i_struct);
        for j=1:length(j_fields)
            j_struct=i_struct.(j_fields{j});
            for k=1:length(meta.regions.name)
                k_block=length(j_struct(k).mean);
                dbtxt(db_counter+1:db_counter+k_block,1)=meta.regions.name(k);
                dbtxt(db_counter+1:db_counter+k_block,2)=i_fields(i);
                dbtxt(db_counter+1:db_counter+k_block,3)=j_fields(j);
                if i==2 %growth rates are one less year of data avail
                db(db_counter+1:db_counter+k_block,1)=1961:2016;
                else
                db(db_counter+1:db_counter+k_block,1)=1960:2016;
                end
                db(db_counter+1:db_counter+k_block,2)=j_struct(k).mean;
                db(db_counter+1:db_counter+k_block,3)=j_struct(k).rsd;                
                db(db_counter+1:db_counter+k_block,4)=j_struct(k).rad;
                db(db_counter+1:db_counter+k_block,5)=j_struct(k).n;
                db_counter=db_counter+k_block;
            end
        end
end

% replace abstract variable names with words
dbtxt(strcmp('norm',dbtxt))={'Normalised'};
dbtxt(strcmp('raw',dbtxt))={'Raw'};
dbtxt(strcmp('gr',dbtxt))={'Growth Rates'};
dbtxt(strcmp('p',dbtxt))={'PBCA'};
dbtxt(strcmp('c',dbtxt))={'CBCA'};
dbtxt(strcmp('g',dbtxt))={'Global Result'};
dbtxt(strcmp('t',dbtxt))={'Transfers'};


xlswrite('db.csv', [{'RegionName'},{'Type of adjustment'},{'Measure'},{'Year'},{'Mean'},{'RSD'},{'RAD'},{'n'}],1,'A1')
xlswrite('db.csv', dbtxt,1,'A2')
xlswrite('db.csv', db,1,'D2')
