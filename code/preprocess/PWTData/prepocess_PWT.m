% Selects variables from the PWT data to be used in the growth model tests.

clear

% Load PWT data
load('../../loading/LoadPWTData/PWT.mat') % PWT data

% Load WIOD data to determine countries and years
addpath('../WIODData')
WorldEconomy  = loadWIOD();                     % WIOD
WIODcountries = WorldEconomy(1).countryCodes;
WIODcountries = [WIODcountries; 'WLD'];
WIODyears     = [WorldEconomy.t];

% Grab selected variables
% Note: List below contains PWT variables names and field names to be used
% in struct
selectedIndicators = {
   'LaborShareOfGDP',            'labsh'
   'DepreciationRate',           'delta'
   'TFPlevelPPP',                'ctfp'
   'TFPlevelPP_welfareRelevant', 'cwtfp'
   'TFPlevel',                   'rtfpna'
   'TFPlevel_welfareRelevant',   'rwtfpna'
   'CapitalStock_PPP',           'ck'
   'CapitalStock',               'rkna'
   'NumberEmployed',             'emp'
	'IndexHumanCapital',          'hc'
   'Population',                 'pop'
   'RealGDP_NationPricesinUSD',  'rgdpna'
};

% Change country code for Romania
% Note: WIOD uses ROM for Romania, while the PWT uses ROU. Change to WIOD
% convention.
PWT.countryCodesFull( strcmp(PWT.countryCodesFull, 'ROU') ) = {'ROM'};
PWT.countryCodes(     strcmp(PWT.countryCodes,     'ROU') ) = {'ROM'};

nVars = size(selectedIndicators,1);
for iVar = 1:nVars
   thisVariable    = selectedIndicators{iVar,2};
   
   % Select needed data
   variableColumn  = find(strcmp(thisVariable, PWT.variableNames));
   isWIODyears     = ismember(PWT.yearsFull,   WIODyears);

   % Arrange data as country X years matrix. Sort countries into the WIOD order.
   dataForThisVariable = nan(WorldEconomy(1).nCountries+1, length(WIODyears));
   for c = 1:WorldEconomy(1).nCountries + 1
      thisCountryCode = WIODcountries{c};
      dataIsFrom_c    = strcmp(thisCountryCode, PWT.countryCodesFull);
      
      thisVariable_overTime = PWT.data(dataIsFrom_c & isWIODyears,variableColumn)';
      if ~isempty(thisVariable_overTime)
         dataForThisVariable(c,:) = thisVariable_overTime;
      end
      
      %check: correct country and years being selected
      %thisCountryCode
      %PWT.countryCodesFull(dataIsFrom_c & isWIODyears)
      %PWT.yearsFull(dataIsFrom_c & isWIODyears)
   end
   
   % Store
   thisFieldName = selectedIndicators{iVar,1};
   PWTselectedData.(thisFieldName) = dataForThisVariable;
end

PWTselectedData.countryCodes = WIODcountries;
PWTselectedData.years        = WIODyears;

save PWTselectedData.mat PWTselectedData