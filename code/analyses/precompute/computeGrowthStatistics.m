function growthStats = computeGrowthStatistics(WorldEconomy,WIOD_SEA,WDIselectedData,PWTselectedData,pp)
% Computes various statistics of country growth rates over time.

disp('Computing growth statistics...')

% Compute GDP using WIOD data
nYears  = length(WorldEconomy);

% Extract hours worked from WIOD_SEA
isTotalIndustries = strcmp(WIOD_SEA.industry, 'total industries');
isHoursWorked2    = strcmp(WIOD_SEA.variable, 'H_EMPE'); % hours worked by employees (millions)
isHoursWorked3    = strcmp(WIOD_SEA.variable, 'H_EMP');  % hours worked by persons engaged (millions)

mask2 = isTotalIndustries & isHoursWorked2;
mask3 = isTotalIndustries & isHoursWorked3;
hoursWorkedEmployees_overTime = WIOD_SEA.dataTable(mask2, :); % Total hours worked by employees (millions)
hoursWorkedLabor_overTime     = WIOD_SEA.dataTable(mask3, :); % Total hours worked by persons engaged (millions)
hoursWorkedEmployees_overTime = [hoursWorkedEmployees_overTime; nan(2,nYears)];   % add 2 NaN rows for ROW, world
hoursWorkedLabor_overTime     = [hoursWorkedLabor_overTime; nan(2,nYears)];   % add 2 NaN rows for ROW, world
%check: see that countries hours worked are in correct order
%[WIOD_SEA.country(mask1) WIOD_SEA.country(mask2) WorldEconomy(1).countryCodes(1:40)]

% Direct WDI for comparison
GDPperCapita_2011PPP  = WDIselectedData.GDPperCapita_2011PPP;

% Population, work force size, and hours worked
population_overTime   = WDIselectedData.Population;   % persons
laborForce_overTime   = WDIselectedData.LaborForce;   % persons
switch pp.householdIncomeType
   case 'employeeCompensation'
      hoursWorked_overTime  = hoursWorkedEmployees_overTime * 1e6;  % hours
   case 'laborIncome'
      hoursWorked_overTime  = hoursWorkedLabor_overTime * 1e6;  % hours
   case 'valueAdded'
      hoursWorked_overTime  = hoursWorkedLabor_overTime * 1e6;  % hours
end

% Taiwan is missing from the World Development Indicators.  Use the Penn
% World Tables to supply population and numer employed for Taiwan.
isTaiwan = find(strcmp('TWN',PWTselectedData.countryCodes));
population_overTime(isTaiwan,:)   = PWTselectedData.Population(isTaiwan,:) * 1e6;     % people
laborForce_overTime(isTaiwan,:)   = PWTselectedData.NumberEmployed(isTaiwan,:) * 1e6; % people

% GDP deflator, PPP conversion factor, market exchange rates
% WDI: "The GDP implicit deflator is the ratio of GDP in current local
% currency to GDP in constant local currency. The base year varies by
% country."
GDPdeflator_overTime   = WDIselectedData.GDPdeflator;   % current year LC / "unit" of GDP
%PPPfactor_overTime     = WDIselectedData.PPP;           % current year LC / current year I$
%exchangeRates_overTime = [];                            % 

% Nominal local GDP
% Currency units:  LC = local currency, I$ = international $, US$ = US dollars
nominalLocalGDP_overTime = WDIselectedData.NominalLocalGDP;  % current year LC

% Real local GDP
baseYear         = 2009;
isBaseYear       = (WDIselectedData.years == baseYear);
P_baseYear       = GDPdeflator_overTime(:,isBaseYear);
deflationFactors = repmat(P_baseYear, [1 nYears]) ./ GDPdeflator_overTime;
realLocalGDP_overTime = nominalLocalGDP_overTime .* deflationFactors; % base year LC

% Taiwan is missing from the World Development Indicators.  Use the Penn
% World Tables to supply real GDP.  Unlike the other data, the Taiwan data
% here is converted to USD rather than being expressed in local currency.
realLocalGDP_overTime(isTaiwan,:) = PWTselectedData.RealGDP_NationPricesinUSD(isTaiwan,:);        % millions of 2005USD


% Real local GDP per (capita, worker, hour)
realLocalGDPperCapita_overTime = realLocalGDP_overTime ./ population_overTime;   % base year LC / person
realLocalGDPperWorker_overTime = realLocalGDP_overTime ./ laborForce_overTime;   % base year LC / person
realLocalGDPperHour_overTime   = realLocalGDP_overTime ./ hoursWorked_overTime;  % base year LC / hour

