% Augment WIOD struct with country names.

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')

nYears = length(WIOD);
for iYear = 1:nYears
   % Note: The names below are not in strict alphabetical order, but in the
   % order of the three-letter country codes in the WIOD data.
   WIOD(iYear).countryNames = {
      'Australia'
      'Austria'
      'Belgium'
      'Bulgaria'
      'Brazil'
      'Canada'
      'China'
      'Cyprus'
      'Czech Republic'
      'Germany'
      'Denmark'
      'Spain'
      'Estonia'
      'Finland'
      'France'
      'United Kingdom'
      'Greece'
      'Hungary'
      'Indonesia'
      'India'
      'Ireland'
      'Italy'
      'Japan'
      'Korea, Republic of'
      'Lithuania'
      'Luxembourg'
      'Latvia'
      'Mexico'
      'Malta'
      'Netherlands'
      'Poland'
      'Portugal'
      'Romania'
      'Russia'
      'Slovak Republic'
      'Slovenia'
      'Sweden'
      'Turkey'
      'Taiwan'
      'United States'
      'Rest of World'
      };
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')