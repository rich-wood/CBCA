% a1_GHG_load.m - process source data to a cbcaistent data structure

% Manuscript Title: Variation in trends of consumption based carbon accounts 
% Authors: Richard Wood, Daniel Moran, Konstantin Stadler
% Contact: richard.wood@ntnu.no
% Git repo: https://github.com/rich-wood/CBCA

% Master script:
% MAIN.m
% Dependencies:
% source data
% Adidtional comments:
% Script takes source data on production and consumption accounts and sets
% it into a common format over a common time span. Number of
% countries/regions is variable.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load model results
modelcounter=0;
modelcounter=modelcounter+1;
meta.modelname(modelcounter)={'GCP'};
co2factor(modelcounter)=3.664;
start_year(modelcounter)=1960;

modelcounter=modelcounter+1;
meta.modelname(modelcounter)={'Eora'};
co2factor(modelcounter)=1e-3;
start_year(modelcounter)=1970;

modelcounter=modelcounter+1;
meta.modelname(modelcounter)={'EXIOBASE'};
co2factor(modelcounter)=1e-3;
start_year(modelcounter)=1990;

modelcounter=modelcounter+1;
meta.modelname(modelcounter)={'WIOD'};
co2factor(modelcounter)=1e-3;
start_year(modelcounter)=1990;

modelcounter=modelcounter+1;
meta.modelname(modelcounter)={'ICIO'};
co2factor(modelcounter)=1;
start_year(modelcounter)=1995;

% more models can be added here 


meta.years=1960:2016;

meta.number_models=modelcounter;

