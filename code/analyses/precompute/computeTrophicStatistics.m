function trophicStats = computeTrophicStatistics(WorldEconomy)
% Computes a variety of averages of the trophic quantities over time, over
% countries, over industries.

disp('Computing trophic statistics...')

nYears      = length(WorldEconomy);
nIndustries = WorldEconomy(1).nIndustries;

% Compute country labor shares of gross output
countryLabSharesGrossOutput_overTime = [WorldEconomy.countryLaborSharesOfGO];
countryLabSharesGrossOutput_timeAve  = mean(countryLabSharesGrossOutput_overTime, 2);

% Compute trophic levels over time and time-average
trophicLevels_overTime = [WorldEconomy.trophicLevels];
trophicLevels_timeAve  = mean(trophicLevels_overTime,2);

% Compute cross-country averages and standard deviations
trophicLevels_overTime_countryAve = zeros(nIndustries,nYears);
trophicLevels_timeAve_countryAve  = zeros(nIndustries,1);
trophicLevels_timeAve_countrySTD  = zeros(nIndustries,1);

industryNames     = WorldEconomy(1).industryNames;
industryNamesFull = WorldEconomy(1).industryNamesFull;
for i = 1:nIndustries
   % Make a mask to find a given industry in all countries
   isIndustry_i = strcmp( industryNames(i), industryNamesFull );
   TLisNan      = isnan( trophicLevels_timeAve );
   mask         = isIndustry_i & ~TLisNan;
  
   trophicLevels_overTime_countryAve(i,:) = mean( trophicLevels_overTime(mask,:), 1);
   trophicLevels_timeAve_countryAve(i)    = mean( trophicLevels_timeAve(mask)      );
   trophicLevels_timeAve_countrySTD(i)    = std(  trophicLevels_timeAve(mask)      );
end

% Compute trophic depths over time and time-average
trophicDepths_overTime     = [WorldEconomy.countryTrophicDepths];
trophicDepths_timeAve      = mean(trophicDepths_overTime(:,1:end-2), 2);      % remove 2010 and 2011 for average
worldTrophicDepth_overTime = [WorldEconomy.worldTrophicDepth];
worldTrophicDepth_timeAve  = mean(worldTrophicDepth_overTime(1:end-2), 2);  % remove 2010 and 2011 for average

% Store quantities
trophicStats.countryLabSharesGrossOutput_overTime = countryLabSharesGrossOutput_overTime;
trophicStats.countryLabSharesGrossOutput_timeAve  = countryLabSharesGrossOutput_timeAve;
trophicStats.trophicLevels_overTime            = trophicLevels_overTime;
trophicStats.trophicLevels_timeAve             = trophicLevels_timeAve;
trophicStats.trophicLevels_overTime_countryAve = trophicLevels_overTime_countryAve;
trophicStats.trophicLevels_timeAve_countryAve  = trophicLevels_timeAve_countryAve;
trophicStats.trophicLevels_timeAve_countrySTD  = trophicLevels_timeAve_countrySTD;
trophicStats.trophicDepths_overTime            = trophicDepths_overTime;
trophicStats.trophicDepths_timeAve             = trophicDepths_timeAve;
trophicStats.worldTrophicDepth_overTime        = worldTrophicDepth_overTime;
trophicStats.worldTrophicDepth_timeAve         = worldTrophicDepth_timeAve;
