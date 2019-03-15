function datain=stat_funcs(datain,n_models,region_count)
%calculate basic mean, std, and abs , rel diff for the data fields used
%here.

datain(region_count).std=std(datain(region_count).all,0,2,'omitnan');
datain(region_count).mean=mean(datain(region_count).all,2,'omitnan');
datain(region_count).rsd=abs(datain(region_count).std./datain(region_count).mean);
datain(region_count).n=sum(~isnan(datain(region_count).all),2);
for i=1:n_models
    datain(region_count).abs_diff(:,i)=nansum(abs(datain(region_count).all(:,i)-datain(region_count).all(:,setxor(i,[1:n_models]))),2)./datain(region_count).n;
end
datain(region_count).mean_diff=nansum(datain(region_count).abs_diff,2)./datain(region_count).n;
datain(region_count).rad=abs(datain(region_count).mean_diff./datain(region_count).mean);
