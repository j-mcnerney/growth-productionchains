function plotReturns_v_trophicLevels_large()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
trophicLevels = trophicStats.trophicLevels_overTime(:,1);
gammaVec      = gammaStats.gammaEstimates_timeAve;
industryCodes = WorldEconomy(1).industryCodesFull;

% Allow for a robustness check: change the end year used for the price returns
years         = [WorldEconomy.t];
years         = years(1:end-1);  %remove 1 year because (by looking at returns) you have first-differenced the data
endYear       = 2009;
iFirst        = 1;
iLast         = find(years == endYear-1);
priceReturns_overTime  = returnStats.realReturns_overTime;
priceReturns  = sum(priceReturns_overTime(:,1:iLast), 2) / iLast;

% Change units to percent per year
priceReturns = priceReturns * 100;
gammaVec     = gammaVec * 100;

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
xfit              = trophicLevelRange;
yfit              = beta(1) + beta(2)*trophicLevelRange;

% Compute direct prediction
gammaBar          = nanmean(gammaVec);
returns_predicted = -gammaBar * trophicLevelRange;

% Compute rank correlation coefficient
mask = ~isnan(trophicLevels) & ~isnan(priceReturns);
[rho_spearman,pval_spearman] = corr(trophicLevels(mask), priceReturns(mask), 'type','Spearman');
dispc(' ')
dispc( ['Spearman rank correlation = ',num2str(rho_spearman),' (p = ',num2str(pval_spearman),')'] )

% Return results
dispc('Regression fit (unweighted)')
dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)
dispc(' ')
dispc(gammaBar)


%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim                     = [0.9 5];
yLim                     = [-0.15 0.15]*100;

fontSize                 = 12;

dataMarkerSizeMain       = 7;
dataMarkerSizeSmall      = 4;
highlightMarkerSize      = 3;
variationMarkerSize      = 7;

markerLineWidth          = 0.5;
markerStyle              = 'o';
variationMarkerStyle     = '.';

markerEdgeColor          = 'w';
variationMarkerEdgeColor = ap.dataColor;
binAverageColor          = [127 49 0 100]/255;
binAverageMarkerSize     = 24;

widthHeightRatio = 0.78;
xMain            = 0.06;
yMain            = 0.23;
heightMain       = 0.7;
widthMain        = heightMain * widthHeightRatio;

shrinkageFactor  = 0.3;
xOffset          = 0.07;
heightSmall      = heightMain * shrinkageFactor;
xServices        = xMain + widthMain + xOffset;
yServices        = yMain + heightMain - heightSmall;
heightServices   = heightSmall;
widthServices    = heightSmall * widthHeightRatio;

xManu            = xMain + widthMain + xOffset;
yManu            = yServices - heightSmall - 0.01;
heightManu       = heightSmall;
widthManu        = heightSmall * widthHeightRatio;

xHighlightLabel  = 5.2;
yHighlightLabel  = 13.0;

xWithin          = xMain + widthMain + 0.12;
yWithin          = yMain;
heightWithin     = heightSmall * 1.1;
widthWithin      = heightSmall;




% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 937   531])


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Main axes
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Position',[xMain    yMain    widthMain    heightMain])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot([-1 5.5],[0 0],'k-')
hReturns    = plot(trophicLevels, priceReturns, markerStyle, 'MarkerSize',dataMarkerSizeMain, 'MarkerFaceColor',ap.dataColor, 'MarkerEdgeColor',markerEdgeColor, 'LineWidth',markerLineWidth);
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
%consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',fontSize)
xlabel('Output multiplier in 1995')
ylabel('Real price change 1995-2009 (% yr^{-1})')

