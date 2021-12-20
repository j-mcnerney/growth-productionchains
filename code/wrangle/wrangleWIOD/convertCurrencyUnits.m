% Convert the currency units of data from the WIOD socioeconomic accounts
% to units of US$ to match the data in the WIOD IO tables.  The variables
% that need converting are the various income variables,
%
%   LaborIncome, CapIncome, and EmployeeCompensation
%
% and the price indices
%
%   IndustryPrices, HouseholdPrices

% Note: The exchange rates could be obtained from the WIOD data through
% EXR_WIOD_Sep12.xlsx.  Here we back it out from the ratio of value added
% computed in the IO tables and value added in the SEA data.  (We have
% checked that the values are the same.)

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')

% Get labor flows, capital flows, and value added for each industry in each
% country
nYears          = length(WIOD);
nCountries      = WIOD(1).nCountries;
nIndustries     = WIOD(1).nIndustries;
nFullIndustries = nCountries * nIndustries;

% Convert industries' income measures to the same currency (US $)
% Long note: In the WIOD IO tables, all countries use $.  In the WIOD
% socioeconomic accounts, each country uses its local currency.  To bring
% the income measures into units of US $, we compute the conversionFactors
% that WIOD is using based on value added, which appears in both data sets.
% The conversion factors are computed as the ratio of value added in US $
% (from the WIOD IO tables) to value added in local currency (from WIOD
% SEA).
%
% We have checked that for the US, where no currency conversion is needed,
% labor income + capital income from the socioeconomic accounts is directly
% equal to total value added from the IO tables.
conversionFactorsMatrix = zeros(nFullIndustries, nYears);
for iYear = 1:nYears
   valueAddedinUSdollars     = WIOD(iYear).ValueAddedRows(5,:);
   valueAddedinLocalCurrency = WIOD(iYear).LaborIncome + WIOD(iYear).CapIncome;
   conversionFactors         = valueAddedinUSdollars ./ valueAddedinLocalCurrency;
   conversionFactors2        = conversionFactors(1 + ([1:nCountries] - 1) * nIndustries); % make a 41x1 vector of conversion factors for each country.

   % Convert incomes
   WIOD(iYear).LaborIncome          = WIOD(iYear).LaborIncome     .* conversionFactors;
   WIOD(iYear).CapIncome            = WIOD(iYear).CapIncome       .* conversionFactors;
   WIOD(iYear).EmployeeCompensation = WIOD(iYear).EmployeeCompensation .* conversionFactors;
   WIOD(iYear).IndustryPrices       = WIOD(iYear).IndustryPrices  .* conversionFactors';
   WIOD(iYear).HouseholdPrices      = WIOD(iYear).HouseholdPrices .* conversionFactors2';
   
   conversionFactorsMatrix(:,iYear) = conversionFactors';
end

% TODO: Should we move these lines of code into augmentWIODhouseholdFlows
% and augmentWIODpriceIndices?  The argument is that this guarantees these
% lines are executed only once, when the data is loaded, so that another
% recoversion does not take place.

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')