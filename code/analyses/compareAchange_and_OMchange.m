function compareAchange_and_OMchange()
% This file studies the relationships between change in the output
% multipliers and change in input coefficients.

global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

announceFunction()

%========================================================================%
% Load data
%========================================================================%
% Unpack data
n                 = WorldEconomy.n;
nYears            = length(WorldEconomy);
years             = [WorldEconomy.t];
countryCodesFull  = WorldEconomy.countryCodesFull;
industryCodesFull = WorldEconomy.industryCodesFull;
industryNamesFull = WorldEconomy.industryNamesFull;
A_overTime        = nan(n,n, nYears);
OMs_overTime      = trophicStats.trophicLevels_overTime;

% Gather the labor shares in order compute the ell_i terms
laborSharesOfGO_overTime = nan(n,nYears);
for iYear = 1:length(WorldEconomy)
   A_overTime(:,:,iYear) = WorldEconomy(iYear).A;
   laborSharesOfGO_overTime(:,iYear) = WorldEconomy(iYear).laborSharesOfGO';
end


%========================================================================%
% Preprocessing
%========================================================================%
% Choose a start year and time duration
startYear = 1995;
Delta_t   = 14;
endYear   = startYear + Delta_t;
iStart    = find(years == startYear);
iEnd      = find(years == endYear);

% Obtain key values at start year, end years, and time average
A0     = WorldEconomy(iStart).A;
A1     = WorldEconomy(iEnd  ).A;
ell0   = laborSharesOfGO_overTime(:,iStart)';
ell1   = laborSharesOfGO_overTime(:,iEnd)';
H0     = H_overTime{iStart};
H1     = H_overTime{iEnd  };
OM0    = OMs_overTime(:,iStart)';
OM1    = OMs_overTime(:,iEnd  )';

% Remove NaNs from state variables
A0(  isnan(A0)  )     = 0;
ell0( isnan(ell0) )   = 0;
H0(  isnan(H0)  )     = 0;
OM0( isnan(OM0) )     = 1;

% Compute geometric means across periods
Aave   = sqrt(A0   .* A1);
ellAve = sqrt(ell0 .* ell1);
Have   = sqrt(H0   .* H1);
OMave  = sqrt(OM0  .* OM1);

Aave(  isnan(Aave)  )   = 0;
ellAve( isnan(ellAve) ) = 0;
Have(  isnan(Have)  )   = 0;
OMave( isnan(OMave) )   = 1;

% Compute log changes in intermediate input coefficients over time
useNormalizedCoefficients = false;
if useNormalizedCoefficients
   % Divide input coefficient by (1 - labor coefficent) first, then compute
   % change of those coefficients
   A0_twiddle = zeros(n,n);
   A1_twiddle = zeros(n,n);
   for j = 1:n
      A0_twiddle(:,j) = A0(:,j) / (1 - ell0(j));
      A1_twiddle(:,j) = A1(:,j) / (1 - ell1(j));
   end
   A_logChanges      = log( A1_twiddle ./ A0_twiddle );
   A_logChangeRate   = A_logChanges / Delta_t;
else
   % Just compute the change in the ordinary input coefficients
   A_logChanges      = log( A1 ./ A0 );
   A_logChangeRate   = A_logChanges / Delta_t;
end

% Compute log changes in other quantities over time
ell_logChanges    = log( ell1 ./ ell0 );
ell_logChangeRate = ell_logChanges / Delta_t;

OM_logChanges     = log( OM1 ./ OM0 );
OM_logChangeRate  = OM_logChanges / Delta_t;


%========================================================================%
% Select an industry and compute the change in its OM
%========================================================================%
% Select industry to analyze
selectedCountry  = 'CHN';  %CHN FRA USA
selectedIndustry = 'Rub';  %Rub Agr
isSelected       = strcmp(countryCodesFull, selectedCountry) & strcmp(industryCodesFull, selectedIndustry);
m                = find(isSelected);

OM_logChange_m = OM_logChanges(m);


