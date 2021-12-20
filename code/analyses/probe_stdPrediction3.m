function probe_stdPrediction3()
global ap pp

announceFunction()

% Additional or customized appearance parameters
xLim                 = [0.9 5];
yLim_returns         = [-0.40 0.40]*100;
yLim_stdevs          = [0 0.25]*100;
fadedDataColor       = [255 172 89]/255;
binAverageColor      = [127 49 0 100]/255;
binAverageMarkerSize = 20;
axesWidth            = 0.25;
axesHeight           = 0.2175;
axesX1               = 0.1000;
axesX2               = 0.43;
%axesX3               = axesX2 + axesWidth;
axesY0               = 0.7525;



% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 600*1.5   640])


% Loop over time horizons
iParamValue = 0;
diagStrengthList = [0.98, 0.5, 0.01];
for diagStrength = diagStrengthList
   
   %========================================================================%
   % Simulate model
   %========================================================================%
   % Simulate IO table
   n               = 1000;
   %diagStrength    = 0.9;
   Lmax            = 4.5;
   A               = makeIOtable(n, diagStrength, Lmax);
   
   % Compute Leontief inverse and trophic levels
   I = eye(n);
   H = inv(I - A);
   trophicLevels = H' * ones(n,1);
   
   %0.01 0.01
   %0.01 0.00
   % Simulate productivity changes
   mu            = -0.0038 + 0.0049 * trophicLevels;
   sigmaGammaVec = 0.0097 + 0.0046 * trophicLevels; %0.01 0.02 works well
   gammaVec      = normrnd(mu, sigmaGammaVec, [n 1]);
   
   % Simulate price changes
   priceReturns = -gammaVec' * H;
   
   
   %========================================================================%
   % Analyze artificial data
   %========================================================================%
   % Change units to percentages
   priceReturns = priceReturns * 100;
   gammaVec     = gammaVec * 100;
   
   % Bin data by trophic level and get stats for each bin
   binEdges      = equalCountBinning(trophicLevels, 25);
   binStats      = binDataBy(priceReturns',trophicLevels,binEdges);
   binMeanTL     = binStats.Xmean;
   binMeanReturn = binStats.Ymean;
   binStdReturn  = binStats.Ystd;
   
   % Calculate sigma_direct for each bin
   binStatsGammas = binDataBy(gammaVec',trophicLevels,binEdges);
   binStdGamma    = binStatsGammas.Ystd;
   
   % Linear fit, get constant and linear term
   LM         = fitlm(binMeanTL,binStdGamma);
   beta       = LM.Coefficients{:,1};
   muhat      = beta(1)
   TLcoeffhat = beta(2)
   
   % Compose linear model of sigma_direct
   sigma_direct = muhat + TLcoeffhat * binMeanTL;
   
   % Calculate sigma_inherited for each bin
   Z = (H - I) * inv(diag(trophicLevels - 1)); %check: columns of Z sum to 1
   method = 'analytical2';
   switch method
      case 'original'
         % Compute sigma_inherited as though st. dev. were not conditioned
         % on OM. This calc does not hold OM fixed!
         sigma_inherited = std(gammaVec' * Z);
         
      case 'binning'
         % Bin gammaVec * Z by trophic level, get Ystd in each bin
         binStatsGammaZ  = binDataBy(gammaVec' * Z,trophicLevels,binEdges);
         sigma_inherited = binStatsGammaZ.Ystd;
         
      case 'analytical'
         % Factor out the effect of the OMs from gammaVec, assuming it
         % linearly affects the gammas.  Do this to get a "bare" value
         % gamma0.  Then compute std of the bare value  across -all-
         % industries.  This might be (i) closest to the analytical
         % approach, and (ii) allow a more accurate calculation of
         % sigma_inherited by using all industries to compute its value.
         gammaVec0 = gammaVec ./ trophicLevels;  %Don't divide; de-trend with a regression
         sigma_inherited0 = std(gammaVec0' * Z);
         sigma_inherited  = sigma_inherited0 * binMeanTL;
         
      case 'analytical2'
         % Calculate sigma_gammaZ for each bin
         binStatsGammasZ = binDataBy(gammaVec' * Z,trophicLevels,binEdges);
         sigma_gammaZ    = binStatsGammasZ.Ystd;
         
         % Linear fit, get constant and linear term
         LM            = fitlm(binMeanTL,sigma_gammaZ);
         beta          = LM.Coefficients{:,1};
         muhat_gZ      = beta(1)
         TLcoeffhat_gZ = beta(2)
         
         % Compose model of sigma_direct
         sigma_inherited = muhat_gZ + TLcoeffhat_gZ * binMeanTL;
   end
   
   
%    c = cov(gammaVec,Z'*gammaVec)
%    figure(8)
%    seematrix(Z)
%    pause
%    
%    binStdGamma
%    sigma_inherited

   % Compute prediction for standard deviation
   rho = corr(gammaVec,Z'*gammaVec);
   sigma_predicted           = sigma_direct + rho * sigma_inherited .* (binMeanTL - 1);
   
   sigma_predicted_inherited = rho * sigma_inherited .* (binMeanTL - 1);
   
   % Compute prediction for price change expectation value
   trophicLevelRange = [1 : 0.1 : 4.5];
   gammaBar          = nanmean(gammaVec);
   returns_predicted = -gammaBar * trophicLevelRange;
   
   % Display results
   disp(' ')
   dispc(diagStrength)
   rho
   sigma_inherited
   binStdGamma
   
   
   %========================================================================%
   % Plot price changes
   %========================================================================%
   % Setup axes
   iParamValue  = iParamValue + 1;
   nParamValues = length(diagStrengthList);
   axesY     = axesY0 - (iParamValue-1)*axesHeight;
   axes('Position',[axesX1    axesY    axesWidth    axesHeight])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   plot([-1 5.5],[0 0],'k-')
   hReturns  = plot(trophicLevels, priceReturns, '.',  'Color',fadedDataColor, 'MarkerSize',ap.markerSize);
   hBinMeans = plot(binMeanTL, binMeanReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
   hTheory   = plot(trophicLevelRange, returns_predicted, 'k-');
   hold off
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim_returns)
   set(gca, 'YTick',[-25,0,25])
   %consistentTickPrecision(gca,'x',1)
   %consistentTickPrecision(gca,'y',1)
   set(gca, 'FontSize',ap.fontSize)
   %xlabel('Output multiplier')
   %ylabel('Price return (% yr^{-1})')
   if iParamValue < nParamValues
      set(gca, 'XTickLabel',[])
   end
   set(gca, 'FontSize',ap.fontSize)
   
   % X axis label
   if iParamValue == nParamValues
      xlabel('Output multiplier')
   end
   
   % Y axis label
   if iParamValue == 2
      ylabel('Price return (% yr^{-1})')
   end
   
   % Parameter value label
%    if iParamValue == 1
%       text(1.1,0.9*(yLim_returns(2)-yLim_returns(1)) + yLim_returns(1),['diagonal strength: ',num2str(diagStrength)], 'FontSize',ap.fontSize)
%    else
%       text(1.1,0.9*(yLim_returns(2)-yLim_returns(1)) + yLim_returns(1),['diagonal strength: ',num2str(diagStrength)], 'FontSize',ap.fontSize)
%    end
   
   % Title
   if iParamValue == 1
      title('$$E[r|\mathcal{L}]$$','interpreter','latex')
   end
   
   % Legend
   if iParamValue == nParamValues
      hLegend = legend([hBinMeans,hTheory],'bin average','theory', 'Location','NorthEast');
      set(hLegend, 'FontSize',ap.fontSize-1, 'Box','off')%, 'Position',[0.2091    0.2650    0.1642    0.0477])
   end
   
   %========================================================================%
   % Standard deviation of price changes across industries
   %========================================================================%
   % Setup axes
   axesY = axesY0 - (iParamValue-1)*axesHeight;
   axes('Position',[axesX2    axesY    axesWidth    axesHeight])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   plot([-1 5.5],[0 0],'k-')
   hBinMeans          = plot(binMeanTL, binStdReturn, '.', 'MarkerSize',binAverageMarkerSize, 'Color',binAverageColor(1:3));
   hTheory            = plot(binMeanTL, sigma_predicted, 'k-');
   hStdInherited      = plot(binMeanTL, binStdReturn - binStdGamma, 'ro');
   plot(binMeanTL, sigma_predicted_inherited, 'r-')
   hStdIneritedNormed = plot(binMeanTL, (binStdReturn - binStdGamma)./sigma_inherited, 'mh');
   plot(binMeanTL, binMeanTL - 1, 'm-')
   hold off
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim_stdevs)
   set(gca, 'YTick',[0,5,15,25])
   %set(gca, 'YScale','log')
   %consistentTickPrecision(gca,'x',1)
   %consistentTickPrecision(gca,'y',1)
   set(gca, 'FontSize',ap.fontSize)
   %xlabel('Output multiplier')
   %ylabel('$$\sigma_{r|\mathcal{L}}$$','interpreter','latex')
   %title(['diagonal strength: ',num2str(diagStrength)])
   if iParamValue < nParamValues
      set(gca, 'XTickLabel',[])
   end
   set(gca, 'FontSize',ap.fontSize)
   
   % X axis label
   if iParamValue == nParamValues
      xlabel('Output multiplier')
   end
   
   % Y axis label
   if iParamValue == 2
      ylabel('St. dev. of price return (% yr^{-1})')
   end
   
   % Y axis tick labels
   if iParamValue ~= 1
      set(gca, 'YTick', [0,5,15])
   end
   
   % Parameter value label
   text(1.1,0.8*(yLim_stdevs(2)-yLim_stdevs(1)) + yLim_stdevs(1),[{'diagonal'},{'strength: '},num2str(diagStrength)], 'FontSize',ap.fontSize)

   % sigma_gammaInherited label
   X = 2.5;
   sigma_predicted_atX = binStdGamma + sigma_inherited * (X - 1) * 100;
   %text(X, 2 + sigma_predicted_atX,['slope = ',num2str(sigma_gammaInherited * 100,'%3.2f'),'% yr^{-1}'], 'FontSize',ap.fontSize)
   
   
   % Title
   if iParamValue == 1
      title('$$\sigma_{r|\mathcal{L}}$$','interpreter','latex')
   end
   
   % Legend
   if iParamValue == nParamValues
      %hLegend = legend([hBinMeans,hTheory],'bin stan. dev.','theory', 'Location','NorthEast');
      %set(hLegend, 'FontSize',ap.fontSize-1, 'Box','off')%, 'Position',[0.5262    0.2650    0.1792    0.0477])
      hLegend = legend([hBinMeans,hStdInherited,hStdIneritedNormed], 'Return std. dev.','Inh. std. dev.','Inh. norm. std. dev.', 'Location','NorthEast');
      set(hLegend, 'FontSize',ap.fontSize-1, 'Box','off')%, 'Position',[0.5262    0.2650    0.1792    0.0477])
   end
   
end


% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = ['Returns_v_OMs_changeDiagonals'];
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   set(h, 'PaperPosition', [-0.2 1.0556 12.5000 8.8889])
   save_image(h, fileName, savemode)
end


end


function A = makeIOtable(n, diagStrength, Lmax)
% Generate output multipliers
outputMultipliers = ones(n,1) + (Lmax - 1)*rand(n,1);

% Make initial "Leontief inverse" matrix
H_diag    = diag(outputMultipliers-1);
H_offDiag = rand(n,n);
H_offDiag = H_offDiag - diag(diag(H_offDiag));     %set diagonal elements to zero
H_offDiag = H_offDiag * inv(diag(sum(H_offDiag))); %normalize column sums to 1
H_offDiag = H_offDiag * diag(outputMultipliers-1);              %normalize column sums to Lvec - 1
I         = eye(n);
H         = I + diagStrength*H_diag + (1 - diagStrength)*H_offDiag;
%check: [Lvec'; sum(H)]

% Derive and correct implied I-O table
A          = I - inv(H);
A(A<0)     = 0;         %set negative elements to zero
end