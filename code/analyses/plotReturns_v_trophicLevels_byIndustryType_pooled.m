function plotReturns_v_trophicLevels_byIndustryType_pooled()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp
% plots returns versus trophic levels for individual industries, pooling
% the industries into one plot after shift and scaling them by average
% values across countries.

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

% Print results
disp(' ')
dispc( beta )
dispc( pval_slope )



%========================================================================%
% Plot
%========================================================================%
% Customize appearance parameters
xLim = [-3 5.5];
yLim = [-5 5];
lineExtensionFrac = 0.02;

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Setup figure
trophicLevelRange_shiftedNormed = [(1+lineExtensionFrac)*min(trophicLevels_shiftedNormed_full) (1+lineExtensionFrac)*max(trophicLevels_shiftedNormed_full)];

% Plot
hold on
plot(trophicLevels_shiftedNormed_full, priceReturns_shiftedNormed_full, '.',  'Color',ap.dataColor, 'MarkerSize',ap.markerSize);
plot(trophicLevelRange_shiftedNormed, beta(1) + beta(2)*(trophicLevelRange_shiftedNormed), 'k-', 'LineWidth',2)
hold off

% Correlation and p-value
[~,~,pvalueString] = coeff_and_expo(pval,'%1.0f');
annotationString = ['Pearson correlation = ',num2str(rho,2),'   (p = ',pvalueString,')'];
xString = 5.2;
yString = 4.4;
text(xString, yString, annotationString, 'FontSize',ap.fontSize, 'HorizontalAlignment','right')

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
%set(gca, 'YLim',yLim)
set(gca, 'XTick',[-5:1:5])
set(gca, 'YTick',[-5:1:5])
%consistentTickPrecision(gca,'x',1)
%consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',ap.fontSize)
xlabel('Centered and normed output multiplier')
ylabel('Centered and normed price change')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'Returns_v_OM_byIndustryPooled.eps';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