%========================================================================%
% Compute total influence weights W_ij^m for this industry
%========================================================================%
% For industry m, compute total influence weights W_ij^m
% Note: See SI, this is the weight that I-O coefficient a_ij receives for
% changes in the mth output multiplier, and is equal to
%
%   W_ij^m = L_i * a_ij * H_jm / L_m
%
weightsComputationMethod = 'geomean';   %geomean, initialYear
switch weightsComputationMethod
   case 'initialYear'
      W_m        = diag(OM0) * A0   * diag(H0(:,m)) / OM0(m);
      
      Wlabor_m   = zeros(n,n);
      for j = 1:n
         Wlabor_m(:,j) = W_m(:,j) * ell0(j) / (1 - ell0(j));
      end
      Wlabor_m( isnan(Wlabor_m) ) = 0;
      Vlabor_m   = sum(Wlabor_m,1);
   case 'geomean'
      W_m        = diag(OMave) * Aave   * diag(Have(:,m)) / OMave(m);
      
      Wlabor_m   = zeros(n,n);
      for j = 1:n
         Wlabor_m(:,j) = W_m(:,j) * ellAve(j) / (1 - ellAve(j));
      end
      Wlabor_m( isnan(Wlabor_m) ) = 0;
      Vlabor_m   = sum(Wlabor_m,1);
end
% Theory note on labor in these equations: Eq. 60 in the SI shows that the
% summation of weights contributing to change in the OM run over -only-
% intermediate inputs, not labor inputs.  (The effects of labor are implied
% through the latter.)  This comes out of differentiating the definition of
% the output multiplier which also involves sums that run over just
% intermediate inputs.

% Use rates of chagne and weights to compute summation terms
summationTerms_m       =  A_logChanges .* W_m;
%summationTerms_labor_m = -ell_logChangeRate .* Vlabor_m;

W_normed_m = W_m / sum(W_m(:));



%========================================================================%
% Combine intermediate goods and labor versions of various variables
%========================================================================%
Abar_logChangeRate   = [A_logChangeRate;   -ell_logChangeRate];
Wbar_m               = [W_m; Vlabor_m];
Wbar_normed_m        = Wbar_m / sum(Wbar_m(:));
summationTerms_bar_m = [A_logChanges;   -ell_logChanges] .* Wbar_m;





%========================================================================%
% Construct terms of the summation
%========================================================================%
% Compute the sum of all contributions to output multiplier change
if useNormalizedCoefficients
   summationTerms_bar_m( isinf(summationTerms_bar_m) ) = NaN;  % Set infinities to NaN
   totalSum_m = nansum( summationTerms_bar_m(:) );
else
   summationTerms_m( isinf(summationTerms_m) ) = NaN;          % Set infinities to NaN
   totalSum_m = nansum( summationTerms_m(:) );
end




%========================================================================%
% Compute the cumulative sum of the terms contributing to change in L_i
%========================================================================%
if useNormalizedCoefficients
   [Wbar_normed_sorted_m,Isort]   = sort( Wbar_normed_m(:), 'descend' );
   summationTerms_sorted_m = summationTerms_bar_m(Isort);
   
   mask                    = ~isnan(summationTerms_sorted_m);     % remove nans
   Wbar_normed_sorted_m    = Wbar_normed_sorted_m( mask );
   summationTerms_sorted_m = summationTerms_sorted_m( mask );
   cumulativeSumOfTerms    = cumsum(summationTerms_sorted_m);
   
else
   [W_normed_sorted_m,Isort]   = sort( W_normed_m(:), 'descend' );
   summationTerms_sorted_m = summationTerms_m(Isort);
   
   mask                    = ~isnan(summationTerms_sorted_m);     % remove nans
   W_normed_sorted_m    = W_normed_sorted_m( mask );
   summationTerms_sorted_m = summationTerms_sorted_m( mask );
   cumulativeSumOfTerms    = cumsum(summationTerms_sorted_m);
   
