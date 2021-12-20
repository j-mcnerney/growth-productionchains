function regressIndustryDummies_and_OMs()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp



%========================================================================%
% Preprocessing
%========================================================================%
announceFunction()

% Unpack data
nIndustryTypes    = WorldEconomy(1).nIndustries;
nCountries        = WorldEconomy(1).nCountries;

% Choose the returns and output multiplier data to compare
dataSelection = 'first_v_ave';
switch dataSelection
   case 'first_v_ave'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      priceReturns  = returnStats.realReturns_timeAve;
   case 'first_v_yearly'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1);
      priceReturns  = returnStats.realReturns_overTime;
   case 'yearly_v_yearly'
      trophicLevels = trophicStats.trophicLevels_overTime(:,1:end-1);   % lop-off last year since there are always 1 fewer return measurements than trophic level measurements
      priceReturns  = returnStats.realReturns_overTime;
   case 'ave_v_ave'
      trophicLevels = trophicStats.trophicLevels_timeAve;
      priceReturns  = returnStats.realReturns_timeAve;
   case 'ave_v_yearly'
      trophicLevels = trophicStats.trophicLevels_timeAve;
      priceReturns  = returnStats.realReturns_overTime;
   otherwise
      error('plotReturns_v_trophicLevels_byIndustryType2: unrecognized option.')
end


% Construct logical vectors indicating for each industry whether it is
% agriculture, manufactuing, or service
agriculture     = [1,3];
manufacturing   = [2,4:18];
services        = [19:35];
isAgriculture   = false(nIndustryTypes,1);
isManufacturing = false(nIndustryTypes,1);
isServices      = false(nIndustryTypes,1);
isAgriculture(agriculture)     = true;
isManufacturing(manufacturing) = true;
isServices(services)           = true;
isAgriculture   = repmat(isAgriculture,   [nCountries 1]);
isManufacturing = repmat(isManufacturing, [nCountries 1]);
isServices      = repmat(isServices,      [nCountries 1]);

% Construct logical vectors indicating whether each industry belongs to
% each of the 35 industry types in the WIOD data
isIndustryType = eye( nIndustryTypes );
isIndustryType = repmat( isIndustryType, [nCountries 1]);


%=====================================================================%
% Regression 1: just agriculture, manufacturing, services dummies
%=====================================================================%
% Fit
%
%   ri = b1 * Ai + b2 * Mi + b3 * Si + b4 * Li
%
% where Mi, Si, and Ai are dummy variables indicating a manufacturing,
% service, or agriculture industry and Li is the output multiplier.
Y = priceReturns;
X = [isAgriculture isManufacturing isServices];
nVars = size(X,2);

% Setup model without intercept
% Note: The regression matrix would lack full rank if all dummy variables
% and the constant term were present, because the ones vector is a linear
% combination of the dummy vectors.  Setting the 'model' input for the
% regstats below to the identity matrix specifies that the variables to
% include are each of the columns of X raised to the first power (and no
% others).
model    = eye( nVars );
fitStats = regstats(Y, X, model);
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
nData    = size(fitStats.yhat,1);

% Collect results for regression table
beta_agriculture   = beta(1);
beta_manufacturing = beta(2);
beta_services      = beta(3);
pval_agriculture   = pvals(1);
pval_manufacturing = pvals(2);
pval_services      = pvals(3);
test1Column = {
   ''
   ''
   num2str( beta_agriculture, '%4.3f')
   scientificnotation( pval_agriculture )
   num2str( beta_manufacturing, '%4.3f')
   scientificnotation( pval_manufacturing )
   num2str( beta_services, '%4.3f')
   scientificnotation( pval_services )
   ''
   ''
   num2str(R2, '%4.3f')
   num2str(nData)
   };


