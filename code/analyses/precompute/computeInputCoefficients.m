function WorldEconomy = computeInputCoefficients(WorldEconomy,pp)
% WorldEconomy = computeInputCoefficients(WorldEconomy) computes the input
% coefficients using the data in WorldEconomy.  It tacks the results onto
% the WorldEconomy struct.

disp('Computing input coefficients...')

nYears = length(WorldEconomy);
for iYear = 1:nYears   
   % Grab data
   n    = WorldEconomy(iYear).n;    % # of industries
   Z    = WorldEconomy(iYear).Z;    % matrix of intermediate transactions
   switch pp.householdIncomeType
      case 'employeeCompensation'
         householdIncome = WorldEconomy(iYear).EmployeeCompensation;
      case 'laborIncome'
         householdIncome = WorldEconomy(iYear).LaborIncome;
      case 'valueAdded'
         householdIncome = WorldEconomy(iYear).Vvec(1:n)';
   end
   
   % For industries w/o labor income data, assume labor income is fraction
   % of value added
   if strcmp(pp.householdIncomeType, 'laborIncome')
      if isnumeric(pp.HHIncomeFracAssumed)
         hasNoLaborIncomeData = isnan(householdIncome);
         Vvec = WorldEconomy(iYear).Vvec(1:n)';
         householdIncome(hasNoLaborIncomeData) = pp.HHIncomeFracAssumed * Vvec(hasNoLaborIncomeData);
      end
   end
   
   % Compute industries' expenditure
   Mout = sum(Z,1) + householdIncome;
   
   % Isolate industries with expenditures
   hasExpenditures = ~isnan(Mout) & (Mout > 0);
   M_sub         = Z(hasExpenditures, hasExpenditures);
   Mout_sub      = Mout(hasExpenditures);
   
   % Compute input coefficients
   A_sub = M_sub * inv(diag(Mout_sub));
   
   % Store this subset of input coefficents within the full matrix
   A = nan(n,n);
   A(hasExpenditures,hasExpenditures) = A_sub;
   
   % Store
   WorldEconomy(iYear).A    = A;
   WorldEconomy(iYear).Mout = Mout;
end
