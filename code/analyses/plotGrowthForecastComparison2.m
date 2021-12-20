function countryValues = plotGrowthForecastComparison2()
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


% Measure correlation of gammaTwiddle and OM with future growth
% Note: We store the correlations in a matrix whose elements give
% correlations betwen each pair of start and end years, e.g.
%
%   corrGammaMatrix(t,s) 
%     = corr. of gamma in year t with ave. growth during years t thru s
%
% Essentially, using data in year t, we are making a prediction about
% growth from t until some future year.
correlationMeasure = 'Pearson';
nYears          = length(years) - 2;   %exclude 2010 and 2011
corrGammaMatrix = nan(nYears,nYears);
corrOMMatrix    = nan(nYears,nYears);
corrGammaMatrix_current = nan(nYears,nYears);
corrOMMatrix_current    = nan(nYears,nYears);
for startYear = 1 : nYears
   
   % Compute gammaTwiddles and OMs used to make predictions
   gammaTwiddles_firstYear = sum(gammaTwiddles_overTime(:,1:startYear), 2) / startYear;
   trophicDepths_firstYear = sum(trophicDepths_overTime(:,1:startYear), 2) / startYear;
   
   for endYear = startYear+1 : nYears
      
      % Compute average growth rate over this period
      Delta_t     = endYear - startYear;
      growthRates = sum(growthRates_overTime(:,startYear+1:endYear), 2) / Delta_t;
      
      % Get correlation of gammaTwiddle and OM with future growth
      mask = ~isnan(growthRates) & ~isnan(gammaTwiddles_firstYear);
      corrGammaMatrix(startYear,endYear) = corr(growthRates(mask), gammaTwiddles_firstYear(mask), 'type',correlationMeasure);
      corrOMMatrix(startYear,endYear)    = corr(growthRates(mask), trophicDepths_firstYear(mask), 'type',correlationMeasure);
      
      % Compute the average gammaTwiddles and trophic depths over this period
      gammaTwiddles = sum(gammaTwiddles_overTime(:,startYear+1:endYear), 2) / Delta_t;
      trophicDepths = sum(trophicDepths_overTime(:,startYear+1:endYear), 2) / Delta_t;
      
      % Get correlation of gammaTwiddle and OM with current growth
      mask = ~isnan(growthRates) & ~isnan(gammaTwiddles);
      corrGammaMatrix_current(startYear,endYear) = corr(growthRates(mask), gammaTwiddles(mask), 'type',correlationMeasure);
      corrOMMatrix_current(startYear,endYear)    = corr(growthRates(mask), trophicDepths(mask), 'type',correlationMeasure);
   end
   
end




%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
horizonLength           = 10;
xLim                    = [-0.5 horizonLength];
yLim                    = [-0.25 1];
xTick                   = [1:2:9];
yearFontSize            = 14;
fontSize                = 18;
gammaColor              = [0 0.447 0.741];
OMColor                 = [0.635 0.078 0.184];
lineWidth               = 1.5;
markerSize              = 8;
yearTextBackgroundColor = 'none';
yearTextMargin          = 0.1;

xYearNudge              = -1.3;

xtLabel                 = 0.1;
ytLabel_topLeft         = 0.92;
ytLabel_topRight        = 0.62;
ytLabel_botLeft         = 0.49;
ytLabel_botRight        = 0.62;

xTitle_gammma           = 6.5;
xTitle_OM               = 6.5;
yTitle                  = -0.;
yNudgeLatex             = 0.035;

axesX0                  = 1;
axesY0                  = 5;
axesWidth               = 4;
axesHeight              = 2.7;
horizSpacing            = 0.0;
verticalSpacing         = 0.0;


% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 920   570])


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Gamma-twiddle correlation (current growth)
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','inches', 'Position',[axesX0 axesY0 axesWidth axesHeight])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrGammaMatrix_current(startYear, startYear+1 : startYear+horizonLength);
   plot(horizonList,    corrList,  '-s',  'Color',gammaColor, 'MarkerFaceColor',gammaColor, 'MarkerEdgeColor','w', 'LineWidth',lineWidth, 'MarkerSize',markerSize)
end
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrGammaMatrix_current(startYear, startYear+1 : startYear+horizonLength);
   text(horizonList(1) + xYearNudge, corrList(1), num2str(1995+startYear-1),'FontSize',yearFontSize, 'BackgroundColor',yearTextBackgroundColor, 'Margin',yearTextMargin)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'XTickLabel',[])
set(gca, 'YTick',[0 : 0.5 : 1])
set(gca, 'FontSize',fontSize)

% Start year t label
text(xtLabel,ytLabel_topLeft,{'t'}, 'FontSize',fontSize)

% Title
xShift  = 0;

hLast   = text(xTitle_gammma+xShift,yTitle-yNudgeLatex,'$$\tilde{\gamma}$$', 'Interpreter','latex', 'FontSize',fontSize, 'VerticalAlignment','top');
lastPos = get(hLast, 'Extent');
xShift  = xShift + lastPos(3);

