function [nStars, nStarsString] = significanceLevel(pvals, significanceLevels)
% [nStars, nStarsString] = significanceLevel(pvals, pLevels) takes a vector of p-values
% and returns a cell array of strings containing stars -- i.e. *, **, or *** -- giving the
% significance level of each p-value.  The argument significanceLevels should be a vector 
% with 3 numbers giving the significance level associated 1, 2, or 3 stars in this order.

% Un-pack p-value star levels
pVal_1star = significanceLevels(1);
pVal_2star = significanceLevels(2);
pVal_3star = significanceLevels(3);

% Start all variables at zero stars
nVars  = length(pvals);
nStars = zeros(nVars,1);      

% Increment star count if you pass 1-star level
mask = (pvals < pVal_1star);
nStars(mask) = nStars(mask) + 1;

% Increment star count if you pass 2-star level
mask = (pvals < pVal_2star);
nStars(mask) = nStars(mask) + 1;

% Increment star count if you pass 3-star level
mask = (pvals < pVal_3star);
nStars(mask) = nStars(mask) + 1;

% Convert to a string
nStarsString = cell(nVars,1);
for iVar = 1:nVars
   if nStars(iVar) == 0
      nStarsString{iVar} = '';
   else
      nStarsString{iVar} = repmat('*',[1 nStars(iVar)]);
   end
end