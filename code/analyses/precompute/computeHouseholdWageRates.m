function WorldEconomy = computeHouseholdWageRates(WorldEconomy)

disp('Computing wage rates...')

nYears          = length(WorldEconomy);
nCountries      = WorldEconomy(1).nCountries;

% Compute wage rates using WIOD data for income and hours worked
countryCodeList  = WorldEconomy(1).countryCodes;
countryCodesFull = WorldEconomy(1).countryCodesFull;

for iYear = 1:nYears
   WorldEconomy(iYear).wvecEmployees = zeros(nCountries,1);
   WorldEconomy(iYear).wvecLabor     = zeros(nCountries,1);   
   for c = 1:nCountries
      countryName         = countryCodeList{c};
      isThisCountry       = strcmp(countryName, countryCodesFull);
      hasIncome2          = ~isnan(WorldEconomy(iYear).EmployeeCompensation');
      hasIncome3          = ~isnan(WorldEconomy(iYear).LaborIncome');
      mask2               = isThisCountry & hasIncome2;
      mask3               = isThisCountry & hasIncome3;
      
      totalIncome2_c      = sum( WorldEconomy(iYear).EmployeeCompensation(mask2)   );
      totalIncome3_c      = sum( WorldEconomy(iYear).LaborIncome(mask3)            );
      totalHoursWorked2_c = sum( WorldEconomy(iYear).HoursWorkedbyEmployees(mask2) );
      totalHoursWorked3_c = sum( WorldEconomy(iYear).HoursWorkedbyLabor(mask3)     );
      
      WorldEconomy(iYear).wvecEmployees(c) = totalIncome2_c / totalHoursWorked2_c;
      WorldEconomy(iYear).wvecLabor(c)     = totalIncome3_c / totalHoursWorked3_c;
   end
end