% this loop puts all models into a consistent format, some "manual"
% renaming is done
for modelcounter=1:meta.number_models
    
    pbca_emis.(meta.modelname{modelcounter})=readtable(['source\',meta.modelname{modelcounter},'_prod.xlsx'],'FileType','spreadsheet');
    cbca_emis.(meta.modelname{modelcounter})=readtable(['source\',meta.modelname{modelcounter},'_cons.xlsx'],'FileType','spreadsheet');
    
    %note when matlab reads tables, default header names are VarX if blank
    %- these are replaced later.
    if strcmp(meta.modelname(modelcounter),'Eora')
        pbca_emis.(meta.modelname{modelcounter}).Var1=pbca_emis.(meta.modelname{modelcounter}).ISO3; %re-sort header names
        cbca_emis.(meta.modelname{modelcounter}).Var1=cbca_emis.(meta.modelname{modelcounter}).ISO3; %re-sort header names
        pbca_emis.(meta.modelname{modelcounter}).ISO3=[]; %re-sort header names
        cbca_emis.(meta.modelname{modelcounter}).ISO3=[]; %re-sort header names
        
        
        %set all NaN to zero:
%         tmp=table2array(cbca_emis.('Eora')(:,3:end));
%         tmp(isnan(tmp))=0;
%         cbca_emis.(meta.modelname{modelcounter})(:,3:end)=num2cell(tmp);
%         tmp=table2array(pbca_emis.('Eora')(:,3:end));
%         tmp(isnan(tmp))=0;
%         pbca_emis.(meta.modelname{modelcounter})(:,3:end)=num2cell(tmp);


        
        
    elseif strcmp(meta.modelname(modelcounter),'ICIO')
        pbca_emis.(meta.modelname{modelcounter}).Properties.VariableNames(1)={'Var1'}; %re-sort header names
        cbca_emis.(meta.modelname{modelcounter}).Properties.VariableNames(1)={'Var1'}; %re-sort header names
        
        %remove discrepancy data for OECD:
        cbca_emis.(meta.modelname{modelcounter})(63,:)=[];
        
    elseif strcmp(meta.modelname(modelcounter),'GCP')
        pbca_emis.(meta.modelname{modelcounter}).Var1=pbca_emis.(meta.modelname{modelcounter}).Var2; %re-sort header names
        cbca_emis.(meta.modelname{modelcounter}).Var1=pbca_emis.(meta.modelname{modelcounter}).Var2; %re-sort header names
        pbca_emis.(meta.modelname{modelcounter}).Var2=[]; %re-sort header names
        cbca_emis.(meta.modelname{modelcounter}).Var2=[]; %re-sort header names
        pbca_emis.(meta.modelname{modelcounter}).x1959=[]; %remove year 1959 (start 1960)
        cbca_emis.(meta.modelname{modelcounter}).x1959=[]; %remove year 1959 (start 1960)
    end
    
    
    %identify which countries are which, report all countries not matched, or regions which are not used further:
    [iout,cnt]=indCountry(pbca_emis.(meta.modelname{modelcounter}).Var1);
    if any(iout.unknown)
        disp(['missing countries in ',meta.modelname{modelcounter}])
        pbca_emis.(meta.modelname{modelcounter}).Var1(iout.unknown)
    end
    
    %assgin ISO3 code:
%     %if matlab r2018 or later:
%     pbca_emis.(meta.modelname{modelcounter}) = addvars(pbca_emis.(meta.modelname{modelcounter}),cnt.ISO3,'After','Var1');
%     [~,cnt]=indCountry(cbca_emis.(meta.modelname{modelcounter}).Var1);
%     cbca_emis.(meta.modelname{modelcounter}) = addvars(cbca_emis.(meta.modelname{modelcounter}),cnt.ISO3,'After','Var1');
%     pbca_emis.(meta.modelname{modelcounter}).Properties.VariableNames{'Var2'} = 'ISO3';
%     cbca_emis.(meta.modelname{modelcounter}).Properties.VariableNames{'Var2'} = 'ISO3';
    
%     if matlab r2017 or earlier
    pbca_emis.(meta.modelname{modelcounter}).ISO3=cnt.ISO3;
    size_model=size(pbca_emis.(meta.modelname{modelcounter}),2);
    pbca_emis.(meta.modelname{modelcounter})=pbca_emis.(meta.modelname{modelcounter})(:,[1,size_model,2:size_model-1]);
    [~,cnt]=indCountry(cbca_emis.(meta.modelname{modelcounter}).Var1);
    cbca_emis.(meta.modelname{modelcounter}).ISO3=cnt.ISO3;
    cbca_emis.(meta.modelname{modelcounter})=cbca_emis.(meta.modelname{modelcounter})(:,[1,size_model,2:size_model-1]);
    
    
    
    %set standard start year of data (filled with zeros):
    for yearcnt=start_year(modelcounter)-1:-1:meta.years(1)
        tmp=table(zeros(size(cbca_emis.(meta.modelname{modelcounter}).Var1,1),1),'VariableName',{['x',num2str(yearcnt)]});
        cbca_emis.(meta.modelname{modelcounter})=[cbca_emis.(meta.modelname{modelcounter})(:,1:2),tmp,cbca_emis.(meta.modelname{modelcounter})(:,3:end)];
        tmp=table(zeros(size(pbca_emis.(meta.modelname{modelcounter}).Var1,1),1),'VariableName',{['x',num2str(yearcnt)]});
        pbca_emis.(meta.modelname{modelcounter})=[pbca_emis.(meta.modelname{modelcounter})(:,1:2),tmp,pbca_emis.(meta.modelname{modelcounter})(:,3:end)];
    end
    
%    Rename ROM to ROU (Romania)
    pbca_emis.(meta.modelname{modelcounter}).ISO3(strcmp('ROM',pbca_emis.(meta.modelname{modelcounter}).ISO3))={'ROU'};
    cbca_emis.(meta.modelname{modelcounter}).ISO3(strcmp('ROM',cbca_emis.(meta.modelname{modelcounter}).ISO3))={'ROU'};
    
    %Applying USR code to Former USSR
    pbca_emis.(meta.modelname{modelcounter}).ISO3(strcmp('USR',pbca_emis.(meta.modelname{modelcounter}).Var1))={'USR'};
    cbca_emis.(meta.modelname{modelcounter}).ISO3(strcmp('USR',cbca_emis.(meta.modelname{modelcounter}).Var1))={'USR'};
    
    % rescale data to predefined conversion factor to express everything in
    % Gg CO2-eq. Can't multiple a table by a scalar. can for an array...
    cbca_emis.(meta.modelname{modelcounter})(:,3:end)=array2table(table2array(cbca_emis.(meta.modelname{modelcounter})(:,3:end))*co2factor(modelcounter));
    pbca_emis.(meta.modelname{modelcounter})(:,3:end)=array2table(table2array(pbca_emis.(meta.modelname{modelcounter})(:,3:end))*co2factor(modelcounter));
    
    
end
clear co2factor size_model tmp
%%
save('A1_Raw_data','pbca_emis','cbca_emis','meta')