% create sublot of Fig2


close all
f1=openfig('C:\Users\richardw\Box Sync\_Mdrive\Papers\2019_CarbonFootprintMultiModel\code\figs\aScatter_1.fig');
ax1 = gca;
ax1.Title.String={['a) ',ax1.Title.String{1}]}
f2=openfig('C:\Users\richardw\Box Sync\_Mdrive\Papers\2019_CarbonFootprintMultiModel\code\figs\aScatter_2.fig');
ax2 = gca;
ax2.Title.String={['b) ',ax2.Title.String{1}]}

fnew = figure;
ax1_copy = copyobj(ax1,fnew);
subplot(1,2,1,ax1_copy)
ax2_copy = copyobj(ax2,fnew);
subplot(1,2,2,ax2_copy)
lgd=legend([{'Raw'}',{'Normalised'}',{['Raw ']},{['Normalised ']}])
lgd.NumColumns=2