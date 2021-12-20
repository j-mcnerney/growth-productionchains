% Selects variables from the WDI data to be used in the growth model tests.

% Load WDI and WIOD data
firstTime = false;
if firstTime
   clear
   load('../../loading/LoadWorldBankData/WDI.mat') % WDI
   
   addpath('../WIODData')
   WorldEconomy  = loadWIOD();                     % WIOD
   WIODcountries = WorldEconomy(1).countryCodes;
   WIODcountries = [WIODcountries; 'WLD'];
   WIODyears     = [WorldEconomy.t];
end

% Grab selected variables from WDI
% Note: List below contains WDI indicator names and field names to be used
% in struct.
selectedIndicators  = {
   'NominalLocalGDP',   'GDP (current LCU)'
   'NominalUSD_GDP',    'GDP at market prices (current US$)'
   'GDPdeflator',       'GDP deflator (base year varies by country)'
   'CPI',               'Consumer price index (2010 = 100)'
   'PPP',               'PPP conversion factor; GDP (LCU per international $)'
   'GDPperCapita_2011PPP',  'GDP per capita; PPP (constant 2011 international $)'
   'GDPperCapitaGrowthRate',   'GDP per capita growth (annual %)'
   'Population',        'Population; total'
   'LaborForce',        'Labor force; total'
   % Variables for regression:
   'RealUSD_GDP',                'GDP at market prices (constant 2005 US$)'
   'RealPPP_GDP',                'GDP; PPP (constant 2011 international $)'
   'GrossSavingsPercGNI',        'Adjusted savings: gross savings (% of GNI)'
   'NetSavingsPercGNI',          'Adjusted savings: net national savings (% of GNI)'
   'RDexpenditurePercGDP',       'Research and development expenditure (% of GDP)'
   'ResearchersInRDPerMillion',  'Researchers in R&D (per million people)'
   'PopAnnualGrowthRate',        'Population growth (annual %)'
   'EnrollmentRatioPre',         'Gross enrolment ratio; pre-primary; both sexes (%)'
   'EnrollmentRatioPri',         'Gross enrollment ratio; primary; both sexes (%)'
   'EnrollmentRatioSec',         'Gross enrolment ratio; secondary; both sexes (%)'
   'EnrollmentRatioTer',         'Gross enrolment ratio; tertiary; both sexes (%)'
   'HealthExpendPercGDP',        'Health expenditure; total (% of GDP)'
   'HealthExpendPerCapitaPPP',   'Health expenditure per capita; PPP (constant 2011 international $)'
   'HealthExpendPerCapitaUSD'    'Health expenditure per capita (current US$)'
   'UrbanPopulationPercent',     'Urban population (% of total)'
   'TaxRevenue',                 'Tax revenue (% of GDP)'
   'GDPdeflatorGrowthRate',      'Inflation; GDP deflator (annual %)'
   'CPIGrowthRate',              'Inflation; consumer prices (annual %)'
   'GrossCapFormationPercGDP',   'Gross capital formation (% of GDP)'
   'GrossCapFormationConstLCU',  'Gross capital formation (constant LCU)'
   };
nVars = size(selectedIndicators,1);
for iVar = 1:nVars
   thisVariable    = selectedIndicators{iVar,2};
   
   % Select needed data
   isThisVariable  = strcmp(thisVariable, WDI.IndicatorNamesFull);
   isWIODcountries = ismember(WDI.CountryCodesFull, WIODcountries);
   isWIODyears     = ismember(WDI.years,            WIODyears);
   availableData   = WDI.IndicatorData(isThisVariable & isWIODcountries, isWIODyears);

   % Sort countries into the WIOD order
   availableCountries = WDI.CountryCodesFull(isThisVariable & isWIODcountries);
   temp = nan(WorldEconomy(1).nCountries+1, length(WIODyears));
   for c = 1:WorldEconomy(1).nCountries + 1
      thisCountryCode = WIODcountries{c};
      iMatch          = find( strcmp(thisCountryCode, availableCountries) );
      
      if ~isempty(iMatch)
         temp(c,:) = availableData(iMatch,:);
      end
   end
   availableData = temp;
   
   % Alternate method:
   %temp2 = nan(WorldEconomy(1).nCountries + 1, length(WIODyears));
   %[~,wiodIndex_of_avail]     = ismember(availableCountries, WIODcountries);
   %temp2(wiodIndex_of_avail,:) = availableData;
   %availableData              = temp2;
   %check: [WIODcountries(wiodIndex_of_avail) availableCountries]
   
   % Store
   thisFieldName = selectedIndicators{iVar,1};
   WDIselectedData.(thisFieldName) = availableData;
end

WDIselectedData.years = WIODyears;

save WDIselectedData.mat WDIselectedData