%=====================================================================%
% Regression 2: just output multiplier
%=====================================================================%
% Fit
%
%   ri = b0 + b1 * Li
%
% where Mi, Si, and Ai are dummy variables indicating a manufacturing,
% service, or agriculture industry and Li is the output multiplier.
Y = priceReturns;
X = [trophicLevels];
nVars = size(X,2);
fitStats = regstats(Y, X, 'linear');
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
nData    = size(fitStats.yhat,1);

% Collect results for regression table
beta_const         = beta(1);
beta_OMS           = beta(2);
pval_const         = pvals(1);
pval_OMS           = pvals(2);
test2Column = {
   num2str( beta_OMS, '%4.3f')
   scientificnotation( pval_OMS )
   ''
   ''
   ''
   ''
   ''
   ''
   num2str( beta_const, '%4.3f')
   scientificnotation( pval_const )
   num2str(R2, '%4.3f')
   num2str(nData)
   };


%=====================================================================%
% Regression 3: agric./manu./services dummies and output multiplier
%=====================================================================%
% Fit
%
%   ri = b1 * Ai + b2 * Mi + b3 * Si + b4 * Li
%
% where Mi, Si, and Ai are dummy variables indicating a manufacturing,
% service, or agriculture industry and Li is the output multiplier.
Y = priceReturns;
X = [isAgriculture isManufacturing isServices trophicLevels];
nVars = size(X,2);

% Setup model without intercept
% Note: The regression matrix would lack full rank if all dummy variables
% and the constant term were present, because the ones vector is a linear
% combination of the dummy vectors.  Setting the 'model' input for the
% regstats below to the identity matrix specifies that the variables to
% include are each of the columns of X raised to the first power (and no
% others).
model    = eye( nVars );
fitStats = regstats(Y, X, model);
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
nData    = size(fitStats.yhat,1);

% Collect results for regression table
beta_agriculture   = beta(1);
beta_manufacturing = beta(2);
beta_services      = beta(3);
beta_OMS           = beta(4);
pval_agriculture   = pvals(1);
pval_manufacturing = pvals(2);
pval_services      = pvals(3);
pval_OMS           = pvals(4);
test3Column = {
   num2str( beta_OMS, '%4.3f')
   scientificnotation( pval_OMS )
   num2str( beta_agriculture, '%4.3f')
   scientificnotation( pval_agriculture )
   num2str( beta_manufacturing, '%4.3f')
   scientificnotation( pval_manufacturing )
   num2str( beta_services, '%4.3f')
   scientificnotation( pval_services )
   ''
   ''
   num2str(R2, '%4.3f')
   num2str(nData)
   };



%=====================================================================%
% Regression 4: specific industry dummies
%=====================================================================%
% Fit
%
%   ri = sum_j bj*Dij + b*Li
%
% where Dij is dummy variable indicating that industry i is of industry
% label j.
Y = priceReturns;
X = [isIndustryType trophicLevels];
nVars = size(X,2);

% Setup model without intercept
% Note: The regression matrix would lack full rank if all dummy variables
% and the constant term were present, because the ones vector is a linear
% combination of the dummy vectors.  Setting the 'model' input for the
% regstats below to the identity matrix specifies that the variables to
% include are each of the columns of X raised to the first power (and no
% others).
model    = eye( nVars );
fitStats = regstats(Y, X, model);
beta     = fitStats.beta;
R2       = fitStats.rsquare;
stdErr   = fitStats.tstat.se;
tvals    = fitStats.tstat.t;
pvals    = fitStats.tstat.pval;
CIs      = [beta-2*stdErr beta+2*stdErr];
nData    = size(fitStats.yhat,1);

dispc('Coefficients and p-values for industry categories:')
table(beta,pvals)


% Output latex table of results
% Construct latex table of regression results
resultsCell = [test1Column test2Column test3Column];
headerCell  = {'(1)','(2)','(3)'};
rowCell     = {'Output multipliers','', 'Agriculture','', 'Manufacturing','', 'Services','', 'Constant','', '$R^2$', '$n$'};
disp(' ')
printLatexTable(resultsCell,headerCell,rowCell)
