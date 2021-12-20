function plotOMchange()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Load data
%========================================================================%
announceFunction()

% Unpack data
nIndustries            = WorldEconomy.n;
countryCodes           = WorldEconomy(1).countryCodes;
industryCodes          = WorldEconomy(1).industryCodesFull;
years                  = [WorldEconomy.t];

trophicLevels_overTime = trophicStats.trophicLevels_overTime;
gammas_overTime        = gammaStats.gammaEstimates_overTime;
priceReturns_overTime  = returnStats.realReturns_overTime;

trophicDepths_overTime = trophicStats.trophicDepths_overTime;
gammaTwiddles_overTime = gammaStats.gammaTwiddles_overTime(:,1:14);
growthRates_overTime   = growthStats.countryRealLocalPerHourGrowthRates_overTime;




%========================================================================%
% Characterize rates of change of OMs, gammas
%========================================================================%
% Compute ratio of OMs in last year (2009) to first year (1995)
mask              = (trophicLevels_overTime(:,1) ~= 0) & (trophicLevels_overTime(:,end-2) ~= 0);
OMs_initial       = trophicLevels_overTime(mask,1);
OMs_final         = trophicLevels_overTime(mask,end-2);
OM_firstLastRatio = OMs_final ./ OMs_initial;

% Compute ratio of gammas values in last year (2009) to first year (1995)
mask = (gammas_overTime(:,1) ~= 0) & (gammas_overTime(:,end-2) ~= 0);
gammas_initial        = gammas_overTime(mask,1);
gammas_final          = gammas_overTime(mask,end-2);
gammas_firstLastRatio = gammas_final ./ gammas_initial;

% (1) Mean absolute rate of change over the period
Delta_t                         = (2009 - 1995);
aveRatesOfChange_OMs            = log(OM_firstLastRatio) / Delta_t;
aveRatesOfChange_gammas         = log(gammas_firstLastRatio) / Delta_t;
meanAbsROC_OMs                  = nanmean( abs(aveRatesOfChange_OMs) ) * 100;     %percent per year
meanAbsROC_gammas               = nanmean( abs(aveRatesOfChange_gammas) ) * 100;  %percent per year

% (2) Correlation between first and last values
correlation_firstAndLastOMs     = corr(OMs_final,OMs_initial, 'rows','complete');
correlation_firstAndLast_gammas = corr(gammas_final,gammas_initial, 'rows','complete');

% (3) Angular difference between first and last vectors
mask = ~isnan(OMs_final) & ~isnan(OMs_initial);
cosineDistance = pdist( [OMs_final(mask) OMs_initial(mask)]', 'cosine');
cosine = 1 - cosineDistance;
angularDifference_InDegrees_OMs = acosd(cosine);

mask = ~isnan(gammas_final) & ~isnan(gammas_initial);
cosineDistance = pdist( [gammas_final(mask) gammas_initial(mask)]', 'cosine');
cosine = 1 - cosineDistance;
angularDifference_InDegrees_gammas = acosd(cosine);

% (4) Coefficient of variation in time series
% Compute time-ave, time-std, and coeff of variation for each time series
% at the industry level
muTime_prices          = nanmean(priceReturns_overTime,2);
muTime_gammas          = nanmean(gammas_overTime,2);
muTime_OMs             = mean(trophicLevels_overTime,2);
sigmaTime_prices       = nanstd(priceReturns_overTime,0,2);
sigmaTime_gammas       = nanstd(gammas_overTime,0,2);
sigmaTime_OMs          = std(trophicLevels_overTime,0,2);
COV_prices             = sigmaTime_prices ./ muTime_prices;
COV_gammas             = sigmaTime_gammas ./ muTime_gammas;
COV_OMs                = sigmaTime_OMs    ./ muTime_OMs;

% Get typical values across industries
% NOTE: Filter out industries (especially PVT) that have no variation in
% the output multiplier to avoid having the geometric mean be zero.
COV_OMs(COV_OMs == 0)  = NaN;
COV_prices_industryAve = nangeomean(abs(COV_prices));
COV_gammas_industryAve = nangeomean(abs(COV_gammas));
COV_OMs_industryAve    = nangeomean(COV_OMs);


% (5) Coefficient of variation in time series (country level)
% Compute time-ave, time-std, and coeff of variation for each time series
% at the country level
muTime_growth          = nanmean(growthRates_overTime,2);
muTime_gammaTwiddle    = mean(gammaTwiddles_overTime,2);
muTime_AOMs            = mean(trophicDepths_overTime,2);
sigmaTime_growth       = nanstd(growthRates_overTime,0,2);
sigmaTime_gammaTwiddle = std(gammaTwiddles_overTime,0,2);
sigmaTime_AOMs         = std(trophicDepths_overTime,0,2);
COV_growth             = sigmaTime_growth       ./ muTime_growth;
COV_gammaTwiddle       = sigmaTime_gammaTwiddle ./ muTime_gammaTwiddle;
COV_AOMs               = sigmaTime_AOMs         ./ muTime_AOMs;
COV_ratio              = COV_growth ./ COV_AOMs;

% Get typical values across countries
COV_growth_countryAve       = nangeomean(abs(COV_growth));
COV_gammaTwiddle_countryAve = nangeomean(abs(COV_gammaTwiddle));
COV_AOMs_countryAve         = nangeomean(COV_AOMs);



%========================================================================%
% Print results
%========================================================================%
dispc('Statistics for rates of change of OMs & gammas:')
disp(' ')
dispc(meanAbsROC_OMs)
dispc(meanAbsROC_gammas)

disp(' ')
dispc(correlation_firstAndLastOMs)
dispc(correlation_firstAndLast_gammas)

disp(' ')
dispc(angularDifference_InDegrees_OMs)
dispc(angularDifference_InDegrees_gammas)

disp(' ')
dispc(COV_OMs_industryAve)
dispc(COV_gammas_industryAve)
dispc(COV_prices_industryAve)

% Display results
disp(' ')
dispc(COV_growth_countryAve)
dispc(COV_gammaTwiddle_countryAve)
dispc(COV_AOMs_countryAve)



%========================================================================%
% Plot 1: OMs over time
%========================================================================%
% Additional or customized appearance parameters
xLim = [1995 2009];
yLim = [1 7];

% Take a random samble of industries to plot
nSample                = 50;
Isample                = randsample(nIndustries,nSample);
trophicLevels_toPlot = trophicLevels_overTime(Isample,:);

% Setup figure
newFigure( [mfilename,'.a'])
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(years,trophicLevels_toPlot')
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',ap.fontSize)
ylabel('Output multiplier')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'OMsOverTime';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end




%========================================================================%
% Plot 2: Factor change in OMs between first and last years
%========================================================================%
% Additional or customized appearance parameters
xLim = [1995 2009];
yLim = [1 7];
barColor = [0 0.447 0.741];

% Get distribution of factor change in OMs
edges  = linspace(0,3,60);
[x,fx] = getpdf(OM_firstLastRatio,edges);

% Setup figure
newFigure( [mfilename,'.b'])
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
histogram(OM_firstLastRatio,60, 'FaceColor',barColor, 'FaceAlpha',1)
hold off

% Refine
set(gca, 'Box','on')
consistentTickPrecision(gca,'x',1)
set(gca, 'FontSize',ap.fontSize)
xlabel('Ratio of output multiplier in 2009 to output multiplier in 1995')
ylabel('Count')


% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'OMratioDistribution';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end