% Legend
hLegend = legend([hReturns,hBinMeans,hTheory],'price changes','bin average','theory', 'Location','NorthWest');
set(hLegend, 'FontSize',fontSize, 'Box','off')


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Services highlight
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
Ihealth      = find( strcmp(industryCodes, 'Hth') );
Ieducation   = find( strcmp(industryCodes, 'Edu') );
IpublicAdmin = find( strcmp(industryCodes, 'Pub') );
Icommunity   = find( strcmp(industryCodes, 'Ocm') );
IprivHouses  = find( strcmp(industryCodes, 'Pvt') );
Igroup       = [Ihealth; Ieducation; IpublicAdmin; Icommunity; IprivHouses];

% Setup axes
axes('Position',[xServices    yServices    widthServices    heightServices])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot([-1 5.5],[0 0],'k-')
hReturns    = plot(trophicLevels, priceReturns, markerStyle, 'MarkerSize',dataMarkerSizeSmall, 'MarkerFaceColor',ap.dataColor, 'MarkerEdgeColor',markerEdgeColor, 'LineWidth',markerLineWidth);
for i = 1:length(Igroup)
   plot(trophicLevels(Igroup(i)), priceReturns(Igroup(i)), markerStyle, 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',highlightMarkerSize)
end
hold off

% Refine
set(gca, 'Box','off')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTickLabel',[])
set(gca, 'YTickLabel',[])
set(gca, 'XColor','w')
set(gca, 'FontSize',fontSize)

% Highlight label
text(xHighlightLabel,yHighlightLabel - 3.5,{'Health (Hth),','Education (Edu),','Private households (Pvt)'}, 'FontSize',fontSize)




%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Manufacturing highlight
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Identify groups of industries
Itextiles    = find( strcmp(industryCodes, 'Tex') ); %
Ichemicals   = find( strcmp(industryCodes, 'Chm') ); %
Imachinery   = find( strcmp(industryCodes, 'Mch') ); 
Ielectrical  = find( strcmp(industryCodes, 'Elc') ); %
Ifood        = find( strcmp(industryCodes, 'Fod') ); %
Ileather     = find( strcmp(industryCodes, 'Lth') );
Iwood        = find( strcmp(industryCodes, 'Wod') );
Ipulp        = find( strcmp(industryCodes, 'Pup') );
Irubber      = find( strcmp(industryCodes, 'Rub') ); %
Ibasicmetals = find( strcmp(industryCodes, 'Met') );
ItransEquip  = find( strcmp(industryCodes, 'Tpt') ); %
Igroup       = [Itextiles; Ichemicals; Ielectrical; Ifood; Irubber; ItransEquip];

% Setup axes
axes('Position',[xManu    yManu    widthManu    heightManu])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot([-1 5.5],[0 0],'k-')
hReturns = plot(trophicLevels, priceReturns, markerStyle, 'MarkerSize',dataMarkerSizeSmall, 'MarkerFaceColor',ap.dataColor, 'MarkerEdgeColor',markerEdgeColor, 'LineWidth',markerLineWidth);
for i = 1:length(Igroup)
   plot(trophicLevels(Igroup(i)), priceReturns(Igroup(i)), markerStyle, 'MarkerFaceColor','k', 'MarkerEdgeColor','k', 'MarkerSize',highlightMarkerSize)
end
hold off

% Refine
set(gca, 'Box','off')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTickLabel',[])
set(gca, 'YTickLabel',[])
set(gca, 'XColor','w')
set(gca, 'FontSize',fontSize)

% Highlight label
text(xHighlightLabel,1.16143497757847, {'Textiles (Tex),','Chemicals (Chm),','Electrical equipment (Elc),','Food (Fod),','Rubber (Rub),','Transport equipment (Tpt)'}, 'FontSize',fontSize)


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Within-industry variation
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Loop over industry types
nIndustries       = WorldEconomy.nIndustries;
industryCodes     = WorldEconomy.industryCodes;
industryCodesFull = WorldEconomy.industryCodesFull;
nTotalIndustries  = WorldEconomy.n;
trophicLevels_shiftedNormed_full = zeros(nTotalIndustries,1);
priceReturns_shiftedNormed_full  = zeros(nTotalIndustries,1);
for iIndustry = 1:nIndustries
   
   % Isolate data for this industry type
   isIndustry_i    = strmatch(industryCodes(iIndustry), industryCodesFull);
   priceReturns_i  = priceReturns(isIndustry_i,:);
   trophicLevels_i = trophicLevels(isIndustry_i,:);
   
   % Make trophic levels and price returns vectors of equal length
   nPeriodsReturns = size(priceReturns_i,2);
   nPeriodsTLs     = size(trophicLevels_i,2);
   trophicLevels_i = repmat(trophicLevels_i, [1 nPeriodsReturns/nPeriodsTLs]);
   trophicLevels_i = trophicLevels_i(:);
   priceReturns_i  = priceReturns_i(:);
   
   % Shift returns and trophic levels by their means and normalize by their
   % standard deviations
   trophicLevelsMean = nanmean(trophicLevels_i);
   priceReturnsMean  = nanmean(priceReturns_i);
   trophicLevelsStd  = nanstd(trophicLevels_i);
   priceReturnsStd   = nanstd(priceReturns_i);
   trophicLevels_shiftedNormed = (trophicLevels_i - trophicLevelsMean) / trophicLevelsStd;
   priceReturns_shiftedNormed  = (priceReturns_i  - priceReturnsMean)  / priceReturnsStd;
   
   % Store results for pooled plot
   trophicLevels_shiftedNormed_full = [trophicLevels_shiftedNormed_full; trophicLevels_shiftedNormed];
   priceReturns_shiftedNormed_full  = [priceReturns_shiftedNormed_full;  priceReturns_shiftedNormed ];
end

% Fit to line
% Note: Fit regression equation r = b_0 + b_1 * (L-1).  Shift L by 1 to
% test the signficance of the intercept at L=1, which the theory predicts
% to be zero.
mask     = ~isnan(trophicLevels_shiftedNormed_full) & ~isnan(priceReturns_shiftedNormed_full);
Y        = priceReturns_shiftedNormed_full(mask,:);
X        = trophicLevels_shiftedNormed_full(mask);

fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);
[rho, pval]    = corr(X,Y);



