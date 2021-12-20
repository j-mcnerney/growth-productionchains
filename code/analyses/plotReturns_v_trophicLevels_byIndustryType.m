function IndustryResultsTable = plotReturns_v_trophicLevels_byIndustryType()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp


%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack and choose data
dataSelection = 'first_v_ave';
switch dataSelection
   case 'first_v_ave'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      priceReturns  = returnStats.realReturns_timeAve;
   case 'first_v_yearly'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      priceReturns  = returnStats.realReturns_overTime;
   case 'yearly_v_yearly'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1:end-1);   % lop-off last year since there are always 1 fewer return measurements than trophic level measurements
      priceReturns  = returnStats.realReturns_overTime;
   case 'ave_v_ave'
      trophicLevels = trophicStats.trophicLevels_timeAve;
      priceReturns  = returnStats.realReturns_timeAve;
   case 'ave_v_yearly'
      trophicLevels = trophicStats.trophicLevels_timeAve;
      priceReturns  = returnStats.realReturns_overTime;
   otherwise
      error('plotReturns_v_trophicLevels_byIndustryType2: unrecognized option.')
end

% Change units to percent per year
priceReturns = priceReturns * 100;




%========================================================================%
% Plot
%========================================================================%
% Customize appearance parameters
ap.xLim = [0.9 4.8];
ap.yLim = [-0.17 0.14]*100;

% Appearance parameters
spacing   = 0;
marginTop = 0.01;
marginBot = 0.09;
lineExtensionFrac = 0.02;

