% Augment WIOD struct with price index data from the WIOD socieconomic
% accounts (SEA) data.
%
% WIOD SEA has 4 price indices to choose from:
%   GO_P    Price levels gross output, 1995=100
%   II_P    Price levels of intermediate inputs, 1995=100
%   VA_P    Price levels of gross value added, 1995=100
%   GFCF_P	Price levels of gross fixed capital formation, 1995=100

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')
load('./wrangle/wrangleWIOD/WIOD_SEA.mat', 'WIOD_SEA')

% Get price index for each industry and the household sector in each
% country
nYears          = length(WIOD);
nCountries      = WIOD(1).nCountries;
nIndustries     = WIOD(1).nIndustries;
nFullIndustries = nCountries * nIndustries;
pvec            = zeros(nFullIndustries + nCountries,1);
for iYear = 1:nYears
   % Grab industry prices
   isIndustryPrice    = strcmp('GO_P', WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   maskIndustries     = isIndustryPrice & isNotTotalIndustry;
   industryPrices     = WIOD_SEA.dataTable(maskIndustries,iYear);
   industryPrices     = [industryPrices; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab household pricess
   isHouseholdPrice   = strcmp('VA_P', WIOD_SEA.variable);
   isTotalIndustry    = strcmp('total industries', WIOD_SEA.industry);
   maskHouseholds     = isHouseholdPrice & isTotalIndustry;
   householdPrices    = WIOD_SEA.dataTable(maskHouseholds,iYear);
   householdPrices    = [householdPrices; nan];                % Tack on a NaN for ROW
   
   % Store
   %pvec(1:nFullIndustries)     = industryPrices;
   %pvec(nFullIndustries+1:end) = householdPrices;
   WIOD(iYear).IndustryPrices  = industryPrices;
   WIOD(iYear).HouseholdPrices = householdPrices;
   
   % Check that industry names of price indices match the industry names of
   % WIOD data
   SEAindustryList = WIOD_SEA.industry(maskIndustries);
   for iIndustry = 1:nFullIndustries - nIndustries    %substract ROW industries
      WIODbasicIndustryName = lower( WIOD(1).industryNamesFull(iIndustry) );
      SEAindustryName       = SEAindustryList(iIndustry);
      isTheSame             = strcmp(WIODbasicIndustryName, SEAindustryName);
      
      [isTheSame WIODbasicIndustryName SEAindustryName]
   end
   
   % Check that country names of price indices match the country names of
   % WIOD data
   SEAcountryList = WIOD_SEA.country(maskIndustries);
   for iIndustry = 1:nFullIndustries - nIndustries    %substract ROW industries
      WIODbasicCountryName = WIOD(1).countryCodesFull(iIndustry);
      SEAcountryName       = SEAcountryList(iIndustry);
      isTheSame            = strcmp(WIODbasicCountryName, SEAcountryName);
      
      [isTheSame WIODbasicCountryName SEAcountryName]
   end
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')