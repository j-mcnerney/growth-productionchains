function WorldEconomy = turnOffTrade(WorldEconomyBase,pp)

% If the turnOffTrade flag is turned on, reload the WIOD data while
% zero-ing out trade entries
if pp.turnOffTrade == false
   WorldEconomy = WorldEconomyBase;
   
else
   disp('Turning ''off'' the effects of trade...')

   % Load WIOD struct
   load('../../../loading/LoadWIODData/WIOD.mat')
   
   nCountries  = WIOD(1).nCountries;
   nIndustries = WIOD(1).nIndustries;
   n           = nCountries * nIndustries;
   
   nYears = length(WIOD);
   for iYear = 1:nYears
      % Simplify notation for main parts of table. (Notation from Miller and
      % Blair p. 501-513)
      % * Important matrices are given as one-letter mathematical symbols
      % * Important vectors end with 'vec'
      % * Important scalars are spelled out
      Z  = WIOD(iYear).IOtable;
      F  = WIOD(iYear).FinalDemandCols;
      V  = WIOD(iYear).ValueAddedRows;
      TM = WIOD(iYear).transportMargins;
      
      % "Turn off" international trade flows
      for c = 1:nCountries
         % Identify indexes of foreign industries to country c
         IallIndustries = [1:n];
         Idomestic_c    = [1:nIndustries] + (c-1)*nIndustries;
         Iforeign_c     = setdiff(IallIndustries, Idomestic_c);
         
         % Turn off imports
         Z(Iforeign_c,Idomestic_c) = 0;
         TM(Idomestic_c)           = 0;
         
         % Turn off exports
         Z(Idomestic_c,Iforeign_c) = 0;
      end
      
      % Compute major aggregates
      GDPvec         = WIOD(iYear).GDPexpend;       % industry GDP contibutions
      Yvec           = sum(F,2);                    % world final demand vector (GDP less net exports)
      Vvec           = sum(V,1)' + TM';             % world value added vector (VA plus transportation)
      totalExpendvec = sum(Z,1)' + sum(V,1)' + TM'; % gross expenditures of industries (AKA Mhat-vector)
      grossOutputvec = sum(Z,2)  + sum(F,2);        % gross output of industries (AKA Mcheck-vector)
      
      worldGDP         = sum(Yvec);
      worldValAdded    = sum(Vvec);
      grossOutputWorld = sum(grossOutputvec);
      intermedConsumptionWorld = sum(Z(:));
      
      thetavec       = Yvec/worldGDP;               % world final demand shares
      
      % Note on Yvec versus GDPvec: Elements of Yvec are not the GDP
      % contributions of individual industries because they do no account for
      % imports and exports.  GDPvec does, and is equal to Yvec plus the net
      % exports of each industry.  At the world level the sum of all net
      % exports nets to zero, and thus sum(GDPvec) = sum(Yvec) = worldGDP.
      
      
      % Basic info
      WorldEconomy(iYear).name             = 'World';
      WorldEconomy(iYear).t                = WIOD(iYear).year;
      WorldEconomy(iYear).nCountries       = nCountries;
      WorldEconomy(iYear).nIndustries      = nIndustries;
      WorldEconomy(iYear).n                = n;
      WorldEconomy(iYear).nFinDemandCols   = WIOD.nFinDemandCols;
      WorldEconomy(iYear).nValAddedRows    = WIOD.nValAddedRows;
      
      % Matrices
      WorldEconomy(iYear).SAMmatrix        = WIOD(iYear).SAMmatrix;
      WorldEconomy(iYear).X                = nan(n,n);
      WorldEconomy(iYear).Z                = Z;
      WorldEconomy(iYear).Phi              = nan(n,n);
      WorldEconomy(iYear).A                = nan(n,n);
      WorldEconomy(iYear).P                = nan(n,n);
      WorldEconomy(iYear).ValueAddedRows   = WIOD(iYear).ValueAddedRows;
      WorldEconomy(iYear).FinalDemandCols  = WIOD(iYear).FinalDemandCols;
      
      % Vectors
      WorldEconomy(iYear).Cvec             = nan(n,1);
      WorldEconomy(iYear).Yvec             = Yvec;
      WorldEconomy(iYear).Lvec             = nan(n,1);
      WorldEconomy(iYear).Vvec             = Vvec;
      WorldEconomy(iYear).Xhat             = nan(n,1);
      WorldEconomy(iYear).GDPvec           = GDPvec;
      WorldEconomy(iYear).grossOutputvec   = grossOutputvec;
      WorldEconomy(iYear).totalExpendvec   = totalExpendvec;
      WorldEconomy(iYear).pvec             = WIOD(iYear).IndustryPrices;
      WorldEconomy(iYear).wvecValueAdded   = WIOD(iYear).HouseholdPrices;
      WorldEconomy(iYear).thetavec         = thetavec;
      WorldEconomy(iYear).onesvec          = ones(n,1);
      WorldEconomy(iYear).transportMargins = WIOD(iYear).transportMargins;
      
      WorldEconomy(iYear).HoursWorkedbyEmployees = WIOD(iYear).HoursWorkedbyEmployees;
      WorldEconomy(iYear).HoursWorkedbyLabor     = WIOD(iYear).HoursWorkedbyLabor;
      WorldEconomy(iYear).EmployeeCompensation   = WIOD(iYear).EmployeeCompensation;
      WorldEconomy(iYear).LaborIncome            = WIOD(iYear).LaborIncome;
      WorldEconomy(iYear).CapIncome              = WIOD(iYear).CapIncome;
      
      % Scalar aggregates
      WorldEconomy(iYear).grossOutput         = grossOutputWorld;
      WorldEconomy(iYear).intermedConsumption = intermedConsumptionWorld;
      WorldEconomy(iYear).totValAdded         = worldValAdded;
      WorldEconomy(iYear).GDP                 = worldGDP;
      WorldEconomy(iYear).L                   = nan;
      
      % Documentation
      WorldEconomy(iYear).timeUnits             = 'years';
      WorldEconomy(iYear).moneyUnits            = WIOD.units;
      WorldEconomy(iYear).goodsUnits            = {};
      WorldEconomy(iYear).countryNames          = WIOD.countryNames;
      WorldEconomy(iYear).countryCodes          = WIOD.countryCodes;
      WorldEconomy(iYear).industryNames         = WIOD.industryNames;
      WorldEconomy(iYear).industryCodes         = WIOD.industryCodes;
      WorldEconomy(iYear).countryNamesFull      = WIOD.countryNamesFull;
      WorldEconomy(iYear).countryCodesFull      = WIOD.countryCodesFull;
      WorldEconomy(iYear).industryNamesFull     = WIOD.industryNamesFull;
      WorldEconomy(iYear).industryCodesFull     = WIOD.industryCodesFull;
      WorldEconomy(iYear).finalDemandCategories = {};
      WorldEconomy(iYear).valueAddedComponents  = {};
      WorldEconomy(iYear).doc                   = WIOD.doc;
      WorldEconomy(iYear).SAMdocumentation      = WIOD.SAMdocumentation;
   end
   
end
