function returnStats = computeReturnStatistics(WorldEconomy,pp)
% Computes various averages of the WIOD price returns over time, over
% countries, over industries.


disp('Computing price changes...')

% Note on NaN prices: WIOD socioeconomic accounts generally have
% price indices for each industry in each country in each year.  Exceptions
% are
%   1- All ROW industries
%   2- a few sporadic industries in other countries
%   3- All industries for 2010 and 2011
% In the first two cases industries have "NA" price indices in the data.
% In the third case the excel elements are simply blank.  Both cases are
% converted into NaNs when loading the data into Matlab.  These are what
% cause NaN price returns in the calculations below.

nYears          = length(WorldEconomy);
nIndustries     = WorldEconomy(1).nIndustries;
nFullIndustries = WorldEconomy(1).n;

% Industry prices and household wage rates
industryPrices_overTime = [WorldEconomy.pvec];
switch pp.householdIncomeType
   case 'employeeCompensation'
      wageRates_overTime = [WorldEconomy.wvecEmployees];
   case 'laborIncome'
      wageRates_overTime = [WorldEconomy.wvecLabor];
   case 'valueAdded'
      %wageRates_overTime = [WorldEconomy.wvecLabor];
      wageRates_overTime = [WorldEconomy.wvecValueAdded];
end

% Make wageRates_overTime a 1435 x 1 vector with the wage rates for each
% country in blocks of 35 elements
wageRates_temp = zeros(nFullIndustries, nYears);
for iYear = 1:nYears
   tempMatrix = repmat(wageRates_overTime(:,iYear), [1,nIndustries])';
   wageRates_temp(:,iYear) = tempMatrix(:);
end
wageRates_overTime = wageRates_temp;

% Nominal annual returns
priceReturns_overTime   = diff( log(industryPrices_overTime), 1, 2);   %log return
wageReturns_overTime    = diff( log(wageRates_overTime),      1, 2);   %log return
if pp.elimNanPriceReturns
   priceReturns_overTime(isnan(priceReturns_overTime)) = 0; % Try Charles' elimination of NaN price returns, line 492 in his script
   wageReturns_overTime(isnan(wageReturns_overTime))   = 0;
end

% Real annual returns (i.e. using wage rate as the deflator)
realReturns_overTime    = priceReturns_overTime - wageReturns_overTime;

% Time-averaged returns over whole period
priceReturns_timeAve  = sum(priceReturns_overTime(:,1:end-2), 2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)
wageReturns_timeAve   = sum(wageReturns_overTime(:,1:end-2),  2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)
realReturns_timeAve   = sum(realReturns_overTime(:,1:end-2),  2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)

% Time standard deviations of returns over whole period
realReturns_timeStd   = std(realReturns_overTime(:,1:end-2), 0, 2);

% Cross-country averages and cross-country standard deviations
realReturns_overTime_countryAve = zeros(nIndustries,nYears-1);
realReturns_timeAve_countryAve  = zeros(nIndustries,1);
realReturns_timeAve_countrySTD  = zeros(nIndustries,1);
industryNames     = WorldEconomy(1).industryNames;
industryNamesFull = WorldEconomy(1).industryNamesFull;
for i = 1:nIndustries
   % Make a mask to find a given industry in all countries
   isIndustry_i = strcmp( industryNames(i), industryNamesFull );
   returnIsNan  = isnan( realReturns_timeAve );
   mask         = isIndustry_i & ~returnIsNan;
   
   realReturns_overTime_countryAve(i,:) = mean( realReturns_overTime(mask,:), 1);
   realReturns_timeAve_countryAve(i)    = mean( realReturns_timeAve(mask)      );
   realReturns_timeAve_countrySTD(i)    = std(  realReturns_timeAve(mask)      );
end

nCountries             = WorldEconomy(1).nCountries;
countryCodes           = WorldEconomy(1).countryCodes;
countryCodesFull       = WorldEconomy(1).countryCodesFull;
switch pp.finalDemandShares
   case 'worldFinalDemand'
      thetaVec_overTime = [WorldEconomy.thetavec];
   case 'countryGDPshares'
      GDPvec_overTime   = [WorldEconomy.GDPvec];
      GDP_overTime      = [WorldEconomy.GDP];
      thetaVec_overTime = GDPvec_overTime ./ repmat(GDP_overTime, [nFullIndustries 1]);
end

realTotReturn_overTime = zeros(nCountries,nYears-1);
for c = 1:nCountries
   % Make a mask with 1s for all of country c's industries and 0 elsewhere
   thisCountryCode = countryCodes(c);
   isInCountry_c   = strcmp(thisCountryCode, countryCodesFull);
   
   % Get this countries real returns for all its industries over time and
   % the final demand shares for these industries
   realReturns_overTime_c      = realReturns_overTime(isInCountry_c,:);
   thetaVec_overTime_c         = thetaVec_overTime(isInCountry_c, 1:nYears-1);
   
   % Re-normalize weights for this country to sum to 1
   thetaVec_overTime_c  = thetaVec_overTime_c ./ repmat(sum(thetaVec_overTime_c,1), [nIndustries 1]);
   
   realTotReturn_overTime(c,:) = sum(thetaVec_overTime_c .* realReturns_overTime_c, 1,'omitnan');
end
realTotReturn_timeAve = sum(realTotReturn_overTime(:,1:end-2),  2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)


% Store quantities
returnStats.industryPrices_overTime         = industryPrices_overTime;
returnStats.wageRates_overTime              = wageRates_overTime;
returnStats.priceReturns_overTime           = priceReturns_overTime;
returnStats.wageReturns_overTime            = wageReturns_overTime;
returnStats.realReturns_overTime            = realReturns_overTime;
returnStats.priceReturns_timeAve            = priceReturns_timeAve;
returnStats.wageReturns_timeAve             = wageReturns_timeAve;
returnStats.realReturns_timeAve             = realReturns_timeAve;
returnStats.realReturns_timeStd             = realReturns_timeStd;
returnStats.realReturns_overTime_countryAve = realReturns_overTime_countryAve;
returnStats.realReturns_timeAve_countryAve  = realReturns_timeAve_countryAve;
returnStats.realReturns_timeAve_countrySTD  = realReturns_timeAve_countrySTD;

returnStats.thetaVec_overTime               = thetaVec_overTime;
returnStats.realTotReturn_overTime          = realTotReturn_overTime;
returnStats.realTotReturn_timeAve           = realTotReturn_timeAve;
