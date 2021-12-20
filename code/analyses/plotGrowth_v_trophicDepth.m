function plotGrowth_v_trophicDepth()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp


%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
trophicDepths        = trophicStats.trophicDepths_overTime(:,1);
growthRates          = growthStats.countryRealLocalPerHourGrowthRates_timeAve;
countryGammaTwiddles = gammaStats.gammaTwiddles_overTime(:,1);
countryCodes         = WorldEconomy(1).countryCodes;

% Allow for a robustness check: change the end year used for the price returns
years         = [WorldEconomy.t];
years         = years(1:end-1);  %remove 1 year because you have first-differenced the data
endYear       = 2009;
iLast         = find(years == endYear-1);
growthRates_overTime = growthStats.countryRealLocalPerHourGrowthRates_overTime;
growthRates  = sum(growthRates_overTime(:,1:iLast), 2) / iLast;

% Change units to percent per year
growthRates          = growthRates * 100;
countryGammaTwiddles = countryGammaTwiddles * 100;

% Regress countryGammaTwiddles on output multipliers
mask     = ~isnan(trophicDepths) & ~isnan(countryGammaTwiddles);
Y        = countryGammaTwiddles(mask);
X        = trophicDepths(mask);
fitStats_gamma = regstats(Y, X, 'linear');
beta_gamma     = fitStats_gamma.beta;
R2_gamma       = fitStats_gamma.rsquare;
stdErr_gamma   = fitStats_gamma.tstat.se;
tvals_gamma    = fitStats_gamma.tstat.t;
pvals_gamma    = fitStats_gamma.tstat.pval;
CIs_gamma      = [beta_gamma-2*stdErr_gamma beta_gamma+2*stdErr_gamma];
pval_intercept_gamma = pvals_gamma(1);
pval_slope_gamma     = pvals_gamma(2);

% Regress growth rates on output multipliers
mask     = ~isnan(trophicDepths) & ~isnan(growthRates);
Y        = growthRates(mask);
X        = trophicDepths(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);

[rho,pval] = corr(X,Y);

dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)

dispc( ['Pearson correlation: ',num2str(rho),'   (p = ',num2str(pval),')'] )


% Bin data by trophic level, and compute statistics in each bin
binEdges          = equalCountBinning(trophicDepths, 5);
binStats          = binDataBy(growthRates,trophicDepths,binEdges);
binMeanTD         = binStats.Xmean;
binMeanGrowthRate = binStats.Ymean;
binStdGrowthRate  = binStats.Ystd;
binStdOfMean      = binStdGrowthRate ./ sqrt(binStats.count);


% Quantify how well the ave. OM predicts growth among countries
% 1- Find the average country in our sample in terms of our output
% multiplier
countryTable = table(countryCodes, trophicDepths, growthRates);
countryTable.Properties.RowNames = countryTable.countryCodes;
countryTable.countryCodes = [];
sortrows(countryTable, 'trophicDepths')

averageCountry       = 'IDN';
deeperCountry1       = 'LTU';
aveOM0               = countryTable{averageCountry,'trophicDepths'};
aveOM1               = countryTable{deeperCountry1,'trophicDepths'};
predictedGrowthRatio = aveOM1 / aveOM0;
actualGrowthRate0    = countryTable{averageCountry,'growthRates'};
actualGrowthRate1    = countryTable{deeperCountry1,'growthRates'};
actualGrowthRatio    = actualGrowthRate1 / actualGrowthRate0;


medianTrophicDepth  = median(trophicDepths);
averageTrophicDepth = mean(trophicDepths);
stdevTrophicDepth   = std(trophicDepths);

dispc( ['Median of ave. OMs across countries  = ',num2str(medianTrophicDepth)] )
dispc( ['Average of ave. OMs across countries = ',num2str(averageTrophicDepth)] )
dispc( ['Ave. OM 1 stan. dev. above the mean  = ',num2str(averageTrophicDepth + stdevTrophicDepth)] )
dispc( [averageCountry,'  (OM = ',num2str(aveOM0),')'] )
dispc( [deeperCountry1,'  (OM = ',num2str(aveOM1),')'] )
dispc(predictedGrowthRatio)
dispc(actualGrowthRatio)



%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim  = [2.15 4.2];
yLim  = [-1 9];
xTick = [2.5:0.5:4];
yTick = [-0.01:0.01:0.1] * 100;
trophicDepthRange = [min(trophicDepths) max(trophicDepths)];
binAverageMarkerSize = 20;

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
set(gca, 'Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
hData       = plot(trophicDepths, growthRates, '.', 'MarkerSize',28, 'Color',ap.moneyColor);
hRegression = plot(trophicDepthRange, beta(1) + beta(2)*trophicDepthRange, 'k-', 'LineWidth',2);
hold off

% Plot country codes
xscale       = 0.1;
yscale       = 1;
x            = trophicDepths   + 0.2*xscale;
y            = growthRates + 0.2*yscale;
text(x,y,countryCodes)

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'YTick',yTick)
consistentTickPrecision(gca,'x',1)
set(gca, 'FontSize',ap.fontSize)
xlabel('Average output multiplier in 1995')
ylabel({'Growth rate real GDP per hour', '1995-2009 (% yr^{-1})'})

% Legend
hLegend = legend([hData hRegression], 'growth rate', 'regression', 'Location','NorthWest');
set(hLegend, 'Box','off', 'FontSize',ap.fontSize)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'Growth_v_OM';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end