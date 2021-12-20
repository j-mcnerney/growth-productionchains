function plotDistributionReturnContributions()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp


%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
n = WorldEconomy(1).n;
realReturns    = returnStats.realReturns_timeAve;

% Grab gammas, returns, and IO table for some year
iYear         = 1;
A             = WorldEconomy(iYear).A;
I             = eye(n);

% Remove industries whose price returns are NaNs
hasReturn       = ~isnan(realReturns);
hasExpenditures = (WorldEconomy(iYear).Mout' > 0);  % Note: Mout is slighly different from totalExpendvec. The former is computed in computeInputCoefficients.
mask            = hasReturn & hasExpenditures;
rvec_mod        = realReturns(mask);
A_mod           = A(mask,mask);
I_mod           = I(mask,mask);
H_mod           = inv(I_mod - A_mod');
gammavec_mod    = -(I_mod - A_mod') * rvec_mod;

% Compute the returns from the gammas
rvec_fromGammas_mod   = -H_mod * gammavec_mod;

% Distribution of magnitudes of local and non-local contributions
% Compute non-local fraction of price reductions
gammaContribution_mod = -gammavec_mod;
sigmaContribution_mod = A_mod' * rvec_fromGammas_mod;

% Restore to full vector size
gammaContribution       = nan(WorldEconomy(1).n,1);
sigmaContribution       = nan(WorldEconomy(1).n,1);
gammaContribution(mask) = gammaContribution_mod;
sigmaContribution(mask) = sigmaContribution_mod;

% Compute distributions of local and non-local contributions
edges = linspace(-10.5,5.5,30);
[xdirect_hist,  fdirect_hist]   = getpdf(gammaContribution * 100,edges);
[xindirect_hist,findirect_hist] = getpdf(sigmaContribution * 100,edges);

[fdirect,   xdirect]   = ksdensity(gammaContribution * 100);
[findirect, xindirect] = ksdensity(sigmaContribution * 100);

% Compute mean contributions
meanDirectContribution   = nanmean(gammaContribution * 100);
meanIndirectContribution = nanmean(sigmaContribution * 100);
dispc(meanDirectContribution)
dispc(meanIndirectContribution)

% Compute mean percent contributions for the average industry
percentGamma     = gammaContribution ./ (gammaContribution + sigmaContribution) * 100;
percentSigma     = sigmaContribution ./ (gammaContribution + sigmaContribution) * 100;
meanPercentGamma = nanmean(percentGamma);
meanPercentSigma = nanmean(percentSigma);
dispc(' ')
dispc( meanPercentGamma )
dispc( meanPercentSigma )
dispc('Note: These means are hard to intepreted because the gamma and sigma terms do not always have the same sign')

% Compute fraction of industries for which inherited component exceeds
% direct
percentage_inheritedMoreNegativeThanDirect = nnz(sigmaContribution < gammaContribution) / n * 100;
dispc(' ')
dispc( percentage_inheritedMoreNegativeThanDirect )

% Pick out some particular industries in which to study the two components
%iList = 221, 1359, 680;
%'Tex''Rub''Elc''Tpt''Pst'
countryCode  = 'CHN';
isCountry    = strcmp(WorldEconomy(1).countryCodesFull, countryCode);
industryCode = 'Elc';
isIndustry   = strcmp(WorldEconomy(1).industryCodesFull, industryCode);
i            = find(isCountry & isIndustry)


dispc(WorldEconomy(1).industryNamesFull(i))
dispc(WorldEconomy(1).countryCodesFull(i))
dispc( ['Total price reduction  = ',num2str(realReturns(i))] )
dispc( ['Direct contribution    = ',num2str(gammaContribution(i))] )
dispc( ['Inherited contribution = ',num2str(sigmaContribution(i))] )
dispc( ['Percent direct         = ',num2str(percentGamma(i))] )
dispc( ['Percent inherited      = ',num2str(percentSigma(i))] )


%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim  = [-10 5];
yLim  = [0 0.5];
xTick = [-10 : 2 : 5];
directColor   = [0 0.4470 0.7410];
indirectColor = [0.8500 0.3250 0.0980];

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 543   420])
%set(gca, 'Position',[0.15    0.15    0.7    0.7])

% Setup axes
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
hDirect    = plot(xdirect_hist, fdirect_hist, '-', 'LineWidth',2, 'Marker','o', 'MarkerSize',7, 'MarkerFaceColor',directColor);
hInherited = plot(xindirect_hist, findirect_hist, '-', 'LineWidth',2, 'Marker','^', 'MarkerSize',7, 'MarkerFaceColor',indirectColor);
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'XTick',xTick)
set(gca, 'YTickLabel',[])
set(gca, 'FontSize',ap.fontSize)
xlabel('Contribution to real price change (% yr^{-1})')
ylabel('Probability density')

% Legend
hLegend = legend([hDirect hInherited], 'Direct component','Inherited component', 'Location', 'NorthWest');
set(hLegend, 'Box','off', 'FontSize',ap.fontSize)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName = 'Direct_v_indirect_contributions';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end
