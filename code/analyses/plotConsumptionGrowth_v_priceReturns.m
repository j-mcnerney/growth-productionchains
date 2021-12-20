function plotConsumptionGrowth_v_priceReturns()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
trophicLevels_overTime = trophicStats.trophicLevels_overTime;
priceReturns      = returnStats.realReturns_timeAve;
Yvec_overTime     = [WorldEconomy.Yvec];
pvec_overTime     = [WorldEconomy.pvec];
Cvec_overTime     = Yvec_overTime ./ pvec_overTime;
thetavec_overTime = Yvec_overTime * inv(diag(sum(Yvec_overTime,1)));

n          = WorldEconomy(1).n;
nYears     = length(WorldEconomy);
nCountries = WorldEconomy(1).nCountries;
thetavec_overTime_byCountry = zeros(n,nYears,nCountries);
for iYear = 1:nYears
   Yvec_byCountry     = WorldEconomy(iYear).Yvec_byCountry;
   thetaVec_byCountry = Yvec_byCountry * inv(diag(nansum(Yvec_byCountry)));
   thetavec_overTime_byCountry(:,iYear,:) = thetaVec_byCountry;
end

% Ignore industries with negative consumption levels
Cvec_overTime(Cvec_overTime < 0) = nan;
thetavec_overTime(thetavec_overTime < 0) = nan;

% Compute the rate of change of consumption for each good
Delta_t = 14;
consumption_returns      = log(Cvec_overTime(:,1+Delta_t)     ./ Cvec_overTime(:,1)) / Delta_t;
consumptionShare_returns = log(thetavec_overTime(:,1+Delta_t) ./ thetavec_overTime(:,1)) / Delta_t;

% Change units to percent per year
priceReturns             = priceReturns * 100;
consumption_returns      = consumption_returns * 100;
consumptionShare_returns = consumptionShare_returns * 100;


%========================================================================%
% Regression fits
%========================================================================%
% (1) Fit consumption growth to line
mask     = ~isnan(priceReturns) & ~isnan(consumption_returns);
Y        = consumption_returns(mask);
X        = priceReturns(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);

disp('--------------------------------')
disp('Fit to consumption growth')
dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)

% Compute regression fit line
priceReturnRange = [-20 10];
xfit = priceReturnRange;
yfit = beta(1) + beta(2)*priceReturnRange;

% Record elasticity of substitution
sigma_substitution = -beta(2);



% (2) Fit consumption-share growth to line
mask     = ~isnan(priceReturns) & ~isnan(consumptionShare_returns);
Y        = consumptionShare_returns(mask);
X        = priceReturns(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);


disp(' ')
disp('--------------------------------')
disp('Fit to consumption share growth')
dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)

% Compute regression fit line
priceReturnRange = [-20 10];
xfit_share = priceReturnRange;
yfit_share = beta(1) + beta(2)*priceReturnRange;



% (3) Fit consumption growth v. consumption-share growth to line
mask     = ~isnan(consumptionShare_returns) & ~isnan(consumption_returns);
Y        = consumption_returns(mask);
X        = consumptionShare_returns(mask);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
pval_intercept = pvals(1);
pval_slope     = pvals(2);

disp(' ')
disp('--------------------------------')
disp('Fit consumption growth v. consumption-share growth')
dispc(beta)
dispc(R2)
dispc(CIs)
dispc(pval_intercept)
dispc(pval_slope)

% Compute regression fit line
consumptionShareReturnRange = [-40 30];
xfit_cVtheta = consumptionShareReturnRange;
yfit_cVtheta = beta(1) + beta(2)*consumptionShareReturnRange;


%========================================================================%
% Estimate drag effect of the dispersion term
%========================================================================%
priceReturns           = priceReturns / 100; %temporarily convert back to units of yr^(-1)

meanSquaredReturn      = nansum(thetavec_overTime(:,1) .* priceReturns.^2);
meanReturnSquared      = (nansum(thetavec_overTime(:,1) .* priceReturns))^2;
sharesWeightedVariance = meanSquaredReturn - meanReturnSquared;
sharesWeightedStd      = sqrt(sharesWeightedVariance);

sharesWeightedStd      = sharesWeightedStd * 100;
%sharesWeightedVariance = sharesWeightedVariance * 100;
priceReturns           = priceReturns * 100; %restore units of %/yr

dragTermSize = (1 - sigma_substitution) * sharesWeightedVariance;

disp(' ')
disp('--------------------------------')
disp('Estimate second-order drag effect on growth')
dispc(sigma_substitution)
disp( ['sharesWeightedStd: ',num2str(sharesWeightedStd),' %/yr'] )
disp( ['sharesWeightedStd: ',num2str(sharesWeightedStd / 100),' yr^(-1)'] )
disp( ['sharesWeightedVariance: ',num2str(sharesWeightedVariance), ' yr^(-2)'] )
disp( ['dragTermSize: ',num2str(dragTermSize), ' yr^(-2)'] )
disp( ['10-year log growth rate reduction: ',num2str(10 * dragTermSize), ' yr^(-1)'] )
disp( ['10-year log growth rate reduction: ',num2str(10 * dragTermSize * 100), '%/yr^(-1)'] )


%========================================================================%
% Plot consumption returns vs. price changes
%========================================================================%
% Additional or customized appearance parameters
xLim = [-20 10];
yLim = [-40 40];

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
plot([xLim(1) xLim(2)], [0 0],'k-')
plot([0 0], [yLim(1) yLim(2)],'k-')
plot(priceReturns, consumption_returns, '.',  'Color',ap.moneyColor, 'MarkerSize',ap.markerSize);
plot(xfit, yfit, 'k-', 'LineWidth',2)
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'FontSize',ap.fontSize)
xlabel('Real price change 1995-2009 (% yr^{-1})')
ylabel('Growth in consumption 1995-2009 (% yr^{-1})')


% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'ConsumptionReturns_v_priceReturns';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end