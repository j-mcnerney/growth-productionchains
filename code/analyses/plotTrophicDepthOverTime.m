function plotTrophicDepthOverTime()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Form matrix of trophic depth for each country (row) in each year (col)
countryTrophicDepths_overTime  = [WorldEconomy.countryTrophicDepths];

% Select countries to plot
countriesToPlot   = {'CHN','SVK','TUR','KOR','BRA','IND','USA','GBR'};
countryCodes      = WorldEconomy(1).countryCodes;
countryNames      = WorldEconomy(1).countryNames;
nPlottedCountries = length(countriesToPlot);
years             = [1995:2011];


%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim = [1995 2009];
yLim = [2 5.2];
lineStyleList = {'-',':','-.','--','-',':','-.','--'};

% Setup figure
newFigure(mfilename)
clf

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
hCountries = [];
for iPlottedCountry = 1:nPlottedCountries
   thisCountry = countriesToPlot(iPlottedCountry);
   iCountry    = find(strcmp(thisCountry,countryCodes));
   
   lineStyle = lineStyleList{iPlottedCountry};
   h = plot(years, countryTrophicDepths_overTime(iCountry,:), 'LineWidth',2, 'LineStyle',lineStyle);
   hCountries = [hCountries h];
end
hold off

% Labels for countries
locationList = [
   2005.58064516129 4.4985553482073 %CHN
   2003.161290322582   4.015495458956 %SVK
   1996.967741935484   3.230990758762 %TUR
   2007.387096774194   3.396159745808 %KOR
   2003.161290322580   3.173348133853 %BRA
   2007.741935483872   3.042924694361 %IND
   2000.61290322581 2.17904641170303 %USA
   2005.032258064515   2.444339427937 %GBR
   ];
for iPlottedCountry = 1:nPlottedCountries
   thisCountry = countriesToPlot(iPlottedCountry);
   iCountry    = find(strcmp(thisCountry,countryCodes));
   countryName = countryNames(iCountry);
   
   x = locationList(iPlottedCountry,1);
   y = locationList(iPlottedCountry,2);
   text(x,y,countryName, 'FontSize',ap.fontSize);
end
annotation(gcf,'line',[0.592857142857143 0.628571428571429],...
   [0.164285714285714 0.226190476190476]);

% Legend
[~,IcountriesPlotted] = ismember(countriesToPlot, countryCodes);
countryNamesToPlot    = countryNames(IcountriesPlotted);

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',ap.fontSize)
ylabel('Average output multiplier')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'TrophicDepthOverTime';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
