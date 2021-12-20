% Augment WIOD struct with labor flows, capital flows, and value added from
% the WIOD socieconomic accounts (SEA) data.

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')
load('WIOD_SEA.mat', 'WIOD_SEA')

% Get labor flows, capital flows, and value added for each industry in each
% country
nYears          = length(WIOD);
nCountries      = WIOD(1).nCountries;
nIndustries     = WIOD(1).nIndustries;
nFullIndustries = nCountries * nIndustries;
for iYear = 1:nYears
   iYear
   
   % Grab total labor payments
   isLaborComponent   = strcmp('LAB',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask1              = isLaborComponent & isNotTotalIndustry;
   laborIncomes       = WIOD_SEA.dataTable(mask1,iYear);
   laborIncomes       = [laborIncomes; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab total capital payments
   isCapComponent     = strcmp('CAP',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask2              = isCapComponent & isNotTotalIndustry;
   capitalIncomes     = WIOD_SEA.dataTable(mask2,iYear);
   capitalIncomes     = [capitalIncomes; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab value added payments
   isVAComponent      = strcmp('VA',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask3              = isVAComponent & isNotTotalIndustry;
   valuesAdded        = WIOD_SEA.dataTable(mask3,iYear);
   valuesAdded        = [valuesAdded; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab employee compensation payments
   isVariable         = strcmp('COMP',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask              = isVariable & isNotTotalIndustry;
   employCompensations = WIOD_SEA.dataTable(mask,iYear);
   employCompensations = [employCompensations; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab hours worked by labor
   isVariable         = strcmp('H_EMP',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask               = isVariable & isNotTotalIndustry;
   hoursWorkedbyLabor = WIOD_SEA.dataTable(mask,iYear);
   hoursWorkedbyLabor = [hoursWorkedbyLabor; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Grab hours worked by employees
   isVariable         = strcmp('H_EMPE',WIOD_SEA.variable);
   isNotTotalIndustry = ~strcmp('total industries', WIOD_SEA.industry);
   mask               = isVariable & isNotTotalIndustry;
   hoursWorkedbyEmployees = WIOD_SEA.dataTable(mask,iYear);
   hoursWorkedbyEmployees = [hoursWorkedbyEmployees; nan(nIndustries,1)];  % Tack on NaNs for the ROW industries. (WIOD has no data for these.)
   
   % Store
   WIOD(iYear).HoursWorkedbyEmployees = hoursWorkedbyEmployees';
   WIOD(iYear).HoursWorkedbyLabor     = hoursWorkedbyLabor';
   WIOD(iYear).EmployeeCompensation   = employCompensations';
   WIOD(iYear).LaborIncome            = laborIncomes';
   WIOD(iYear).CapIncome              = capitalIncomes';
   WIOD(iYear).ValueAdded             = valuesAdded';
  
   % Check that industry names of price indices match the industry names of
   % WIOD data
   SEAindustryList = WIOD_SEA.industry(mask1);
   for iIndustry = 1:nFullIndustries - nIndustries    %substract ROW industries
      WIODbasicIndustryName = lower( WIOD(1).industryNamesFull(iIndustry) );
      SEAindustryName       = SEAindustryList(iIndustry);
      isTheSame             = strcmp(WIODbasicIndustryName, SEAindustryName);
      
      %[isTheSame WIODbasicIndustryName SEAindustryName]
   end
   
   % Check that country names of price indices match the country names of
   % WIOD data
   SEAcountryList = WIOD_SEA.country(mask1);
   for iIndustry = 1:nFullIndustries - nIndustries    %substract ROW industries
      WIODbasicCountryName = WIOD(1).countryCodesFull(iIndustry);
      SEAcountryName       = SEAcountryList(iIndustry);
      isTheSame            = strcmp(WIODbasicCountryName, SEAcountryName);
      
      %[isTheSame WIODbasicCountryName SEAcountryName]
   end
   
   % Check that labor income + capital income equals value added
   %((WIOD(iYear).LaborIncome + WIOD(iYear).CapIncome) ./ WIOD(iYear).ValueAdded)'
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')