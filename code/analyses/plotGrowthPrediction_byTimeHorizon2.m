function countryValues = plotGrowthPrediction_byTimeHorizon2()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
years                  = [WorldEconomy.t]';
gammaTwiddles_overTime = gammaStats.gammaTwiddles_overTime;
trophicDepths_overTime = trophicStats.trophicDepths_overTime;
switch pp.growthConcept
   case 'perHour'
      growthRates_overTime = growthStats.countryRealLocalPerHourGrowthRates_overTime;
   case 'perWorker'
      growthRates_overTime = growthStats.countryRealLocalPerWorkerGrowthRates_overTime;
   case 'perCapita'
      growthRates_overTime = growthStats.countryRealLocalPerCapitaGrowthRates_overTime;
end

% Change units to percent per year
gammaTwiddles_overTime = gammaTwiddles_overTime * 100;
growthRates_overTime   = growthRates_overTime * 100;

% Construct a simple growth forecast between all pairs of years
nYears                       = length(years) - 2;   %exclude 2010 and 2011
RMSErrorMatrix               = nan(nYears,nYears);
growthRates_yearByYear       = cell(nYears,nYears);
growthPredictions_yearByYear = cell(nYears,nYears);

for startYear = 1 : nYears
   
   % Compute growth prediction
   trophicDepths              = trophicDepths_overTime(:,startYear);
   Delta_t                    = startYear;
   gammaTwiddles_soFar        = sum(gammaTwiddles_overTime(:,1:startYear), 2) / Delta_t;
   gammaTwiddles_time_Ave_BAR = nanmean( gammaTwiddles_soFar )
   
   growthPredictions          = gammaTwiddles_time_Ave_BAR * trophicDepths;

   for endYear = startYear+1 : nYears
      
      % Compute average growth rate over this period
      Delta_t       = endYear - startYear;
      growthRates   = sum(growthRates_overTime(:,startYear+1:endYear), 2) / Delta_t;
      gammaTwiddles = sum(gammaTwiddles_overTime(:,startYear+1:endYear), 2) / Delta_t;
      
      % Store for later plotting
      trophicDepths_byYear{startYear}                 = trophicDepths;
      growthRates_yearByYear{startYear,endYear}       = growthRates;
      growthPredictions_yearByYear{startYear,endYear} = growthPredictions;
      
      % Compute prediction error
      mask       = ~isnan(growthRates) & ~isnan(growthPredictions);
      nCountries = nnz(mask);
      RMSError   = sqrt( nansum((growthRates - growthPredictions).^2) / nCountries );
      RMSErrorMatrix(startYear,endYear) = RMSError;
      
   end
   
end


%========================================================================%
% Plot
%========================================================================%
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Predictions for different horizons
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Additional or customized appearance parameters
xLim            = [2.15 4.2];
yLim            = [-3.3 12.5];
xTick           = [2.5:0.5:4];
yTick           = [-3:3:12];
startYearToPlot = 1;
horizonsToPlot  = [1 10];

xTimeLabel      = 2.25;
yTimeLabel      = 11;
fontSize        = 16;

axesX0          = 1.05;
axesY0          = 2.30;
axesWidth       = 3.5;
axesHeight      = axesWidth / 1.33333;


% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 980   400])

% Plot
iHorizon = 0;
for endYear = startYearToPlot + horizonsToPlot
   iHorizon         = iHorizon+1;
   trophicDepths    = trophicDepths_byYear{startYearToPlot};
   growthRates      = growthRates_yearByYear{startYearToPlot,endYear};
   growthPredictions = growthPredictions_yearByYear{startYearToPlot,endYear};

   % Setup axes
   axes('Units','inches', 'Position',[axesX0+(iHorizon-1)*axesWidth    axesY0   axesWidth    axesHeight])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

   % Plot
   hold on
   for c = 1:length(trophicDepths)
      plot( trophicDepths(c)*[1 1], [growthPredictions(c) growthRates(c)], 'k-')
   end
   hPrediction = plot(trophicDepths, growthPredictions, 'k-', 'LineWidth',2);
   hData       = plot(trophicDepths, growthRates, '.', 'MarkerSize',28, 'Color',ap.moneyColor);
   hold off
   
   % Time label
   if iHorizon == 1
      text(xTimeLabel,yTimeLabel, ['T = ',num2str(endYear-startYearToPlot), ' year'], 'FontSize',fontSize)
   else
      text(xTimeLabel,yTimeLabel, ['T = ',num2str(endYear-startYearToPlot), ' years'], 'FontSize',fontSize)
   end
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim)
   set(gca, 'XTick',xTick)
   set(gca, 'YTick',yTick)
   consistentTickPrecision(gca,'x',1)
   set(gca, 'FontSize',fontSize)
   xlabel( {'Ave. output multiplier in 1995'})
   
   % Y labels
   if iHorizon == 1
      ylabel({'Growth rate real GDP per', 'hour 1995-2009 (% yr^{-1})'})
   end
   if iHorizon ~= 1
      set(gca, 'YTickLabel',[])
   end
   
   % Legend
   if iHorizon ~= 1
      hLegend = legend([hData hPrediction], 'growth rate', 'forecast', 'Location','NorthEast');
      set(hLegend, 'Box','off', 'FontSize',fontSize)
   end
end



%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Prediction error vs. horizon
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
xLim             = [1 15];
yLim             = [0 5];
xAxes            = 9.4;
yAxes            = axesY0;
axesWidth        = 4;
axesHeight       = axesHeight;
startYearsToPlot = [1 3 6];
lineColor        = 'k';
lineStyles       = {'-','--','-.'};

% Setup axes
axes('Units','inches', 'Position',[xAxes    yAxes    axesWidth    axesHeight])

% Plot
hold on
iLine = 0;
forecastLineHandles = [];
for startYear = startYearsToPlot
   iLine = iLine + 1;
   horizonList = [1 : nYears - startYear];
   hPlot = plot(horizonList, RMSErrorMatrix(startYear, startYear+1:end), lineStyles{iLine}, 'Color',lineColor, 'LineWidth',2);
   forecastLineHandles = [forecastLineHandles hPlot];
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'FontSize',fontSize)
xlabel('Forecasting horizon T (years)')
ylabel({'RMS prediction', 'error (% yr^{-1})'})

% Legend
nYearsPlotted  = length(startYearsToPlot);
startYearNames = cell(nYearsPlotted, 1);
for iYear = 1:nYearsPlotted
   startYearNames{iYear} = ['t = ',num2str(1995 + startYearsToPlot(iYear) - 1)];
end
hLegend = legend(forecastLineHandles, startYearNames);
set(hLegend, 'Box','off', 'FontSize',fontSize)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'growthForecast_byHorizon';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end