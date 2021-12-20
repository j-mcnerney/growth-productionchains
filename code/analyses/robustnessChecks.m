function robustnessChecks()
% This file performs a robustness check to see whether changing the end
% year of our analysis alters the results.  In particular it checks the
% impact of excluding 2007-2009 (the Great Recession).

global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Prep data
%========================================================================%
announceFunction()

% Unpack data
gammaEstimates_overTime = gammaStats.gammaEstimates_overTime;
priceReturns_overTime   = returnStats.realReturns_overTime;
growthRates_overTime    = growthStats.countryRealLocalPerHourGrowthRates_overTime;
growthRates             = growthStats.countryRealLocalPerHourGrowthRates_timeAve;
countryCodes            = WorldEconomy(1).countryCodes;

% Change units to percent per year
priceReturns_overTime   = priceReturns_overTime * 100;
gammaEstimates_overTime = gammaEstimates_overTime * 100;
growthRates_overTime    = growthRates_overTime * 100;
growthRates             = growthRates * 100;

% Choose the time spans to plot
years     = [WorldEconomy.t];
years     = years(1:end-1);  %remove 1 year because (by looking at returns) you have first-differenced the data
firstYear = 1995;

% Choose robustnesss check to run
robustnessMode = 'none';   %none endYear timeAverage noTrade
switch robustnessMode
   case 'none'
      lastYears     = 2009;
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      trophicDepths = trophicStats.trophicDepths_overTime(:,1);
      
   case 'endYear'
      lastYears     = 2005;
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      trophicDepths = trophicStats.trophicDepths_overTime(:,1);
      
   case 'timeAverage'
      lastYears     = 2009;
      trophicLevels = trophicStats.trophicLevels_timeAve;
      trophicDepths = trophicStats.trophicDepths_timeAve;
      
   case 'noTrade'
      lastYears     = 2009;
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      trophicDepths = trophicStats.trophicDepths_overTime(:,1);
      % First, modify main.m to set turnOffTradeFlag.  Then run this file.
end


%========================================================================%
% Loop over time periods
%========================================================================%
% Setup figure
pricesFigure = newFigure( [mfilename,'.prices']);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   900])


growthFigure = newFigure( [mfilename,'.growth'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   900])

for iPeriod = 1:length(lastYears)
   lastYear_i = lastYears(iPeriod);
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Obtain rates of price change and productivity change over this period
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   iFirst           = find(years == firstYear);
   iLast            = find(years == lastYear_i - 1);
   priceReturns_i   = sum(priceReturns_overTime(:,iFirst:iLast), 2) / iLast;
   gammaEstimates_i = sum(gammaEstimates_overTime(:,iFirst:iLast), 2) / iLast;
   growthRates_i    = sum(growthRates_overTime(:,iFirst:iLast), 2) / iLast;
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Obtain regression fit and theory predictions for prices
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   [binMeanTL,binMeanReturn,binStdOfMean,trophicLevelRange,returns_predicted,regressionVals] = regressionFits_and_theoryLine(trophicLevels, priceReturns_i, gammaEstimates_i, num2str(lastYear_i));
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Obtain regression results for growth rates
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Regress growth rates on output multipliers
   mask     = ~isnan(trophicDepths) & ~isnan(growthRates_i);
   Y        = growthRates_i(mask);
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
   
   trophicDepth_fit = [min(trophicDepths) max(trophicDepths)];
   growthRates_fit  = beta(1) + beta(2)*trophicDepth_fit;
   
   regressionStatsGrowth = {['\rho = ',num2str(rho,2)], ['p = ',num2str(pval,1)]};
   
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Plot price changes
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Additional or customized appearance parameters
   xLim                     = [0.9 5];
   yLim                     = [-0.15 0.15]*100;
   
   fontSize                 = 12;
   dataMarkerSizeMain       = 7;
   markerLineWidth          = 0.5;
   markerStyle              = 'o';
   
   markerEdgeColor          = 'w';
   binAverageColor          = [127 49 0 100]/255;
   binAverageMarkerSize     = 24;
   
   marginLeft               = 0.12;
   marginTop                = 0.03;
   spacingHoriz             = 0;
   spacingVert              = 0.05;
   
   xStats = 4.1;
   yStats = 10.5;
   
   % Recall figure
   figure(pricesFigure)
   
   % Setup axes
   subaxis(3,1,iPeriod, 'SpacingHoriz',spacingHoriz, 'SpacingVert',spacingVert, 'MarginTop',marginTop, 'MarginLeft',marginLeft)
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   plot([-1 5.5],[0 0],'k-')
   hReturns    = plot(trophicLevels, priceReturns_i, markerStyle, 'MarkerSize',dataMarkerSizeMain, 'MarkerFaceColor',ap.dataColor, 'MarkerEdgeColor',markerEdgeColor, 'LineWidth',markerLineWidth);
   hBinMeans   = plot(binMeanTL, binMeanReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
   hBinErrors  = errorbar(binMeanTL, binMeanReturn, 2*binStdOfMean, 2*binStdOfMean);
   hTheory     = plot(trophicLevelRange, returns_predicted, 'k-', 'LineWidth',2);
   hold off
   set(hBinErrors, 'Color',binAverageColor, 'LineStyle','none', 'LineWidth',2)
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim)
   consistentTickPrecision(gca,'x',1)
   set(gca, 'FontSize',fontSize)
   if strcmp(robustnessMode,'timeAverage')
      xlabel('Output multiplier, time-average 1995-2009')
   else
      xlabel('Output multiplier in 1995')
   end
   
   ylabel({'Real price change',['1995-',num2str(lastYear_i),' (% yr^{-1})']})
   
   % Regression fit statistics
   text(xStats,yStats, regressionVals, 'FontSize',fontSize)
   
   % Legend
   hLegend = legend([hReturns,hBinMeans,hTheory],'price changes','bin average','theory', 'Location','NorthWest');
   set(hLegend, 'FontSize',fontSize, 'Box','off')
   
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Plot growth rates
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   xLim  = [2.15 4.5];
   yLim  = [-1 9];
   xTick = [2.5:0.5:4];
   yTick = [-0.01:0.01:0.1] * 100;
   xStats = 4.07;
   yStats = 1;
   
   % Recall figure
   figure(growthFigure)
   
   % Setup axes
   subaxis(3,1,iPeriod, 'SpacingHoriz',spacingHoriz, 'SpacingVert',spacingVert, 'MarginTop',marginTop, 'MarginLeft',marginLeft)
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   hData       = plot(trophicDepths, growthRates_i, '.', 'MarkerSize',28, 'Color',ap.moneyColor);
   hRegression = plot(trophicDepth_fit, growthRates_fit, 'k-', 'LineWidth',2);
   hold off
   
   % Plot country codes
   xscale       = 0.1;
   yscale       = 1;
   x            = trophicDepths   + 0.2*xscale;
   y            = growthRates_i + 0.2*yscale;
   text(x,y,countryCodes)
   
   % Regression fit statistics
   text(xStats,yStats, regressionStatsGrowth, 'FontSize',fontSize)
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim)
   set(gca, 'XTick',xTick)
   set(gca, 'YTick',yTick)
   consistentTickPrecision(gca,'x',1)
   set(gca, 'FontSize',fontSize)
   if strcmp(robustnessMode,'timeAverage')
      xlabel('Average output multiplier, time-average 1995-2009')
   else
      xlabel('Average output multiplier in 1995')
   end
   ylabel({'Growth rate real GDP per hour', ['1995-',num2str(lastYear_i),' (% yr^{-1})']})
   
   % Legend
   hLegend = legend([hData hRegression], 'growth rate', 'regression', 'Location','NorthWest');
   set(hLegend, 'Box','off', 'FontSize',fontSize)
