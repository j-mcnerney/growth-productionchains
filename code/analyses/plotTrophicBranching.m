function plotTrophicBranching()
% Draws branching diagram for how the trophic levels combine under
% aggregation.

global pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Load US economic data
%economy = loadEconomy_US1997();
economy = loadEconomy_US2002();
industryCodes = economy.industryLabels(:,1);

% Compute trophic levels and trophic depth at every stage of aggregation
trophicLevels_byStage = zeros(economy.n, 7);
trophicDepth_byStage  = zeros(1, 7);
numIndustriesPresent  = zeros(1, 7);

% First stage: no aggregation beyond that of the original data
[trophicLevels, trophicDepth] = computeTrophicLevelsBEA(economy);
trophicLevels_byStage(:,1)    = trophicLevels;
trophicDepth_byStage(1)       = trophicDepth;
numIndustriesPresent(1)       = length(trophicLevels);

% Remaining stages: combine industries that share the first nDigits
for nDigits = 5:-1:0  
   % Shorten NAICS codes to length nDigits
   labelList = keepDigits(industryCodes, nDigits);
   
   % Coarse-grain
   keepLastNodeSeparate = true;
   G = aggregationMatrix(economy.n+1,'custom',labelList,keepLastNodeSeparate);
   economyAgg = coarseGrainEconomy(G,economy);
   
   % Measure trophic levels
   [trophicLevels, trophicDepth] = computeTrophicLevelsBEA(economyAgg);
   numIndustriesPresent(6-nDigits+1) = length(trophicLevels);
   
   % Duplicate merged nodes
   % Long note: Coarse-graining makes the length of the trophicLevels
   % vector shorter at each aggregation stage.  We would like to make a
   % second vector of trophic levels with the same length as the original
   % number of industries n, with entries showing what the original
   % industry's trophic level eventually became at stage of mergers.  To
   % make this list, we duplicate the values in the trophicLevels vector,
   % mapping them back to the original n industries.  To do this, we create
   % a map iCoarse_of_iFine:
   %   iCoarse_of_iFine = (n+1) x 1 vector containing the "coarse-grained"
   %                      industry index for each industry in the original
   %                      fine-grained representation with n industries
   [~,~,iCoarse_of_iFine] = unique(labelList);
   trophicLevelsDuplicated = trophicLevels(iCoarse_of_iFine);
   
   % Record trophic levels at this stage of aggregation
   trophicLevels_byStage(:,6-nDigits+1) = trophicLevelsDuplicated;
   trophicDepth_byStage(6-nDigits+1)    = trophicDepth;
end






%========================================================================%
% Plot
%========================================================================%
% Appearance parameters
fontSize = 13;

% Create 2 maps to help color-code the industries by their first digit.
% There are n industries and c colors:
%    iColor_of_iIndustry = nx1 vector containing the color index of each industry
%    iIndustry_of_iColor = cx1 vector containing the industry indexes for a
%                          set of representatives from each color group
%
industryCodes = economy.industryLabels(:,1);     % get industries' NAICS codes
firstDigits   = keepDigits(industryCodes, 1);   % returns their first digits
[~,iIndustry_of_iColor,iColor_of_iIndustry] = unique(firstDigits);

% Set colors for each digit/color group
colorList = [
   rgb('Gray')
   0.4660    0.6740    0.1880
   rgb('Gold')
   0.8500    0.3250    0.0980
   rgb('DarkSlateGray')
   0.4940    0.1840    0.5560
   rgb('CornflowerBlue')
   0.6350    0.0780    0.1840
   rgb('Teal')
   rgb('DarkOrange')
   ];
nColors = length(colorList);
nStages = length(trophicDepth_byStage);

% Give meaning of NAICS categories
% http://www.census.gov/eos/www/naics/reference_files_tools/1997/1997.html
firstDigitLabels = {
   'Scrap'
   'Agrigulture'
   'Mining, utilities, construction'
   'Manufacturing'
   'Trade, transportation, storage'
   'Information, finance, real estate, professional services'
   'Education, health care, social care'
   'Entertainment and food services'
   'Other services'
   %'Public administration'
   'Government-owned industry'};

% Setup figure
figure(1)
clf
figpos = get(gcf,'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 621   574])

% Plot
hold on
% First plot one member of each digit-group to get a set of line handles
% to help setup the legend
firstDigitHandles = zeros(nColors,1);
for iColor = 1:length(iIndustry_of_iColor)
   iRepresentativeIndustry   = iIndustry_of_iColor(iColor);
   industryColor             = colorList(iColor,:);
   firstDigitHandles(iColor) = plot([nStages:-1:1]-1, trophicLevels_byStage(iRepresentativeIndustry,:), 'Color',industryColor);
end

% Plot trophic levels
for iIndustry = 1:economy.n
   iColor        = iColor_of_iIndustry(iIndustry);
   industryColor = colorList(iColor,:);
   plot([nStages:-1:1]-1, trophicLevels_byStage(iIndustry,:), 'Color',industryColor, 'LineWidth',1)
end
plot([nStages:-1:1]-1, trophicDepth_byStage, 'k', 'LineWidth',4)  %trophic depth line
hold off

% Legend
% Note: order legend entries according to the trophic levels of the 1-digit industries
TL_ofOneDigitIndustries = trophicLevels_byStage(iIndustry_of_iColor,6);
[~,Ireorder] = sort(TL_ofOneDigitIndustries,'descend');
hLegend = legend(firstDigitHandles(Ireorder), firstDigitLabels(Ireorder), 'Location','SouthWest');
set(hLegend, 'FontSize',fontSize, 'Box','off')

% Refine
set(gca, 'Box','on')
set(gca, 'FontSize',fontSize)
set(gca, 'XGrid','off')
set(gca, 'YLim',[0 4.6])   % if using labor-based trophic levels
%set(gca, 'YLim',[0 3.7])   % if using value added-based trophic levels
consistentTickPrecision(gca,'y',1)
xlabel('Number of NAICS digits')
ylabel('Output multiplier')

% Save
saveImage = true;
if saveImage
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'TrophicBranching';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end