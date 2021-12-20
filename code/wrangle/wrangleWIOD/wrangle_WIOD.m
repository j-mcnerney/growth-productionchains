announceFunction()

loadWIODbasicData
augmentWIODhouseholdFlows
augmentWIODpriceIndices
augmentWIODindustryCodes
augmentWIODcountryNames
convertCurrencyUnits
computeOtherAggregates

load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')
fieldNames = {
   'fileName'
   'year'
   'nCountries'
   'nIndustries'
   'nIndustriesFull'
   'nFinDemandCols'
   'nValAddedRows'
   'SAMmatrix'
   'IOtable'
   'HoursWorkedbyEmployees'
   'HoursWorkedbyLabor'
   'EmployeeCompensation'
   'LaborIncome'
   'CapIncome'
   'netTaxesOnProducts'
   'valueAddedBasicPrices'
   'ValueAdded'            %<--------
   'ValueAddedRows'
   'transportMargins'
   'FinalDemandCols'
   'finalDemandLessNX'
   'imports'
   'exports'
   'netExports'
   'GDPincome'
   'GDPexpend'
   'GDPincome_byCountry'
   'GDPexpend_byCountry'
   'OtherCells'
   'IndustryPrices'
   'HouseholdPrices'
   'countryNames'
   'countryCodes'
   'industryNames'
   'industryCodes'
   'countryNamesFull'
   'countryCodesFull'
   'industryNamesFull'
   'industryCodesFull'
   'units'
   'doc'
   'SAMdocumentation'
   };
WIOD = orderfields(WIOD, fieldNames);
save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')


% Ask user whether to move the saved .mat file to ./save where it will be
% used by analyses.
reply = input('Move saved WIOD mat file to ./save directory? (y/n)', 's');
if strcmp(reply, 'y')
   ! mv ./wrangle/wrangleWIOD/WIOD.mat ./save/WIOD.mat
else
   disp('Okay, WIOD.mat not moved. File in ./wrangle/wrangleWIOD/WIOD.mat')
end


% Any of the augment codes above can be run independently to update those
% parts of the WIOD struct, without disturbing its structure.