text(xTitle_gammma+xShift,yTitle,'_c(t,t+T)', 'FontSize',fontSize, 'VerticalAlignment','top')



%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Output multiplier correlation (current growth)
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','inches', 'Position',[axesX0+axesWidth+horizSpacing axesY0 axesWidth axesHeight])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrOMMatrix_current(startYear, startYear+1 : startYear+horizonLength);
   plot(horizonList,    corrList, '-s',   'Color',OMColor, 'MarkerFaceColor',OMColor, 'MarkerEdgeColor','w', 'LineWidth',lineWidth, 'MarkerSize',markerSize)
end
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrOMMatrix_current(startYear, startYear+1 : startYear+horizonLength);
   text(horizonList(1) + xYearNudge, corrList(1), num2str(1995+startYear-1), 'FontSize',yearFontSize, 'BackgroundColor',yearTextBackgroundColor, 'Margin',yearTextMargin)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'XTickLabel',[])
set(gca, 'YTickLabel',[])
set(gca, 'FontSize',fontSize)

% Start year t label
text(xtLabel,ytLabel_topRight,{'t'}, 'FontSize',fontSize)

% Title
xShift  = 0;
hLast   = text(xTitle_OM+xShift,yTitle-yNudgeLatex,'$$\bar{\mathcal{L}}$$', 'Interpreter','latex', 'FontSize',fontSize, 'VerticalAlignment','top');
lastPos = get(hLast, 'Extent');
xShift  = xShift + lastPos(3);
text(xTitle_OM+xShift,yTitle,'_c(t,t+T)', 'FontSize',fontSize, 'VerticalAlignment','top')


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Gamma-twiddle correlation (future growth)
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','inches', 'Position',[axesX0 axesY0-axesHeight-verticalSpacing axesWidth axesHeight])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrGammaMatrix(startYear, startYear+1 : startYear+horizonLength);
   plot(horizonList,    corrList,  '-s',  'Color',gammaColor, 'MarkerFaceColor',gammaColor, 'MarkerEdgeColor','w', 'LineWidth',lineWidth, 'MarkerSize',markerSize)
end
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrGammaMatrix(startYear, startYear+1 : startYear+horizonLength);
   text(horizonList(1) + xYearNudge, corrList(1), num2str(1995+startYear-1),'FontSize',yearFontSize, 'BackgroundColor',yearTextBackgroundColor, 'Margin',yearTextMargin)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'YTick',[0 : 0.5 : 1])
set(gca, 'FontSize',fontSize)
xlabel('Time horizon T (years)')
ylabel( [correlationMeasure,' correlation with g_c(t,t+T)'], 'Position',[-1.7 1] )

% Start year t label
text(xtLabel,ytLabel_botLeft,{'t'}, 'FontSize',fontSize)

% Title
xShift  = 0;
hLast   = text(xTitle_gammma+xShift,yTitle-yNudgeLatex,'$$\tilde{\gamma}$$', 'Interpreter','latex', 'FontSize',fontSize, 'VerticalAlignment','top');
lastPos = get(hLast, 'Extent');
xShift  = xShift + lastPos(3);
text(xTitle_gammma+xShift,yTitle,'_c(1995,t)', 'FontSize',fontSize, 'VerticalAlignment','top')


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Output multiplier correlation (future growth)
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','inches', 'Position',[axesX0+axesWidth+horizSpacing axesY0-axesHeight-verticalSpacing axesWidth axesHeight])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrOMMatrix(startYear, startYear+1 : startYear+horizonLength);
   plot(horizonList,    corrList, '-s',   'Color',OMColor, 'MarkerFaceColor',OMColor, 'MarkerEdgeColor','w', 'LineWidth',lineWidth, 'MarkerSize',markerSize)
end
for startYear = 1 : nYears - horizonLength
   horizonList = [1 : horizonLength];
   corrList    = corrOMMatrix(startYear, startYear+1 : startYear+horizonLength);
   text(horizonList(1) + xYearNudge, corrList(1), num2str(1995+startYear-1), 'FontSize',yearFontSize, 'BackgroundColor',yearTextBackgroundColor, 'Margin',yearTextMargin)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'YTickLabel',[])
set(gca, 'FontSize',fontSize)
xlabel('Time horizon T (years)')

% Start year t label
text(xtLabel,ytLabel_botRight,{'t'}, 'FontSize',fontSize)

% Title
xShift  = 0;
hLast   = text(xTitle_OM+xShift,yTitle-yNudgeLatex,'$$\bar{\mathcal{L}}$$', 'Interpreter','latex', 'FontSize',fontSize, 'VerticalAlignment','top');
lastPos = get(hLast, 'Extent');
xShift  = xShift + lastPos(3);
text(xTitle_OM+xShift,yTitle,'_c(1995,t)', 'FontSize',fontSize, 'VerticalAlignment','top')

% Memorize positions of labels
propertyName     = 'Type';
propertyValue    = 'Text';
matFileDirectory = ['save/objpos2_plotGrowthForecastComparison2'];
memorizeObjPositions(gcf, 'set', propertyName, propertyValue, matFileDirectory)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'growthForecastComparison';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
