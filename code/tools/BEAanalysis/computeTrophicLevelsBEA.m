function [trophicLevels,trophicDepth] = computeTrophicLevelsBEA(economy)
% [trophicLevels,trophicDepth,Pmod] = computeTrophicLevelsBEA(economy)
% computes the trophic levels and trophic depth for the BEA data.

% Grab data
n        = economy.n;               % # of industries
thetaVec = economy.thetavec(1:n);   % GDP shares of industries
%Yvec     = economy.Yvec(1:n);     % GDP of industries
A        = economy.Abar(1:n,1:n);   % input coefficients
Mout     = economy.Mhatvec(1:n);    % industry expenditures
%Z        = economy.Mbar(1:n,1:n);  % matrix of industries only

% Isolate subset of industries with expenditures
hasExpenditures = ~isnan(Mout) & (Mout > 0);

% Compute trophic levels for this subset
A_sub       = A(hasExpenditures,hasExpenditures);
n_sub       = nnz(hasExpenditures);
I_sub       = eye(n_sub);
onesVec_sub = ones(n_sub,1);
TL_sub      = inv(I_sub - A_sub') * onesVec_sub;

% Store (set the trophic levels of industries with expenditures to NaN)
trophicLevels = nan(n,1);
trophicLevels(hasExpenditures) = TL_sub;

% Set NaN trophic levels to zero for purpose of computing trophic depths
trophicLevels_mod = trophicLevels;
trophicLevels_mod(~hasExpenditures) = 0;

% Compute average output multiplier
trophicDepth = thetaVec' * trophicLevels_mod;