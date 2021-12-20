function plotCombinedReturnPrediction_byTimeHorizon4()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp


%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
trophicLevels        = trophicStats.trophicLevels_overTime(:,1);
realReturns_overTime = returnStats.realReturns_overTime;
gammas_overTime      = gammaStats.gammaEstimates_overTime;

% Change units to percent per year
realReturns_overTime = realReturns_overTime * 100;
gammas_overTime      = gammas_overTime * 100;

%========================================================================%
% Plot loop
%========================================================================%
% Additional or customized appearance parameters
xLim                 = [0.9 5];

fadedDataColor       = [255 172 89]/255;
binAverageColor      = [127 49 0]/255;
markerFaceColor      = fadedDataColor;
markerEdgeColor      = fadedDataColor;

markerSize           = 11;
binAverageMarkerSize = 20;
markerStyle          = '.';

axesWidth            = 0.25;
axesHeight           = 0.2175;
axesX1               = 0.1000;
axesX2               = 0.43;
axesX3               = axesX2 + axesWidth;
axesY0               = 0.74;

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 600*1.5   640])

% Loop over time horizons
iHorizon = 0;
iPlot    = 0;
horizonList            = [1:8];
horizonsToPlot         = [1,2,4,8];
nBins                  = 25;
stdReturn_list         = zeros(length(horizonList),1);
errorIn_StdReturn_list = zeros(length(horizonList),1);
binMeanTL_list         = zeros(length(horizonList),nBins);
binStdReturn_list      = zeros(length(horizonList),nBins);
for Delta_t = horizonList
   iHorizon  = iHorizon + 1;
   
   % Compute ave. rates of change over this time horizon
   priceReturns = sum(realReturns_overTime(:,1:Delta_t), 2) / Delta_t;
   gammaVec     = sum(gammas_overTime(:,1:Delta_t), 2) / Delta_t;
   
   % Compute standard deviation across all industries
   stdReturn                = nanstd( priceReturns );
   stdReturn_list(iHorizon) = stdReturn;
   
   % Compute error bars around standard deviation estimates
   % Note: The standard error of standard deviation is
   %   SE(sigma) = sigma / sqrt(2N-2)
   % Source: https://pdfs.semanticscholar.org/ba2b/131bc7b442c3f7f4641339f3549f69b15a9b.pdf
   numReturns                       = nnz(~isnan(priceReturns));
   errorIn_StdReturn                = stdReturn ./ sqrt(2*numReturns - 2);
   errorIn_StdReturn_list(iHorizon) = errorIn_StdReturn;
   
   % Bin data by trophic level and get stats for each bin
   binEdges      = equalCountBinning(trophicLevels, nBins);
   binStats      = binDataBy(priceReturns',trophicLevels,binEdges);
   binMeanTL     = binStats.Xmean;
   binMeanReturn = binStats.Ymean;
   binStdReturn  = binStats.Ystd;
   binStdOfMeanReturn = binStdReturn ./ sqrt(binStats.count);
   
   binMeanTL_list(iHorizon,:)    = binMeanTL;
   binStdReturn_list(iHorizon,:) = binStdReturn;
   
   % Compute error bars around standard deviation estimates
   % Note: The standard error of standard deviation is
   %   SE(sigma) = sigma / sqrt(2N-2)
   % Source: https://pdfs.semanticscholar.org/ba2b/131bc7b442c3f7f4641339f3549f69b15a9b.pdf
   binErrorIn_StdReturn = binStdReturn ./ sqrt(2*binStats.count - 2);
   binErrorIn_StdReturn(binStats.count <= 1) = nan;
   
   % Linear fit of price changes st. dev.
   LM_returns         = fitlm(binMeanTL,binStdReturn);
   beta_returns       = LM_returns.Coefficients{:,1};
   muhat_returns      = beta_returns(1);
   TLcoeffhat_returns = beta_returns(2);
   
   % Calculate sigma_direct for each bin
   binStatsGammas = binDataBy(gammaVec',trophicLevels,binEdges);
   binStdGamma    = binStatsGammas.Ystd;
   
   % Linear fit of gamma st. dev.
   LM         = fitlm(binMeanTL,binStdGamma);
   beta       = LM.Coefficients{:,1};
   muhat      = beta(1);
   TLcoeffhat = beta(2);
   
   % Compose linear model of sigma_direct
   sigma_direct = muhat + TLcoeffhat * binMeanTL;
   
   % Calculate sigma_inherited for each bin
   % Estimate sigma_inherited, using the Leontief inverse from the first
   % year of the data
   iYear           = 1;
   H               = H_overTime{iYear};
   Mout            = WorldEconomy(1).Mout;
   mask            = ~isnan(gammaVec) & ~isnan(Mout') & (Mout' > 0) & (trophicLevels > 1);
   n_sub           = nnz(mask);
   I_sub           = eye(n_sub);
   H_sub           = H(mask,mask);
   AH_sub          = H_sub - I_sub;
   trophicLevels_sub = trophicLevels(mask);
   Z_sub           = AH_sub * inv(diag(trophicLevels_sub - 1)); %check: columns of Z sum to 1
   gammaVec_sub    = gammaVec(mask);

   
   % Calculate sigma_gammaZ for each bin
   binStatsGammasZ = binDataBy(gammaVec_sub' * Z_sub,trophicLevels_sub,binEdges);
   sigma_gammaZ    = binStatsGammasZ.Ystd;
   
   % Linear fit, get constant and linear term
   LM            = fitlm(binMeanTL,sigma_gammaZ);
   beta          = LM.Coefficients{:,1};
   muhat_gZ      = beta(1);
   TLcoeffhat_gZ = beta(2);
   
   % Compose model of sigma_inherited
   sigma_inherited = mean(sigma_gammaZ);% constant method
   
   % Compute prediction for standard deviation
   rho = corr(gammaVec_sub,Z_sub'*gammaVec_sub);
   sigma_predicted           = sigma_direct + rho * sigma_inherited .* (binMeanTL - 1) + 0.5*sigma_direct.*(sigma_inherited ./ sigma_direct).^2 .* (binMeanTL - 1).^2;
   sigma_predicted_inherited = rho * sigma_inherited .* (binMeanTL - 1) + 0.5*sigma_direct.*(sigma_inherited ./ sigma_direct).^2 .* (binMeanTL - 1).^2;
   
   
   % Compute prediction for price change expectation value
   trophicLevelRange = [1 : 0.1 : 4.5];
   gammaBar          = nanmean(gammaVec);
   returns_predicted = -gammaBar * trophicLevelRange;
   
   % Compute mean square prediction error for standard deviations
   meanSqPredErrorPerBin  = sum( (sigma_predicted*sqrt(Delta_t) - binStdReturn*sqrt(Delta_t)).^2 ) / nBins;
   RMSPredErrorPerBin     = sqrt(meanSqPredErrorPerBin);
   
   meanSqPredErrorPerBin_inherited  = sum( (sigma_predicted_inherited*sqrt(Delta_t) - (binStdReturn - binStdGamma)*sqrt(Delta_t)).^2 ) / nBins;
   RMSPredErrorPerBin_inherited     = sqrt(meanSqPredErrorPerBin_inherited);
   
   % Display results
   disp(' ')
   disp('------------------')
   dispc(Delta_t)
   dispc(rho)
   dispc(sigma_inherited)
   dispc(RMSPredErrorPerBin)
   dispc(RMSPredErrorPerBin_inherited)
   dispc(TLcoeffhat_returns)
   dispc(TLcoeffhat)
   
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   % Plot ave. returns
   %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
   if ismember(Delta_t,horizonsToPlot)
      iPlot = iPlot + 1;
      
      % Setup axes
      nHorizons = length(horizonsToPlot);
      axesY     = axesY0 - (iPlot-1)*axesHeight;
      axes('Position',[axesX1    axesY    axesWidth    axesHeight])
      set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
      
      % Plot
      hold on
      plot([-1 5.5],[0 0],'k-')
      hReturns    = plot(trophicLevels, priceReturns, markerStyle,  'Color',fadedDataColor, 'MarkerFaceColor',markerFaceColor, 'MarkerEdgeColor',markerEdgeColor, 'MarkerSize',markerSize);
      hTheory     = plot(trophicLevelRange, returns_predicted, 'k-');
      hBinMeans   = plot(binMeanTL, binMeanReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
      hBinErrors  = errorbar(binMeanTL, binMeanReturn, 2*binStdOfMeanReturn, 2*binStdOfMeanReturn);
      hold off
      set(hBinErrors, 'Color',binAverageColor, 'LineStyle','none', 'LineWidth',2)
      
      % Refine
      yLim = [-0.15 0.15]*100;
      set(gca, 'Box','on')
      set(gca, 'XLim',xLim)
      set(gca, 'YLim',yLim)
      set(gca, 'YTick',[-10,0,10])
      if iPlot < nHorizons
         set(gca, 'XTickLabel',[])
      end
      set(gca, 'FontSize',ap.fontSize)
      
      % X axis label
      if iPlot == nHorizons
         xlabel('Output multiplier in 1995')
      end
      
      % Y axis label
      if iPlot == 2
         ylabel('Real price change 1995-2009 (% yr^{-1})')
      end
      
      % Time horizon label
      if iPlot == 1
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' year'], 'FontSize',ap.fontSize)
      else
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' years'], 'FontSize',ap.fontSize)
      end
      
      % Title
      if iPlot == 1
         title('$$E[r|\mathcal{L}]$$','interpreter','latex')
      end
      
      % Legend
      if iPlot == nHorizons
         hLegend = legend([hBinMeans,hTheory],'bin average','theory', 'Location','NorthEast');
         set(hLegend, 'FontSize',ap.fontSize, 'Box','off', 'Position',[0.2091    0.255    0.1642    0.0477])
      end
      
      
      %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
      % Plot st. dev. of returns
      %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
      % Setup axes
      axesY = axesY0 - (iPlot-1)*axesHeight;
      axes('Position',[axesX2    axesY    axesWidth    axesHeight])
      set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
      
      % Plot
      hold on
      hBinMeans  = plot(binMeanTL, binStdReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
      hBinErrors = errorbar(binMeanTL, binStdReturn, 2*binErrorIn_StdReturn, 2*binErrorIn_StdReturn);
      hTheory    = plot(binMeanTL, sigma_predicted, '-', 'Color','k');
      hold off
      set(hBinErrors, 'Color',binAverageColor, 'LineStyle','none', 'LineWidth',2)
      
      % Refine
      yLim = [-0.0 0.26]*100;
      set(gca, 'Box','on')
      set(gca, 'XLim',xLim)
      set(gca, 'YLim',yLim)
      set(gca, 'YTick',[0,10,20])
      set(gca, 'FontSize',ap.fontSize)
      if iPlot < nHorizons
         set(gca, 'XTickLabel',[])
      end
      set(gca, 'FontSize',ap.fontSize)
      
      % X axis label
      if iPlot == nHorizons
         xlabel('Output multiplier in 1995')
      end
      
      % Y axis label
      if iPlot == 2
         ylabel('St. dev. of real price change 1995-2009 (% yr^{-1})')
      end
      
      % Time horizon label
      if iPlot == 1
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' year'], 'FontSize',ap.fontSize)
      else
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' years'], 'FontSize',ap.fontSize)
      end
      
      % Title
      if iPlot == 1
         title('$$\sigma_{r|\mathcal{L}}$$','interpreter','latex')
      end
      
      % Legend
      if iPlot == nHorizons
         hLegend = legend([hBinMeans,hTheory],'bin stan. dev.','theory', 'Location','SouthEast');
         set(hLegend, 'FontSize',ap.fontSize, 'Box','off', 'Position',[0.5195    0.2303    0.1792    0.0766])
      end
      
      
      
      %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
      % Plot time-scaled st. dev. of returns
      %=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
      % Setup axes
      axesY = axesY0 - (iPlot-1)*axesHeight;
      axes('Position',[axesX3    axesY    axesWidth    axesHeight])
      set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
      
      % Plot
      hold on
      hBinMeans  = plot(binMeanTL, binStdReturn*sqrt(Delta_t), '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
      hBinErrors = errorbar(binMeanTL, binStdReturn*sqrt(Delta_t), 2*binErrorIn_StdReturn*sqrt(Delta_t), 2*binErrorIn_StdReturn*sqrt(Delta_t));
      hTheory    = plot(binMeanTL, sigma_predicted*sqrt(Delta_t), '-', 'Color','k');
      hold off
      set(hBinErrors, 'Color',binAverageColor, 'LineStyle','none', 'LineWidth',2)
      
      % Refine
      set(gca, 'Box','on')
      set(gca, 'XLim',xLim)
      set(gca, 'YLim',yLim)
      set(gca, 'YTick',[0,10,20])
      set(gca, 'YTickLabel',[])
      set(gca, 'FontSize',ap.fontSize)
      if iPlot < nHorizons
         set(gca, 'XTickLabel',[])
      end
      set(gca, 'FontSize',ap.fontSize)
      
      % X axis label
      if iPlot == nHorizons
         xlabel('Output multiplier in 1995')
      end
      
      % Y axis label
      if iPlot == 2
         %ylabel('Time-adjusted st. dev. of real price return 1995-2009 (% yr^{-1})')
         %ylabel('St. dev. of real price return 1995-2009 (% yr^{-1})')
      end
      
      % Time horizon label
      if iPlot == 1
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' year'], 'FontSize',ap.fontSize)
      else
         text(1.1,0.9*(yLim(2)-yLim(1)) + yLim(1),['T = ',num2str(Delta_t),' years'], 'FontSize',ap.fontSize)
      end
      
      % Prediction error label
      text(1.1, 0.78*(yLim(2)-yLim(1)) + yLim(1), ['RMSPE = ',num2str(RMSPredErrorPerBin,'%3.2f')], 'FontSize',ap.fontSize)
      
      % Title
      if iPlot == 1
         title('$$\sigma_{r|\mathcal{L}} \cdot \sqrt{T}$$','interpreter','latex')
      end

   end % end if-statement whether to plot results of this time horizon
   
