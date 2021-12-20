function gammaShuffleTest()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

announceFunction()

% Do analysis twice, once without and once with shuffling
doShuffle = false;
dispc( ['Gammas shuffled: ',string(doShuffle){1}] )
gammaShuffleTest_sub( [mfilename,'.a'],WorldEconomy,gammaStats,returnStats,trophicStats,H_overTime,ap,pp,doShuffle)

doShuffle = true;
dispc( ['Gammas shuffled: ',string(doShuffle){1}] )
gammaShuffleTest_sub( [mfilename,'.b'],WorldEconomy,gammaStats,returnStats,trophicStats,H_overTime,ap,pp,doShuffle)

end


function gammaShuffleTest_sub(figureNum,WorldEconomy,gammaStats,returnStats,trophicStats,H_overTime,ap,pp,doShuffle)
%========================================================================%
% Preprocessing
%========================================================================%
% Unpack data
n = WorldEconomy(1).n;
trophicLevels = trophicStats.trophicLevels_overTime(:,1);
realReturns   = returnStats.realReturns_timeAve;

% Change units to percent per year
realReturns = realReturns * 100;

% Grab gammas, returns, and IO table for some year
iYear         = 1;
A             = WorldEconomy(iYear).A;
I             = eye(n);

% Remove industries whose price returns are NaNs
hasReturn       = ~isnan(realReturns);
hasExpenditures = (WorldEconomy(iYear).Mout' > 0);  % Note: Mout is slighly different from totalExpendvec. The former is computed in computeInputCoefficients.
mask            = hasReturn & hasExpenditures;
rvec_mod        = realReturns(mask);
A_mod           = A(mask,mask);
I_mod           = I(mask,mask);
H_mod           = inv(I_mod - A_mod');
gammaVec_mod    = -(I_mod - A_mod') * rvec_mod;
trophicLevels_mod = trophicLevels(mask);

% Shuffle the gammas
if doShuffle
   n_mod        = length(gammaVec_mod);
   Ishuffle     = randperm(n_mod);
   gammaVec_mod = gammaVec_mod(Ishuffle);
end
gammaVec       = nan(n,1);       %restore removed industries,
gammaVec(mask) = gammaVec_mod;   %setting their improvement rates to NaN

% Compute the returns from the gammas
rvec_fromGammas_mod   = -H_mod * gammaVec_mod;
rvec_fromGammas       = nan(n,1);               %restore removed industries,
rvec_fromGammas(mask) = rvec_fromGammas_mod;    %setting their price returns to NaN

% Fit to line
mask     = ~isnan(trophicLevels) & ~isnan(rvec_fromGammas);
Y        = rvec_fromGammas(mask);
X        = trophicLevels(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);

% Compute fit
xFit = [1 max(trophicLevels)];
yFit = beta(1) + beta(2)*(xFit);

dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)

mask = ~isnan(trophicLevels) & ~isnan(rvec_fromGammas) & ~isnan(gammaVec);
[rho1, p1] = corr(trophicLevels(mask), rvec_fromGammas(mask));
[rho2, p2] = corr(trophicLevels(mask), gammaVec(mask));
[rho3, p3] = corr(gammaVec(mask),      rvec_fromGammas(mask));
disp( ['Correlation(L,r) = ',num2str(rho1), '   (p = ',num2str(p1),')'] )
disp( ['Correlation(L,g) = ',num2str(rho2), '   (p = ',num2str(p2),')'] )
disp( ['Correlation(g,r) = ',num2str(rho3), '   (p = ',num2str(p3),')'] )

% Bin data by trophic level, and compute statistics in each bin
%binEdges      = [1:0.1:5];
binEdges      = equalCountBinning(trophicLevels, 25);
binStats      = binDataBy(rvec_fromGammas,trophicLevels,binEdges);
binMeanTL     = binStats.Xmean;
binMeanReturn = binStats.Ymean;
binStdReturn  = binStats.Ystd;
binStdOfMean  = binStdReturn ./ sqrt(binStats.count);

% Compute error bars around standard deviation estimates
% Note: The standard error of standard deviation is
%   SE(sigma) = sigma / sqrt(2N-2)
% Source: https://pdfs.semanticscholar.org/ba2b/131bc7b442c3f7f4641339f3549f69b15a9b.pdf
binErrorIn_StdReturn = binStdReturn ./ sqrt(2*binStats.count - 2);
binErrorIn_StdReturn(binStats.count <= 1) = nan;



%========================================================================%
% Price changes versus output multipliers
%========================================================================%
% Additional or customized appearance parameters
xLim  = [0.9 5];
yLim  = [-0.15 0.15]*100;
yTick = [-0.15 : 0.05 : 0.1] * 100;
binAverageColor   = [127 49 0 100]/255;
binAverageMarkerSize = 20;
gammaMarkerSize = 6;
lineColor            = 0.2 * [1 1 1];
trophicLevelRange    = [1 max(trophicLevels)];

% Setup figure
newFigure(figureNum)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 543   420])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot([-1 5.5],[0 0],'k-')
plot(trophicLevels, rvec_fromGammas, '.', 'Color',ap.dataColor, 'MarkerSize',10);
plot(xFit, yFit, 'k-', 'LineWidth',2);
hBinMeans = plot(binMeanTL, binMeanReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'YTick',yTick)
set(gca, 'FontSize',ap.fontSize)
xlabel('Output multiplier')
ylabel('Real price return (% yr^{-1})')

% Show correlation on plot
[~,~,pvalueString] = coeff_and_expo(p1,'%1.0f');
annotationString = ['Pearson correlation = ',num2str(rho1,2),'   (p = ',pvalueString,')'];
xString = 4.9;
yString = 13.5;
text(xString, yString, annotationString, 'FontSize',ap.fontSize, 'HorizontalAlignment','right')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   if doShuffle
      fileName = 'Returns_v_OMs_shuffle';
   else
      fileName = 'Returns_v_OMs_noshuffle';
   end
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end


%========================================================================%
% Productivity growth rates versus output multipliers
%========================================================================%
% Fit to line
mask     = ~isnan(trophicLevels) & ~isnan(gammaVec);
Y        = gammaVec(mask);
X        = trophicLevels(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;

% Setup figure
newFigure( [figureNum,'.1'])
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 543   420])
%set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Plot
hold on
plot([1 5], [0 0],'k-')
plot(trophicLevels, gammaVec, 'o', 'MarkerSize',gammaMarkerSize)
plot(xFit, (beta(1) + beta(2)*xFit), 'k-', 'LineWidth',2);
hold off

% Refine figure
set(gca, 'Box','on')
set(gca, 'XLim',[0.9 5])
set(gca, 'FontSize',ap.fontSize)
xlabel('Output multiplier')
ylabel('Improvement rate (% yr^{-1})')

% Show correlation on plot
if doShuffle
   pvalueString = num2str(p2,'%3.2f');
else
   [~,~,pvalueString] = coeff_and_expo(p2,'%1.0f');
end
annotationString = ['Pearson correlation = ',num2str(rho2,2),'   (p = ',pvalueString,')'];
xString = 4.9;
yString = 18;
text(xString, yString, annotationString, 'FontSize',ap.fontSize, 'HorizontalAlignment','right')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   if doShuffle
      fileName = 'gammas_v_L_shuffle';
   else
      fileName = 'gammas_v_L_noshuffle';
   end
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end

end