end


   
%========================================================================%
% Display stats about selected industry's largest inputs for intuition
%========================================================================%
% Find minimal set of inputs needed to reach a required total input share
reqInputShare         = 0.99;
Abar0                 = [A0; ell0];
[Abar_m_sorted,Isort] = sort(Abar0(:,m), 'descend');
cumulativeAbar_m      = cumsum(Abar_m_sorted);
numLargestInputs      = find(cumulativeAbar_m > reqInputShare,1);
indicesOfLargest      = Isort(1:numLargestInputs);

industryNamesFull_bar =  [industryNamesFull; 'labor'];
countryCodesFull_bar  =  [countryCodesFull; selectedCountry];

disp( ['Largest intermediate inputs to (',selectedIndustry,', ',selectedCountry,')'] )
[countryCodesFull_bar( indicesOfLargest ) industryNamesFull_bar( indicesOfLargest )]

% Remove labor from the list of largest indices going forward, if it is
% present.  (See note above about labor.)  1436 = 1435+1 is the extra index
% created for labor.
if ~useNormalizedCoefficients
   indicesOfLargest = setdiff(indicesOfLargest, 1436);
end

% Display the input share minus labor
highlightedInputShareMinusLabor = reqInputShare - ell0(m);
dispc(highlightedInputShareMinusLabor)


%========================================================================%
% Display stats about changes in important quantities
%========================================================================%
ell_percentChange = exp(ell_logChanges(m)) - 1;

disp( ['Initial labor share:                       ',num2str(ell0(m))] )
disp( ['Percent change in labor share over period: ',num2str(ell_percentChange)] )
disp(' ')
disp( ['Log change in output multiplier (actual):  ',num2str(OM_logChange_m) ] )
disp( ['Log change in output multiplier (sum):     ',num2str(totalSum_m)     ] )

disp(' ')
disp('Contributions to change from inputs accounting for large fraction of input share:')
largestDirectContributions_m = Abar_logChangeRate(indicesOfLargest,m) .* Wbar_m(indicesOfLargest,m)


%========================================================================%
% Look at correlations between change in input coefficients and output
% multipliers
%========================================================================%
% Set up variables for the first and last time periods
Abar0      = [A0; ell0];
Abar1      = [A1; ell1];
Delta_Abar = (Abar1 - Abar0) / 14;
OMavebar   = [OMave 0]';

% Compute a correlation coefficient and covariance across all industries
Delta_Abar(  isnan(Delta_Abar) )  = 0;
OMs_replicated = repmat(OMavebar, [1 n]);
mask           = ~isnan(Delta_Abar) & ~isinf(Delta_Abar) & ~isnan(OMs_replicated);
[rhoAll,pval]  = corr( OMs_replicated(mask), Delta_Abar(mask) );
covAll         = cov(  OMs_replicated(mask), Delta_Abar(mask) );
covAll         = covAll(1,2);

% Compute correlation coefficients and covariances industry-by-industry
correlationsVec = zeros(n,1);
covariancesVec  = zeros(n,1);
for i = 1:n
   mask = ~isnan(OMavebar) & ~isnan(Delta_Abar(:,i));
   correlationsVec(i) = corr(   OMavebar(mask), Delta_Abar(mask,i) );
   C                  = nancov( OMavebar(mask), Delta_Abar(mask,i) );
   covariancesVec(i)  = C(1,2);
end

rhoCount = nnz( abs(correlationsVec) < 0.15 ) / length(correlationsVec);

disp(' ')
disp(['Correlation across industries: ',num2str(rhoAll)])
disp(['Covariance across industries:  ',num2str(covAll)])
disp(['Number of correlations in range [-0.15 0.15]: ',num2str(rhoCount)])






%========================================================================%
% Plot 1: Coefficient change for direct inputs vs. direct input share
%========================================================================%
% Appearance parameters
xLim   = 10.^[-6 0];
yLim   = [-0.8 0.8];
xLabel = 6e-2;
yLabel = 0.7;
highlightColor = MatlabColors(2);