% Real local per (capita, worker, hour) annual growth rates
realLocalPerCapitaGrowthRates_overTime = diff( log(realLocalGDPperCapita_overTime), 1, 2);  %log return
realLocalPerWorkerGrowthRates_overTime = diff( log(realLocalGDPperWorker_overTime), 1, 2);  %log return
realLocalPerHourGrowthRates_overTime   = diff( log(realLocalGDPperHour_overTime), 1, 2);    %log return

% Time-averaged growth rates over whole period
realLocalPerCapitaGrowthRates_timeAve = sum(realLocalPerCapitaGrowthRates_overTime(:,1:end-2), 2) / 14;  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)
realLocalPerWorkerGrowthRates_timeAve = sum(realLocalPerWorkerGrowthRates_overTime(:,1:end-2), 2) / 14;  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)
realLocalPerHourGrowthRates_timeAve   = sum(realLocalPerHourGrowthRates_overTime(:,1:end-2), 2) / 14;  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)

% Time standard deviations of growth rates over whole period
realLocalPerCapitaGrowthRates_timeSTD = std(realLocalPerCapitaGrowthRates_overTime(:,1:end-2), 0,2);  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)
realLocalPerWorkerGrowthRates_timeSTD = std(realLocalPerWorkerGrowthRates_overTime(:,1:end-2), 0,2);  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)
realLocalPerHourGrowthRates_timeSTD   = std(realLocalPerHourGrowthRates_overTime(:,1:end-2), 0,2);  % Average growth over the period 1995-2009 (last 2 years have NaN price indices)

% Obtain world per-capita growth rates directly from WDI data
worldPerCapitaGrowthRate_overTime = WDIselectedData.GDPperCapitaGrowthRate(end,:) / 100;
worldPerCapitaGrowthRate_timeAve  = mean( worldPerCapitaGrowthRate_overTime(1:end-2) );   % Average growth over the period 1995-2009


% Store quantities
growthStats.countryPopulation_overTime      = population_overTime(1:41,:);
growthStats.countryLaborForce_overTime      = laborForce_overTime(1:41,:);
growthStats.countryHoursWorked_overTime     = hoursWorked_overTime(1:41,:);

growthStats.countryGDPDeflator_overTime     = GDPdeflator_overTime(1:41,:);
growthStats.countryNominalLocalGDP_overTime = nominalLocalGDP_overTime(1:41,:);
growthStats.countryRealLocalGDP_overTime    = realLocalGDP_overTime(1:41,:);

growthStats.countryRealLocalGDPperCapita_overTime    = realLocalGDPperCapita_overTime(1:41,:);
growthStats.countryRealLocalGDPperWorker_overTime    = realLocalGDPperWorker_overTime(1:41,:);
growthStats.countryRealLocalGDPperHour_overTime      = realLocalGDPperHour_overTime(1:41,:);

growthStats.countryRealIntDolGDPperCapita_timeAve    = GDPperCapita_2011PPP(1:41,end-2);

growthStats.countryRealLocalPerCapitaGrowthRates_overTime = realLocalPerCapitaGrowthRates_overTime(1:41,:);
growthStats.countryRealLocalPerWorkerGrowthRates_overTime = realLocalPerWorkerGrowthRates_overTime(1:41,:);
growthStats.countryRealLocalPerHourGrowthRates_overTime   = realLocalPerHourGrowthRates_overTime(1:41,:);
growthStats.countryRealLocalPerCapitaGrowthRates_timeAve  = realLocalPerCapitaGrowthRates_timeAve(1:41,:);
growthStats.countryRealLocalPerWorkerGrowthRates_timeAve  = realLocalPerWorkerGrowthRates_timeAve(1:41,:);
growthStats.countryRealLocalPerHourGrowthRates_timeAve    = realLocalPerHourGrowthRates_timeAve(1:41,:);

growthStats.realLocalPerCapitaGrowthRates_timeSTD  = realLocalPerCapitaGrowthRates_timeSTD(1:41,:);
growthStats.realLocalPerWorkerGrowthRates_timeSTD  = realLocalPerWorkerGrowthRates_timeSTD(1:41,:);
growthStats.realLocalPerHourGrowthRates_timeSTD    = realLocalPerHourGrowthRates_timeSTD(1:41,:);

growthStats.worldPerCapitaGrowthRate_overTime = worldPerCapitaGrowthRate_overTime;
growthStats.worldPerCapitaGrowthRate_timeAve  = worldPerCapitaGrowthRate_timeAve;






