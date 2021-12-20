function gammaStats = computeGammaStatistics(WorldEconomy,returnStats)
% Computes various averages of the improvement rates (gamma) over time,
% over countries, over industries.

disp('Computing productivity growth rates...')

nYears      = length(WorldEconomy);
nCountries  = WorldEconomy(1).nCountries;
nIndustries = WorldEconomy(1).nIndustries;
n           = WorldEconomy(1).n;

% Get price returns
realReturns_overTime = returnStats.realReturns_overTime;

% For each year, estimate gamma for each industry
gammaEstimates_overTime = zeros(n,nYears-1);
for iYear = 1:nYears - 1
   % Grab this year's returns and IO table
   rvec     = realReturns_overTime(:,iYear);
   A        = WorldEconomy(iYear).A;
   I        = eye(n);
   
   % Remove industries whose price returns are NaNs
   hasReturn       = ~isnan(rvec);
   hasExpenditures = (WorldEconomy(iYear).Mout' > 0);  % Note: Mout is slighly different from totalExpendvec. The former is computed in computeInputCoefficients.
   mask            = hasReturn & hasExpenditures;
   rvec_mod  = rvec(mask);
   A_mod     = A(mask,mask);
   I_mod     = I(mask,mask);
   
   % Estimate the gammas
   gammavec_mod = -(I_mod - A_mod') * rvec_mod;
   
   % Restore removed industries, setting their gammas to NaN
   gammavec = nan(n,1);
   gammavec(mask) = gammavec_mod;
   
   % Store
   gammaEstimates_overTime(:,iYear) = gammavec;
end

% Median gamma over time for industry
gammaEstimates_timeMed = median(gammaEstimates_overTime(:,1:end-2), 2);     % Median gamma over the period 1995-2009 (last 2 years have NaN price indices)

% For each year, compute gammaTwiddle for each country
gammaMedTwiddles           = zeros(nCountries,1);
gammaTwiddles_overTime     = zeros(nCountries,nYears-1);
gammaTwiddleWorld_overTime = zeros(1,nYears-1);
for iYear = 1:nYears - 1
   % gamma-twiddle equals the gross-output-weighted average of the gammas in that country
   grossOutputvec = WorldEconomy(iYear).grossOutputvec; % gross output of industries
   
   countryCodes     = WorldEconomy(1).countryCodes;
   countryCodesFull = WorldEconomy(1).countryCodesFull;
   for c = 1:nCountries
      % Make a mask with 1s for all of country c's industries and 0 elsewhere
      thisCountryCode = countryCodes(c);
      isInCountry_c   = strcmp(thisCountryCode, countryCodesFull);
      
      % Make a vector thetaGOvec_c containing the gross output shares of
      % each industry in country c.  (Industries outside c will thus have
      % zeros.)
      thetaGOvec_c = (isInCountry_c .* grossOutputvec) ./ sum(isInCountry_c .* grossOutputvec);
      
      % Remove industries for which there is no data on gamma values
      hasGamma = ~isnan( gammaEstimates_overTime(:,iYear) );
      
      % Store
      gammaTwiddles_overTime(c,iYear) = thetaGOvec_c(hasGamma)' * gammaEstimates_overTime(hasGamma,iYear);
      
      if iYear == 1
         hasGamma = ~isnan( gammaEstimates_timeMed );
         gammaMedTwiddles(c) = thetaGOvec_c(hasGamma)' * gammaEstimates_timeMed(hasGamma);
      end
   end
   
   thetaGOvec_c = grossOutputvec ./ sum(grossOutputvec);
   hasGamma     = ~isnan( gammaEstimates_overTime(:,iYear) );
   gammaTwiddleWorld_overTime(iYear)  = thetaGOvec_c(hasGamma)' * gammaEstimates_overTime(hasGamma,iYear);
end

% Gamma time-average over whole period
gammaEstimates_timeAve = mean(gammaEstimates_overTime(:,1:end-2), 2,'omitnan');   % Average gamma over the period 1995-2009 (last 2 years have NaN price indices)

% Cross-country averages and standard deviations of gamma for each industry
gammaEstimates_overTime_countryAve = zeros(nIndustries,nYears-1);
gammaEstimates_timeAve_countryAve  = zeros(nIndustries,1);
gammaEstimates_timeAve_countrySTD  = zeros(nIndustries,1);

industryNames     = WorldEconomy(1).industryNames;
industryNamesFull = WorldEconomy(1).industryNamesFull;
for i = 1:nIndustries
   % Make a mask to find a given industry in all countries
   isIndustry_i = strcmp( industryNames(i), industryNamesFull );
   gammaIsNan   = isnan( gammaEstimates_timeAve );
   mask         = isIndustry_i & ~gammaIsNan;
   
   gammaEstimates_overTime_countryAve(i,:) = mean( gammaEstimates_overTime(mask,:), 1);
   gammaEstimates_timeAve_countryAve(i)    = mean( gammaEstimates_timeAve(mask)  );
   gammaEstimates_timeAve_countrySTD(i)    = std(  gammaEstimates_timeAve(mask)  );
end

% Time-averaged gamma-twiddle over whole period
gammaTwiddles_timeAve     = sum(gammaTwiddles_overTime(:,1:end-2), 2) / 14; % Average gamma-twiddles over the period 1995-2009 (last 2 years have NaN price indices)
gammaTwiddleWorld_timeAve = sum(gammaTwiddleWorld_overTime(:,1:end-2), 2) / 14; % Average gamma-twiddles over the period 1995-2009 (last 2 years have NaN price indices)(:,1:end-2), 2) / 14; % Average gamma-twiddles over the period 1995-2009 (last 2 years have NaN price indices)

%gammaTwiddles_timeMed     = median(gammaTwiddles_overTime(:,1:end-2), 2);
gammaTwiddles_timeMed     = median(gammaTwiddles_overTime(:,1:8), 2);

% Time standard deviation over whole period
gammaTwiddles_timeSTD     = std(gammaTwiddles_overTime(:,1:end-2), 0,2);

% Central estimates of gamma distributions: Median value of non-NaN gammas
gammaAnnualMedian   = median( gammaEstimates_overTime(:),'omitnan' );
gammaOverTimeMedian = median( gammaEstimates_overTime, 1,'omitnan' );
gammaTimeAveMedian  = median( gammaEstimates_timeAve,'omitnan'     );
gammaCountryAnnualMedians   = zeros(nCountries,1);
gammaCountryOverTimeMedians = zeros(nCountries,nYears-1);
gammaCountryTimeAveMedians  = zeros(nCountries,1);
for c = 1:nCountries
   % Make a mask with 1s for all of country c's industries and 0 elsewhere
   thisCountryCode = countryCodes(c);
   isInCountry_c   = strcmp(thisCountryCode, countryCodesFull);
   
   gammas_overTime_c = gammaEstimates_overTime(isInCountry_c);
   gammas_timeAve_c  = gammaEstimates_timeAve(isInCountry_c);
   
   gammaCountryAnnualMedians(c)     = median( gammas_overTime_c(:),'omitnan' );
   gammaCountryOverTimeMedians(c,:) = median( gammas_overTime_c, 1,'omitnan' );
   gammaCountryTimeAveMedians(c)    = median( gammas_timeAve_c,'omitnan' );
end


% Store quantities
gammaStats.gammaEstimates_overTime            = gammaEstimates_overTime;
gammaStats.gammaEstimates_timeAve             = gammaEstimates_timeAve;
gammaStats.gammaEstimates_timeMedian          = gammaEstimates_timeMed;
gammaStats.gammaEstimates_overTime_countryAve = gammaEstimates_overTime_countryAve;
gammaStats.gammaEstimates_timeAve_countryAve  = gammaEstimates_timeAve_countryAve;
gammaStats.gammaEstimates_timeAve_countrySTD  = gammaEstimates_timeAve_countrySTD;
gammaStats.gammaTwiddles_overTime             = gammaTwiddles_overTime;
gammaStats.gammaTwiddles_timeAve              = gammaTwiddles_timeAve;
gammaStats.gammaTwiddles_timeSTD              = gammaTwiddles_timeSTD;
gammaStats.gammaCountryAnnualMedians          = gammaCountryAnnualMedians;
gammaStats.gammaCountryOverTimeMedians        = gammaCountryOverTimeMedians;
gammaStats.gammaCountryTimeAveMedians         = gammaCountryTimeAveMedians;
gammaStats.gammaAnnualMedian                  = gammaAnnualMedian;
gammaStats.gammaOverTimeMedian                = gammaOverTimeMedian;
gammaStats.gammaTimeAveMedian                 = gammaTimeAveMedian;
gammaStats.gammaTwiddleWorld_overTime         = gammaTwiddleWorld_overTime;
gammaStats.gammaTwiddleWorld_timeAve          = gammaTwiddleWorld_timeAve;
gammaStats.gammaMedTwiddles                   = gammaMedTwiddles;
gammaStats.gammaTwiddles_timeMed              = gammaTwiddles_timeMed;