end

% Save
if pp.saveFigures
   h         = gcf;
   set(h, 'PaperSize',[15 11], 'PaperPosition',[0 1.0556 14.5000 8.8889])
   folder    = pp.figuresFolder;
   fileName  = ['Returns_v_OMs_TimeHorizon_full'];
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end


%========================================================================%
% Standard deviation versus time horizon
%========================================================================%
% Setup figure
newFigure( [mfilename,'.timeDependence'] )
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 584   249])

% Appearance parameters
xLim              = [0.9 8.8];
yLim              = [2 30];
dataThickness     = 1;
theoryThickness   = 2.5;
averageMarkerSize = 9;
dataLineColors    = brighten(copper(nBins), 0.5);
theoryColor       = binAverageColor;
theoryLabelFontSize = 24;

% Construct theoretical prediction
horizonList_theory = linspace(min(horizonList), max(horizonList), 50);
theoryLine = 11./sqrt(horizonList_theory);

% Plot
hold on
h_theory   = plot(horizonList_theory, theoryLine, 'k--','LineWidth',theoryThickness);
h_average  = plot(horizonList, stdReturn_list, 'o', 'LineWidth',theoryThickness, 'MarkerSize',averageMarkerSize, 'MarkerFaceColor',theoryColor, 'MarkerEdgeColor',theoryColor, 'Color',theoryColor);
hBinErrors = errorbar(horizonList, stdReturn_list, 2*errorIn_StdReturn_list, 2*errorIn_StdReturn_list);
hold off
set(hBinErrors, 'Color',binAverageColor, 'LineStyle','none', 'LineWidth',2)

% sqrt(T) label
text(1.3268,   13.1482, '$\frac{1}{\sqrt{T}}$', 'Interpreter','latex', 'fontSize',theoryLabelFontSize)

% Refine
set(gca, 'Box','on')
set(gca, 'XScale','log')
set(gca, 'YScale','log')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'YTick',[3,10,30])
set(gca, 'FontSize',ap.fontSize+2)
set(gca, 'FontSize',ap.fontSize+2)
xlabel('Time horizon T')
ylabel({'St. dev. of real','price change (% yr^{-1})'})

% Legend
h_legend = legend([h_average], 'ave. across output multiplier bins');
set(h_legend, 'Box','off', 'FontSize',ap.fontSize+2)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'StDev_v_timeHorizon';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end

