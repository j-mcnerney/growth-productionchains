% This is the main code file for the paper "How production networks amplify
% economic growth".

% Save command window output to output file
outputFile = fullfile('./output/Output.txt');
delete( outputFile )
diary(  outputFile )
disp('=====================================================================')
disp('RUNNING MAIN.M...')
disp('=====================================================================')

% Add paths to data and libraries
addpath('./analyses')
addpath('./analyses/precompute')
addpath('./save')
addpath('./tools')
addpath('./tools/BEAanalysis')
addpath('./lib')
addpath('./lib/SubAxis')
addpath('./wrangle/wrangleWIOD')

% Wrangle raw data
wrangle = true;
if wrangle
   wrangle_WIOD()
end

% Load saved data
firstTime = true;
if firstTime
   clear
   disp('Loading data...')
   WorldEconomyBase = loadWIOD();               % WIOD
   load('WIOD_SEA.mat','WIOD_SEA');             % WIOD socioeconomic accounts
   load('WDIselectedData','WDIselectedData');   % select World Development Indicators
   load('PWTselectedData','PWTselectedData');   % select Penn World Table Indicators
   global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp
end

% Set processing and appearance parameters
pp.householdIncomeType      = 'laborIncome';      %employeeCompensation laborIncome valueAdded
pp.HHIncomeFracAssumed      = 0.5;              %false 0.5  (0.5 is close to the average labor share of 0.57 computed from the data)
pp.elimNanPriceReturns      = false;              %try Charles' elimination of NaN price returns, line 492 in his script
pp.finalDemandShares        = 'worldFinalDemand'; %worldFinalDemand countryGDPshares
pp.growthConcept            = 'perHour';          %perHour perWorker perCapita
pp.timeAveraging_AVPGrowth  = 'periodAverage';    %periodAverage firstYear
pp.timeAveraging_regression = 'periodAverage';    %periodAverage firstYear
pp.turnOffTrade             = false;
pp.figuresFolder            = './output';
pp.saveFigures              = false;
ap                          = getAppearanceParams();

% Compute key values: output multipliers, price returns, productivity
% improvement rates, growth rates, etc.
computeStats = true;
if computeStats
   WorldEconomy = turnOffTrade(WorldEconomyBase,pp);
   WorldEconomy = computeInputCoefficients(WorldEconomy,pp);
   WorldEconomy = computeTrophicValues(WorldEconomy,pp);
   WorldEconomy = computeHouseholdWageRates(WorldEconomy);
   trophicStats = computeTrophicStatistics(WorldEconomy);
   returnStats  = computeReturnStatistics(WorldEconomy,pp);
   gammaStats   = computeGammaStatistics(WorldEconomy,returnStats);
   growthStats  = computeGrowthStatistics(WorldEconomy,WIOD_SEA,WDIselectedData,PWTselectedData,pp);
   H_overTime   = computeLeontiefInverse(WorldEconomy);
end

% Basic statistics
if true; reportWIODstats(); end
if true; makeIndustryTable(); end
if true; makeCountryTable(WDIselectedData); end

% Output multipliers in China and US
if true; plotTrophicStructure();   end

% Direct and inherited contributions
if true; plotDistributionReturnContributions();   end

% Price changes and output multipliers
if true; plotReturns_v_trophicLevels_large();   end
if true; gammaShuffleTest();   end

% Cross-industry st. dev. price change v trophic levels
if true; plotCombinedReturnPrediction_byTimeHorizon4();   end

% Average output multiplier and productivity growth rates over time
if true; plotGammaTwiddleOverTime();   end
if true; plotTrophicDepthOverTime();   end

% Growth rates v trophic depths
if true; plotGrowth_v_trophicDepth();   end
if true; plotGrowthForecastComparison2(); end
if true; plotGrowthPrediction_byTimeHorizon2(); end

% Persistence of industry output multipliers
if true; plotOMchange(); end
if true; compareAchange_and_OMchange(); end

% Within-industry regressions
if true; plotReturns_v_trophicLevels_byIndustryType(); end
if true; regressIndustryDummies_and_OMs(); end

% Consumption growth and price change
if true; plotConsumptionGrowth_v_priceReturns(); end

% Robustness checks
if true; robustnessChecks(); end

% Aggregation of industry ouput multipliers in US BEA data
if true; plotTrophicBranching(); end


% Close output of command window to file
diary off
disp([newline;newline;newline])