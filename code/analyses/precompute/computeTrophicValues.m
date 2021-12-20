function WorldEconomy = computeTrophicValues(WorldEconomy,pp)
% WorldEconomy = computeTrophicValues(WorldEconomy) computes the trophic
% levels and trophic depths using the data in WorldEconomy.  It tacks the
% results onto the WorldEconomy struct.

% Long note: There are different data issues to overcome dependon on
% whether we use value or labor income to define flows to households. With
% valued added there are a few industries that have zero expenditures.
% These need to be removed to obtain a finite Leontief inverse.
%
% When using labor expenditures, there are 3 places where WIOD lacks labor
% expenditures:
%   1- Some industries in some countries, sporatically
%   2- The ROW region has no data for labor expenditures at all
%   3- In the last 2 years, several countries lack labor expenditures

disp('Computing output multipliers...')

nYears = length(WorldEconomy);
for iYear = 1:nYears
   % Grab data
   n        = WorldEconomy(iYear).n;             % # of industries
   GDPvec   = WorldEconomy(iYear).GDPvec;        % GDP of industries
   Yvec     = WorldEconomy(iYear).Yvec(1:n);     % World final demand of industries
   A        = WorldEconomy(iYear).A;             % input coefficients
   Mout     = WorldEconomy(iYear).Mout;          % industry expenditures
   Z        = WorldEconomy(iYear).Z;             % matrix of industries only
   
   worldThetaVec = Yvec / sum(Yvec);
   
   % Isolate subset of industries with expenditures
   hasExpenditures = ~isnan(Mout) & (Mout > 0);
   
   % Compute trophic levels for this subset
   A_sub       = A(hasExpenditures,hasExpenditures);
   n_sub       = nnz(hasExpenditures);
   I_sub       = eye(n_sub);
   onesVec_sub = ones(n_sub,1);
   TL_sub      = inv(I_sub - A_sub') * onesVec_sub;
   
   % Store (set the trophic levels of industries with expenditures to NaN)
   trophicLevels = nan(n,1);
   trophicLevels(hasExpenditures) = TL_sub;
   
   % Set NaN trophic levels to zero for purpose of computing trophic depths
   trophicLevels_mod = trophicLevels;
   trophicLevels_mod(~hasExpenditures) = 0;
   
   % Compute trophic depth
   worldTrophicDepth = worldThetaVec' * trophicLevels_mod;
   
   % Compute country trophic depths
   nCountries           = WorldEconomy.nCountries;
   nIndustries          = WorldEconomy.nIndustries;
   countryTrophicDepths = zeros(nCountries,1);
   thetaVecConcat       = zeros(nCountries*nIndustries,1);
   etaVecConcat         = zeros(nCountries*nIndustries,1);
   for c = 1:nCountries
      
      % Make a mask with 1s for all of country c's industries and 0 elsewhere
      isInCountry_c = zeros(n,1);
      lower         = 1 + (c-1) * nIndustries;
      upper         = c * nIndustries;
      isInCountry_c(lower:upper) = 1;
      
      % Make a vector thetaVec_c containing the GDP shares of each industry
      % in country c.  (Industries outside c will thus have zeros.)
      switch pp.finalDemandShares
         case 'worldFinalDemand'
            thetaVec_c = (isInCountry_c .* Yvec)   ./ sum(isInCountry_c .* Yvec);
         case 'countryGDPshares'
            thetaVec_c = (isInCountry_c .* GDPvec) ./ sum(isInCountry_c .* GDPvec);
      end

      countryTrophicDepths(c) = thetaVec_c' * trophicLevels_mod;
      
      thetaVecConcat = thetaVecConcat + thetaVec_c;
      etaVecConcat   = etaVecConcat   + (thetaVec_c .* trophicLevels_mod) / countryTrophicDepths(c);
   end
   
   % Compute labor shares of gross output by industry
   totalLaborPayments       = Mout - sum(Z,1);
   laborSharesOfGrossOutput = totalLaborPayments ./ Mout;
   
   % Compute average labor shares of gross output by country
   nCountries       = WorldEconomy(1).nCountries;
   countryCodes     = WorldEconomy(1).countryCodes;
   countryCodesFull = WorldEconomy(1).countryCodesFull;
   countryLaborSharesOfGrossOutput = zeros(nCountries,1);
   for c = 1:nCountries
      thisCountryCode  = countryCodes(c);
      isCountry_c      = strmatch(thisCountryCode, countryCodesFull);
      
      totalLaborPayments_c = sum( totalLaborPayments(isCountry_c),'omitnan' );
      Mout_c               = sum( Mout(isCountry_c),'omitnan' );
      countryLaborSharesOfGrossOutput(c) = totalLaborPayments_c / Mout_c;
   end
   
   % Store values
   WorldEconomy(iYear).laborSharesOfGO        = laborSharesOfGrossOutput;
   WorldEconomy(iYear).countryLaborSharesOfGO = countryLaborSharesOfGrossOutput;
   WorldEconomy(iYear).trophicLevels          = trophicLevels;
   WorldEconomy(iYear).thetaVecConcat         = thetaVecConcat;
   WorldEconomy(iYear).etaVecConcat           = etaVecConcat;
   WorldEconomy(iYear).worldTrophicDepth      = worldTrophicDepth;
   WorldEconomy(iYear).countryTrophicDepths   = countryTrophicDepths;
end