end


% Save
if pp.saveFigures
   h         = figure(pricesFigure);
   folder    = pp.figuresFolder;
   fileName  = ['robustnessPrices_',robustnessMode];
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   
   %h.PaperPositionMode = 'auto';
   %D = h.PaperPosition;
   %h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [17 17];
   save_image(h, fileName, savemode)
   
   %Save manually! Don't know why this is necessary.
end


% Save
if pp.saveFigures
   h         = figure(growthFigure);
   folder    = pp.figuresFolder;
   fileName  = ['robustnessGrowth_',robustnessMode];
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   
   save_image(h, fileName, savemode)
end





end



function [binMeanTL,binMeanReturn,binStdOfMean,trophicLevelRange,returns_predicted,regressionVals] = regressionFits_and_theoryLine(trophicLevels,priceReturns,gammaVec,caseLabel)

disp('------------------------------------')
disp(caseLabel)
disp('------------------------------------')

% Bin data by trophic level, and compute statistics in each bin
binEdges      = equalCountBinning(trophicLevels, 25);
binStats      = binDataBy(priceReturns',trophicLevels,binEdges);
binMeanTL     = binStats.Xmean;
binMeanReturn = binStats.Ymean;
binStdReturn  = binStats.Ystd;
binStdOfMean  = binStdReturn ./ sqrt(binStats.count);

% Regress bin means on output multiplier
mask     = ~isnan(binMeanTL) & ~isnan(binMeanReturn);
Y        = binMeanReturn(mask);
X        = binMeanTL(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);

% Compute regression fit line
trophicLevelRange = [1 max(trophicLevels)];

% Compute direct prediction
gammaBar          = nanmean(gammaVec);
returns_predicted = -gammaBar * trophicLevelRange;

% Compute rank correlation coefficient
mask = ~isnan(trophicLevels) & ~isnan(priceReturns);
[rho_spearman,pval_spearman] = corr(trophicLevels(mask), priceReturns(mask), 'type','Spearman');
dispc( ['Spearman rank correlation = ',num2str(rho_spearman),' (p = ',num2str(pval_spearman),')'] )

% Return results
dispc('Regression fit')
dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)
dispc(' ')
dispc(gammaBar)
dispc(' ')

regressionVals = {
   ['slope = ',num2str(beta(2),3)],
   ['p = ',num2str(pval_slope,1)],
   ['R^2 = ',num2str(R2,2)]
   };

end