% Setup figure
newFigure(mfilename)
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
set(gca, 'Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(10.^[-6 0], [0 0], 'k-')
if useNormalizedCoefficients
   plot(Abar0(:,m),                Abar_logChangeRate(:,m),                'o')
   plot(Abar0(indicesOfLargest,m), Abar_logChangeRate(indicesOfLargest,m), 'o', 'MarkerEdgeColor',highlightColor)
else
   plot(A0(:,m),                A_logChangeRate(:,m),'o')
   plot(A0(indicesOfLargest,m), A_logChangeRate(indicesOfLargest,m),'o', 'MarkerEdgeColor',highlightColor)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XScale','log')
set(gca, 'YScale','linear')
set(gca, 'YLim',yLim)
set(gca, 'XLim',xLim)
set(gca, 'XTick',10.^[-6:0])
set(gca, 'FontSize',ap.fontSize)
switch weightsComputationMethod
   case 'initialYear'
      xlabel('Expenditure shares a_{im} of industry m in 1995')
   case 'geomean'
      xlabel('Expenditure shares a_{im} of industry m')
end
      
ylabel('Ave. rate of change of log(a_{im}) 1995-2009 (yr^{-1})')

% Industry label
industryLabel = [selectedIndustry,', ',selectedCountry];
text(xLabel, yLabel, industryLabel, 'FontSize',ap.fontSize)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'aChanges_v_inputShares';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end



%========================================================================%
% Plot 2: Coefficient change for indirect inputs vs. summation term
% influence
%========================================================================%
% Appearance parameters
xLim = 10.^[-6 0];
yLim = [-0.8 0.8];

% Setup figure
newFigure([mfilename,'.b'])
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
set(gca, 'Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(10.^[-6 0], [0 0], 'k-')
if useNormalizedCoefficients
   plot(Wbar_m(:)                  / sum(Wbar_m(:)), Abar_logChangeRate(:),                   '.')
   plot(Wbar_m(indicesOfLargest,m) / sum(Wbar_m(:)), Abar_logChangeRate(indicesOfLargest,m), 'o', 'MarkerEdgeColor',highlightColor)
else
   plot(W_m(:)                  / sum(W_m(:)), A_logChangeRate(:),                   '.')
   plot(W_m(indicesOfLargest,m) / sum(W_m(:)), A_logChangeRate(indicesOfLargest,m), 'o', 'MarkerEdgeColor',highlightColor)
end
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'XScale','log')
set(gca, 'YScale','linear')
set(gca, 'YLim',yLim)
set(gca, 'XLim',xLim)
set(gca, 'XTick',10.^[-6:0])
set(gca, 'FontSize',ap.fontSize)
switch weightsComputationMethod
   case 'initialYear'
      xlabel('Weight share S_{ij}^m in 1995')
   case 'geomean'
      %xlabel('Weight share S_{ij}^m')
      xlabel('Weight share W_{ij}^m / \Sigma_{ij} W_{ij}^m')
end
ylabel('Ave. rate of change of log(a_{im}) 1995-2009 (yr^{-1})')

% Industry label
industryLabel = [selectedIndustry,', ',selectedCountry];
text(xLabel, yLabel, industryLabel, 'FontSize',ap.fontSize)

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.figuresFolder;
   fileName  = 'aChanges_v_weights';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end




%========================================================================%
% Plot 3: Coefficient change for summation terms vs. summation term
% influence
%========================================================================%
if false
   % Appearance parameters
   xLim   = 10.^[-6 0];
   yLim   = [-0.012 0.012];
   yLabelc = yLim(2) * (yLabel / 0.8);
   
   % Setup figure
   hSave = newFigure([mfilename,'.c']);
   clf
   figpos = get(gcf, 'Position');
   set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
   
   % Setup axes
   subaxis(2,1,1)
   
   % Plot
   hold on
   plot(10.^[-6 0], [0 0], 'k-')
   if useNormalizedCoefficients
      plot(Wbar_m(:)                  / sum(Wbar_m(:)), Abar_logChangeRate(:)                  .* Wbar_m(:),                   '.')
      plot(Wbar_m(indicesOfLargest,m) / sum(Wbar_m(:)), Abar_logChangeRate(indicesOfLargest,m) .* Wbar_m(indicesOfLargest,m), 'o', 'MarkerEdgeColor',highlightColor)
   else
      plot(W_m(:)                  / sum(W_m(:)), A_logChangeRate(:)                  .* W_m(:),                   '.')
      plot(W_m(indicesOfLargest,m) / sum(W_m(:)), A_logChangeRate(indicesOfLargest,m) .* W_m(indicesOfLargest,m), 'o', 'MarkerEdgeColor',highlightColor)
   end
   hold off
   
   % Industry label
   industryLabel = [selectedIndustry,', ',selectedCountry];
   text(xLabel, yLabelc, industryLabel, 'FontSize',ap.fontSize)
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XScale','log')
   set(gca, 'YScale','linear')
   set(gca, 'YLim',yLim)
   set(gca, 'XLim',xLim)
   set(gca, 'XTick',10.^[-6:0])
   set(gca, 'FontSize',ap.fontSize)
   xlabel('Weight share S_{ij}^m in 1995')
   ylabel('Contribution to change in output multiplier (yr^{-1})')
   
   % Industry label
   industryLabel = [selectedIndustry,', ',selectedCountry];
   text(xLabel, yLabel, industryLabel, 'FontSize',ap.fontSize)
   
   
   % Setup axes
   subaxis(2,1,2)
   
   % Plot
   hold on
   if useNormalizedCoefficients
      plot(Wbar_normed_sorted_m, cumulativeSumOfTerms, 'b-')
   else
      plot(W_normed_sorted_m, cumulativeSumOfTerms, 'b-')
   end
   plot(xLim, [0 0], 'k-')
   hold off
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'XScale','log')
   set(gca, 'YScale','linear')
   set(gca, 'XLim',xLim)
   set(gca, 'XTick',10.^[-6:0])
   set(gca, 'FontSize',ap.fontSize)
   xlabel('Weight share S_{ij}^m in 1995')
   ylabel('Cumulative sum (yr^{-1})')
   
   % Save
   if pp.saveFigures
      h         = gcf;
      folder    = pp.figuresFolder;
      fileName  = 'summationTerms_v_weights';
      fileName  = fullfile(folder, fileName);
      savemode  = 'painters_pdf';
      save_image(h, fileName, savemode)
   end
