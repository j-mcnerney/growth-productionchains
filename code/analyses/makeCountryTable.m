function countryTableCell = makeCountryTable(WDIselectedData)
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp
% Makes a cell containing the data for the countries table.

announceFunction()

nCountries = WorldEconomy(1).nCountries;
countryTableCell = cell(nCountries,6);

countryTableCell(:,1) = WorldEconomy(1).countryCodes;
countryTableCell(:,2) = WorldEconomy(1).countryNames;
countryTableCell(:,3) = num2cell( WDIselectedData.GDPperCapita_2011PPP([1:40,42],1) );
countryTableCell(:,4) = num2cell( growthStats.countryRealLocalPerCapitaGrowthRates_timeAve * 100 );    % Check data
countryTableCell(:,5) = num2cell( gammaStats.gammaTwiddles_timeAve   * 100 );
countryTableCell(:,6) = num2cell( trophicStats.trophicDepths_timeAve );

% Convert to final table format
newCountryTableCell = cell(nCountries,6);
for i = 1:nCountries
   newCountryTableCell(i,1:2) = countryTableCell(i,1:2);
   newCountryTableCell{i,3}   = num2money(countryTableCell{i,3});
   newCountryTableCell{i,3}   = newCountryTableCell{i,3}(2:end-3);     %strip the money symbol, decimal places
   newCountryTableCell{i,4}   = num2str(countryTableCell{i,4},'%3.2f');
   newCountryTableCell{i,5}   = num2str(countryTableCell{i,5},'%3.2f');
   newCountryTableCell{i,6}   = num2str(countryTableCell{i,6},'%3.2f');
end
countryTableCell = newCountryTableCell;

% Rest of world row
countryTableCell{41,4} = 'N.A.'; %ave. growth per capita
countryTableCell{41,5} = 'N.A.'; %gamma-twiddle

dispc(' ')
printLatexTable(countryTableCell)