xIndustryLabel = 1.1;
yIndustryLabel = 8;
xpvalueLabel   = 4.6;
ypvalueLabel   = yIndustryLabel;
xpstarsLabel   = 4.6;
ypstarsLabel   = yIndustryLabel - 4;

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 758   646])
%set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Loop over industry types
nIndustries       = WorldEconomy.nIndustries;
industryNames     = WorldEconomy.industryNames;
industryCodes     = WorldEconomy.industryCodes;
industryCodesFull = WorldEconomy.industryCodesFull;
IndustryResultsTable = cell(nIndustries,5);
industrySlopes    = zeros(nIndustries,1);
industryPvals     = zeros(nIndustries,1);
for iIndustry = 1:nIndustries
   % Isolate data for this industry type
   isIndustry_i    = strmatch(industryCodes(iIndustry), industryCodesFull);
   priceReturns_i  = priceReturns(isIndustry_i,:);
   trophicLevels_i = trophicLevels(isIndustry_i,:);
   
   % Make trophic levels and price returns vectors of equal length
   nPeriodsReturns = size(priceReturns_i,2);
   nPeriodsTLs     = size(trophicLevels_i,2);
   trophicLevels_i   = repmat(trophicLevels_i, [1 nPeriodsReturns/nPeriodsTLs]);
   trophicLevels_i   = trophicLevels_i(:);
   priceReturns_i    = priceReturns_i(:);

   % Fit to line
   % Note: Fit regression equation r = b_0 + b_1 * (L-1).  Shift L by 1 to
   % test the signficance of the intercept at L=1, which the theory predicts
   % to be zero.
   mask     = ~isnan(trophicLevels_i) & ~isnan(priceReturns_i);
   Y        = priceReturns_i(mask,:);
   X        = trophicLevels_i(mask);
   fitStats = regstats(Y, X, 'linear');
   beta     = fitStats.beta;
   R2       = fitStats.rsquare;
   stdErr   = fitStats.tstat.se;
   tvals    = fitStats.tstat.t;
   pvals    = fitStats.tstat.pval;
   CIs      = [beta-2*stdErr beta+2*stdErr];
   pval_intercept = pvals(1);
   pval_slope     = pvals(2);
   CI_slope       = CIs(2,:);
   
   % Setup axes
   subaxis(7,5,iIndustry, 'Spacing',spacing, 'MarginTop',marginTop, 'MarginBot',marginBot)
   
   % Plot
   trophicLevelRange = [(1-lineExtensionFrac)*min(trophicLevels_i) (1+lineExtensionFrac)*max(trophicLevels_i)];
   hold on
   plot([-1 5.5],[0 0],'k-')
   plot(trophicLevels_i, priceReturns_i, '.',  'Color',ap.dataColor, 'MarkerSize',10);
   plot(trophicLevelRange, beta(1) + beta(2)*(trophicLevelRange), 'k-', 'LineWidth',2);
   hold off
   
   % Refine
   set(gca, 'Box','on')
   %set(gca, 'XScale','log')
   %set(gca, 'YScale','log')
   set(gca, 'XLim',ap.xLim)
   set(gca, 'YLim',ap.yLim)
   %set(gca, 'DataAspectRatio', [1 1 1])
   set(gca, 'XTick',[1:5])
   set(gca, 'YTick',[-0.15:0.05:0.15] * 100)
   consistentTickPrecision(gca,'x',1)
   consistentTickPrecision(gca,'y',1)
   set(gca, 'FontSize',ap.fontSize)
   
   % x-axis tick labels on bottom panels only
   set(gca, 'XTickLabels',[])
   bottomEdge = any(iIndustry == [31 32 33 34 35]);
   if bottomEdge
      set(gca, 'XTickLabel',[1:5])
   end
   
   % y-axis tick on left panels only
   set(gca, 'YTickLabels',[])
   leftEdge = any(iIndustry == [6 11 16 21 26 31]);
   if leftEdge
      set(gca, 'YTickLabel',[-0.15:0.05:0.10]*100)
   end
   if iIndustry == 1
      set(gca, 'YTickLabel',[-0.15:0.05:0.15]*100)
   end
      
   % x- and y-axis labels
   plotXaxisLabel = (iIndustry == 33);
   if plotXaxisLabel
      xlabel('Output multiplier in 1995')
   end
   plotYaxisLabel = (iIndustry == 16);
   if plotYaxisLabel
      ylabel({'Yearly real price return (% yr^{-1})'})
   end
   
   % Industry-type label
   industryLabel = text(xIndustryLabel,yIndustryLabel, industryCodes(iIndustry));
   set(industryLabel, 'HorizontalAlignment','left', 'VerticalAlignment','bottom', 'FontWeight','normal')
   
   % p-value label
   if pval_slope < 0.01
      [~,~,pvalueString] = coeff_and_expo(pval_slope);
   else
      pvalueString = num2str(pval_slope,'%3.2f');
   end
   pvalueString       = ['p = ',pvalueString];
   pvalueLabel        = text(xpvalueLabel,ypvalueLabel, pvalueString);
   set(pvalueLabel, 'HorizontalAlignment','right', 'VerticalAlignment','bottom', 'FontWeight','normal')
   
   % p-value stars
   pVal_1star = 0.05;
   pVal_2star = 0.01;
   pVal_3star = 0.001;
   significanceLevels = [pVal_1star, pVal_2star, pVal_3star];
   [~,nStarsString]   = significanceLevel(pval_slope, significanceLevels);
   pstarsLabel        = text(xpstarsLabel,ypstarsLabel, nStarsString);
   set(pstarsLabel, 'HorizontalAlignment','right', 'VerticalAlignment','bottom', 'FontWeight','bold')
   
   % Store results for a latex table
   IndustryResultsTable{iIndustry,1} = industryCodes{iIndustry};
   IndustryResultsTable{iIndustry,2} = industryNames{iIndustry};
   IndustryResultsTable{iIndustry,3} = num2str(beta(2), '%3.2f');
   IndustryResultsTable{iIndustry,4} = ['[',num2str(CI_slope(1), '%3.2f'),', ',num2str(CI_slope(2), '%3.2f'),']'];
   IndustryResultsTable{iIndustry,5} = pvalueString(5:end);
   IndustryResultsTable{iIndustry,6} = nStarsString{1};
   
   % Store results for side plots
   industrySlopes(iIndustry)   = beta(2);
   industryPvals(iIndustry)    = pval_slope;
end

% Save
saveImage = false;
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'NewFigure.eps';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end

% Print statistics
numNegative    = nnz(industrySlopes < 0);
numSignificant = nnz(industryPvals  < 0.05);
dispc( ['Coefficients negative for ',num2str(numNegative),' of ',num2str(nIndustries),' industries.'] )
dispc( ['Coefficients significant for ',num2str(numSignificant),' of ',num2str(nIndustries),' industries.'] )

% Print industry results table
headerRow = {'Industry code','Industry name','Slope','Confidence interval','$p$-value',''};
disp(' ')

IndustryResultsTable
printLatexTable(IndustryResultsTable,headerRow)