end


%========================================================================%
% Plot 4: Contributions of terms to total change in L_i
%========================================================================%
if false
   % Additional or customized appearance parameters
   xLim = 10.^[0 6];
   yLim = [0 0.4];
   yMax = max(abs(cumulativeSumOfTerms));
   xLabel_e = 6e4;
   yLabel_e = 0.375;
   
   % Setup figure
   newFigure( [mfilename,'.contributions'] );
   clf
   figpos = get(gcf, 'Position');
   set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
   
   % Setup axes
   axes('Position',[0.15    0.15    0.7    0.7])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   plot(cumulativeSumOfTerms, '-')
   plot(10.^[0 7], [0 0], 'k-')
   hold off
   
   % Industry label
   industryLabel = [selectedIndustry,', ',selectedCountry];
   text(xLabel_e, yLabel_e, industryLabel, 'FontSize',ap.fontSize)

   % Refine
   set(gca, 'Box','on')
   set(gca, 'Layer', 'top')
   set(gca, 'XScale','log')
   set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim)
   set(gca, 'XTick',10.^[0:6])
   set(gca, 'FontSize',ap.fontSize)
   xlabel('No. summation terms')
   ylabel('Cumulative sum (yr^{-1})')
   
   % Save
   if pp.saveFigures
      h         = gcf;
      folder    = pp.figuresFolder;
      fileName  = 'numSummationTerms';
      fileName  = fullfile(folder, fileName);
      savemode  = 'painters_pdf';
      save_image(h, fileName, savemode)
   end
end

