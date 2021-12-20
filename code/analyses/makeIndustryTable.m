function industryTableCell = makeIndustryTable()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp
% Makes a cell containing the data for the industries table.

announceFunction()

nIndustries = WorldEconomy(1).nIndustries;
industryTableCell = cell(nIndustries,8);

industryTableCell(:,1) = WorldEconomy(1).industryCodes;
industryTableCell(:,2) = WorldEconomy(1).industryNames;
industryTableCell(:,3) = num2cell( trophicStats.trophicLevels_timeAve_countryAve'  );
industryTableCell(:,4) = num2cell( trophicStats.trophicLevels_timeAve_countrySTD'  );
industryTableCell(:,5) = num2cell( gammaStats.gammaEstimates_timeAve_countryAve' * 100 );
industryTableCell(:,6) = num2cell( gammaStats.gammaEstimates_timeAve_countrySTD' * 100 );
industryTableCell(:,7) = num2cell( returnStats.realReturns_timeAve_countryAve'   * 100 );
industryTableCell(:,8) = num2cell( returnStats.realReturns_timeAve_countrySTD'   * 100 );

% Sort industries by average trophic level
[~,Isort] = sort( trophicStats.trophicLevels_timeAve_countryAve', 'descend' );
industryTableCell = industryTableCell(Isort,:);

% Convert to final table format. Put averages and standard deviation
% columns into one column.
newIndustryTableCell = cell(nIndustries,5);
for i = 1:nIndustries
   newIndustryTableCell(i,1:2) = industryTableCell(i,1:2);
   newIndustryTableCell{i,3}   = [num2str(industryTableCell{i,3},'%3.2f'),' (\pm',num2str(industryTableCell{i,4},'%3.2f'),')'];
   newIndustryTableCell{i,4}   = [num2str(industryTableCell{i,5},'%3.2f'),' (\pm',num2str(industryTableCell{i,6},'%3.2f'),')'];
   newIndustryTableCell{i,5}   = [num2str(industryTableCell{i,7},'%3.2f'),' (\pm',num2str(industryTableCell{i,8},'%3.2f'),')'];
end
industryTableCell = newIndustryTableCell;

dispc(' ')
printLatexTable(industryTableCell)