%========================================================================%
% Plot
%========================================================================%
% Customize appearance parameters
xLim = [-3 5.5];
yLim = [-5 5];
lineExtensionFrac = 0.02;

% Setup axes
axes('Position',[xWithin    yWithin    widthWithin    heightWithin])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Setup figure
trophicLevelRange_shiftedNormed = [(1+lineExtensionFrac)*min(trophicLevels_shiftedNormed_full) (1+lineExtensionFrac)*max(trophicLevels_shiftedNormed_full)];

% Plot
hold on
plot(trophicLevels_shiftedNormed_full, priceReturns_shiftedNormed_full, variationMarkerStyle, 'MarkerSize',variationMarkerSize, 'MarkerFaceColor',ap.dataColor, 'MarkerEdgeColor',variationMarkerEdgeColor);
plot(trophicLevelRange_shiftedNormed, beta(1) + beta(2)*(trophicLevelRange_shiftedNormed), 'k-', 'LineWidth',2)
hold off

% Correlation and p-value
[~,~,pvalueString] = coeff_and_expo(pval,'%1.0f');
annotationString = {['Pearson correlation = ',num2str(rho,2)],['   (p = ',pvalueString,')']};
xString = 5.2;
yString = 3.0;
text(xString, yString, annotationString, 'FontSize',fontSize, 'HorizontalAlignment','right')

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
%set(gca, 'YLim',yLim)
set(gca, 'XTick',[-5:1:5])
set(gca, 'YTick',[-4:2:4])
set(gca, 'FontSize',fontSize)
xlabel( {'Centered and normed', 'output multiplier'} )
ylabel( {'Centered and normed', 'price change'} )

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'Returns_v_OMs_large';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   
   %h.PaperPositionMode = 'auto';
   %D = h.PaperPosition;
   %h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [17 17];
   save_image(h, fileName, savemode)
   
   %Save manually! Don't know why this is necessary.
end