function setTextLocations(theAxes, textLocationsTable)
% setTextLocations(theAxes, textLocationsTable) set the text locations
% using the information produced by getTextLocations.

% Identify textTag shared by these text labels
textTag = textLocationsTable.textTags{1};

nTextLabels = height(textLocationsTable);
for iLabel = 1:nTextLabels
   thisLabelName = textLocationsTable.textNames{iLabel};
   thisLabelLoc  = textLocationsTable.textLocations(iLabel,:);
   
   textObj = findobj('Parent',theAxes, 'UserData',textTag, 'String',thisLabelName);
   set(textObj, 'Position',thisLabelLoc)
end