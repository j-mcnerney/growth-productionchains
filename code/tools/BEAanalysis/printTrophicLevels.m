% Sort the industries by trophic level and print out the ranked list of
% industries with their trophic levels given.

[sortedTrophicLevels, Isort] = sort( trophicLevels_byStage(1:end-1,1), 'ascend');
sortedIndustryNames          = US1997.industryLabels(Isort,2);

for iIndustry = 1:US1997.n
   thisLine = sprintf('%4.3f   %s',sortedTrophicLevels(iIndustry), sortedIndustryNames{iIndustry});
   disp(thisLine)
end