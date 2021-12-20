function [H_overTime,badIndustries] = computeLeontiefInverse(WorldEconomy)
% H_overTime = computeLeontiefInverse(WorldEconomy) computes the Leontief
% inverse for each year.

disp('Computing Leontief inverses...')

nYears     = length(WorldEconomy);
H_overTime = cell(nYears,1);
for iYear = 1:nYears
   % Grab data
   n        = WorldEconomy(iYear).n;             % # of industries
   A        = WorldEconomy(iYear).A;             % input coefficients
   Mout     = WorldEconomy(iYear).Mout;          % industry expenditures
   
   % Isolate subset of industries with expenditures
   hasExpenditures = ~isnan(Mout) & (Mout > 0);
   
   % Compute Leontief inverse for this subset in this year
   A_sub = A(hasExpenditures,hasExpenditures);
   n_sub = nnz(hasExpenditures);
   I_sub = eye(n_sub);
   H_sub = inv(I_sub - A_sub);
   
   % Restore eliminate rows and columns of H, filling these with NaNs
   H = nan(n,n);
   H(hasExpenditures,hasExpenditures) = H_sub;
   
   % Store
   H_overTime{iYear} = H;
end
