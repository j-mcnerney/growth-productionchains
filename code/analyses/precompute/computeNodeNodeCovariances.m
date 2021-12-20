function covarianceStats = computeNodeNodeCovariances(returnStats,gammaStats)
% Computes covariances and correlations between changes at each node for
% prices and improvement rates.

disp('Computing price change time-covariances...')

% Get price returns and improvement rates
realReturns_overTime    = returnStats.realReturns_overTime;
gammaEstimates_overTime = gammaStats.gammaEstimates_overTime;

% Compute correlations, covariances, and cross moments
returnCorrelations = corrcoef(realReturns_overTime',    'rows','pairwise');
gammaCorrelations  = corrcoef(gammaEstimates_overTime', 'rows','pairwise');

returnCovariances  = cov(realReturns_overTime',    'partialrows');
gammaCovariances   = cov(gammaEstimates_overTime', 'partialrows');

meanReturns = nanmean(realReturns_overTime,   2);
meanGammas  = nanmean(gammaEstimates_overTime,2);
meanReturnsProductsMatrix = meanReturns * meanReturns';
meanGammasProductsMatrix  = meanGammas  * meanGammas';
returnCrossMoments = returnCovariances + meanReturnsProductsMatrix; % The covariance is defined as Cov(X,Y) = E[X,Y] - E[X]*E[Y]; here we are adding back E[X]*E[Y] to obtain the cross-moment E[X,Y].
gammaCrossMoments  = gammaCovariances  + meanGammasProductsMatrix;

% Compute covariances and cross-moments for three periods of data
% Split data into three periods
breakYear1    = 1999;
breakYear2    = 2004;
period1       = [1995         : breakYear1];
period2       = [breakYear1+1 : breakYear2];
period3       = [breakYear2+1 : 2008      ];
years         = [1995:2011];
[~,I_period1] = ismember(period1,years);
[~,I_period2] = ismember(period2,years);
[~,I_period3] = ismember(period3,years);
gammaCovariances_period1 = cov(gammaEstimates_overTime(:,I_period1)', 'partialrows');
gammaCovariances_period2 = cov(gammaEstimates_overTime(:,I_period2)', 'partialrows');
gammaCovariances_period3 = cov(gammaEstimates_overTime(:,I_period3)', 'partialrows');


% Store
covarianceStats.returnCorrelations = returnCorrelations;
covarianceStats.gammaCorrelations  = gammaCorrelations;

covarianceStats.returnCovariances  = returnCovariances;
covarianceStats.gammaCovariances   = gammaCovariances;

covarianceStats.returnCrossMoments = returnCrossMoments;
covarianceStats.gammaCrossMoments  = gammaCrossMoments;

covarianceStats.gammaCovariances_period1 = gammaCovariances_period1;
covarianceStats.gammaCovariances_period2 = gammaCovariances_period2;
covarianceStats.gammaCovariances_period3 = gammaCovariances_period3;
