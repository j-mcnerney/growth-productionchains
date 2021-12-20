function plotTrophicStructure()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

announceFunction()

countryCodeToPlot = 'CHN';
yLim = [2 5.1];
plotTrophicStructure_sub(mfilename,WorldEconomy,trophicStats,ap,pp,countryCodeToPlot,yLim)

countryCodeToPlot = 'USA';
yLim = [1.5 4.1];
plotTrophicStructure_sub(mfilename,WorldEconomy,trophicStats,ap,pp,countryCodeToPlot,yLim)

end




function plotTrophicStructure_sub(figureNum,WorldEconomy,trophicStats,ap,pp,countryCodeToPlot,yLim)
%========================================================================%
% Preprocessing
%========================================================================%
% Get industry codes, order them by agriculture, manufacturing, services
industryCodes  = WorldEconomy(1).industryCodes;
nIndustries    = WorldEconomy(1).nIndustries;
Iagriculture   = [1,3];
Imanufacturing = [2,4:18];
Iservices      = [19:35];
Isort          = [Iagriculture Imanufacturing Iservices];

% Get country names and codes
countryNames     = WorldEconomy(1).countryNames;
countryCodes     = WorldEconomy(1).countryCodes;
countryCodesFull = WorldEconomy(1).countryCodesFull;

% Choose year of data to show
iYear = 1;

% Get name and data for country to be plotted
c = find( strcmp(countryCodes, countryCodeToPlot) );
countryNameToPlot = countryNames{c};
isCountry_c       = strcmp(countryCodeToPlot, countryCodesFull);
trophicLevels_c   = WorldEconomy(iYear).trophicLevels(isCountry_c);
GDPvec_c          = WorldEconomy(iYear).GDPvec(isCountry_c);
grossOutputvec_c  = WorldEconomy(iYear).grossOutputvec(isCountry_c);

% Choose GDP or gross output node sizes
nodeSizeCase = 'grossOuput';     %grossOuput GDP

%========================================================================%
% Plot
%========================================================================%
A = length(Iagriculture);
M = length(Imanufacturing);
S = length(Iservices);

% Additional or customized appearance parameters
xLim            = [-1 A+M+S + 3];
nodeColor       = [58+15+2 139+20+2-4 177+14-2]/255;
textColor       = [0 0 0];
ap.fontSize     = 14;
countryFontSize = 19;
nodeScaleFactor = 200;
y_xlabel        = 0.046;

% Setup figure
newFigure( [figureNum,': ',countryNameToPlot])
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2)  560   295])

% Compute marker sizes
totalGDP_c         = sum(GDPvec_c);
totalGrossOutput_c = sum(grossOutputvec_c);
switch nodeSizeCase
   case 'grossOuput'
      nodeSizes = sqrt(grossOutputvec_c' / totalGrossOutput_c) * nodeScaleFactor;
   case 'GDP'
      nodeSizes = sqrt(GDPvec_c' / totalGDP_c) * nodeScaleFactor;
end

% Sort data by agriculture, manfuacturing, and services sectors
trophicLevels_c = trophicLevels_c(Isort);
nodeSizes       = nodeSizes(Isort);
industryCodes   = industryCodes(Isort);

% Set industry positions
x_industry        = [1:35];
x_industry(1:2)   = x_industry(1:2)   + 0;
x_industry(3:18)  = x_industry(3:18)  + 1;
x_industry(19:35) = x_industry(19:35) + 2;

% Plot industries
hold on
for i = 1:nIndustries
   if nodeSizes(i) > 0
      plot(x_industry(i), trophicLevels_c(i), '.', 'Color',nodeColor, 'MarkerSize',nodeSizes(i))
   end
end
hold off

% Plot vertical lines separating agriculture, manufacturing, services
hold on
plot([A A] + 1,     yLim, '--', 'Color','k')
plot([A+M A+M] + 2, yLim, '--', 'Color','k')
hold off

% Plot industry codes
yRange = diff(yLim);
x      = x_industry;
y      = trophicLevels_c + sqrt(nodeSizes)'*0.02 + yRange * 0.02;
text(x,y,industryCodes, 'Color',textColor, 'FontSize',ap.fontSize, 'FontWeight','normal', 'HorizontalAlignment','center', 'UserData','industry_label')
switch countryCodeToPlot
   %textLocationsTable = getTextLocations(gca, 'industry_label');
   %save('./save/textLocationsTable_CHN.mat', 'textLocationsTable')
   case 'CHN'
      load('./save/textLocationsTable_CHN.mat')
      setTextLocations(gca, textLocationsTable)
   case 'USA'
      load('./save/textLocationsTable_USA.mat')
      setTextLocations(gca, textLocationsTable)    
end

% Refine
set(gca, 'Box','off')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'YTick',[1:0.5:5])
consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',ap.fontSize)
ylabel('Output multiplier')

% Country name
xCountryName = 37;
yCountryName = yLim(2) * 0.96;
text(xCountryName, yCountryName, countryNameToPlot, 'FontSize',countryFontSize, 'HorizontalAlignment','right')

% Agriculture, manufacturing, and services labels on x-axis
set(gca, 'XTick',[], 'XTickLabel',[])
annotation(gcf,'textbox',...
   [0.10 y_xlabel 0.191857142857143 0.0428571428571428],...
   'String','Agriculture',...
   'LineStyle','none',...
   'FontSize',ap.fontSize,...
   'FontName','Helvetica',...
   'FitBoxToText','off');
annotation(gcf,'textbox',...
   [0.28 y_xlabel 0.191857142857143 0.0428571428571428],...
   'String','Manufacturing',...
   'LineStyle','none',...
   'FontSize',ap.fontSize,...
   'FontName','Helvetica',...
   'FitBoxToText','off');
annotation(gcf,'textbox',...
   [0.67 y_xlabel 0.191857142857143 0.0428571428571428],...
   'String','Services',...
   'LineStyle','none',...
   'FontSize',ap.fontSize,...
   'FontName','Helvetica',...
   'FitBoxToText','off');

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = ['OMStructure_',countryCodeToPlot];
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
end
