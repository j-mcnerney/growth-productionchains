function plotGammaTwiddleOverTime()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Form matrix of trophic depth for each country (row) in each year (col)
countryGammaTwiddles_overTime  = gammaStats.gammaTwiddles_overTime;

% Change units to percent
countryGammaTwiddles_overTime = countryGammaTwiddles_overTime * 100;

% Select countries to plot
countriesToPlot  = {'CHN','SVK','TUR','KOR','BRA','IND','USA','GBR'};

countryCodes     = WorldEconomy(1).countryCodes;
countryNames     = WorldEconomy(1).countryNames;

years = [1995:2010];




%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim = [1995 2008];
yLim = [-0.04 0.08]*100;
lineStyleList = {'-',':','-.','--','-',':','-.','--','-'};

% Setup figure
newFigure(mfilename)
clf

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot data
hCountries = [];
hold on
plot(years, zeros(length(years),1), 'k-', 'LineWidth',1)
for iPlottedCountry = 1:length(countriesToPlot)
   thisCountry = countriesToPlot(iPlottedCountry);
   iCountry    = find(strcmp(thisCountry,countryCodes));
   
   h = plot(years, countryGammaTwiddles_overTime(iCountry,:), 'LineWidth',2);
   
   hCountries = [hCountries h];
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'FontSize',ap.fontSize)
ylabel('Average productivity improvement rate (% yr^{-1})')

% Legend
[~,IcountriesPlotted] = ismember(countriesToPlot, countryCodes);
countryNamesToPlot    = countryNames(IcountriesPlotted);
theLegend = legend(hCountries, countryNamesToPlot, 'Location','North');
set(theLegend, 'Box','off', 'FontSize',12, 'Position',[0.3674 0.6238 0.2295 0.2940])

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'GammaTwiddleOverTime';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
