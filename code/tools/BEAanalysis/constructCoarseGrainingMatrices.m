function [H,W,V] = constructCoarseGrainingMatrices(G,e)
% [H,W,V] = constructCoarseGrainingMatrices(G,economy) takes an
% aggregation matrix G and constructs the other 3 coarse-graining matrices
% H, W, and V for the given economy.

% Construct H matrix
% Long note: By definition the elements of the H matrix are related to
% those of the G matrix by
%
%    H_Ij = (1/Mhat_I) * G_Ij * Mhat_j.
%
% Here, I is the index of a coarse-grained industry, j is the index of a
% fine-grained industry, and Mhat_I or Mhat_j represents the total
% expenditures of I or j. For most elements of H, we can use the formula
% above directly. For a few elements, we have to use a modified calculation
% when handling real data. Real IO data include some industries with no
% expenditures. If the coarse-graining leaves these industries unmerged, or
% merged only with other industries that also have zero expenditures, then
% the expendtures Mhat_I of the coarse-grained industry will equal zero,
% and cause the formua above to be infinite.
%
% To avoid this, we follow a different approach in cases where Mhat_I is
% zero. Note that conceptually, H_Ij has the interpretation as the fraction
% of I's expenditures that are made by j. If I has no expenditures, and
% contains nFine nodes from the fine-grained network, then it isn't wrong
% to say that each fine-grained node contributes a fraction 1/nFine of the
% total (zero) expenditures of Mhat_I. This preserves the property of H
% that the row sums are all equal to 1, and testing so far does not seem to
% cause any issues.
MhatvecFine   = e.Mhatvec;
MhatvecCoarse = G * e.Mhatvec;

nCoarse = size(G,1);
nFine   = size(G,2);
H       = zeros(nCoarse, nFine);
for iCoarse = 1:nCoarse
   if MhatvecCoarse(iCoarse) == 0
      nFineNodesInThisCoarseNode = sum( G(iCoarse,:) );
      H(iCoarse,:) = G(iCoarse,:) / nFineNodesInThisCoarseNode; % Split evenly across nodes
   else
      H(iCoarse,:) = (1/MhatvecCoarse(iCoarse)) * G(iCoarse,:) .* MhatvecFine';
   end
end

% Construct W matrix
% Note: By definition the elements of W are related to those of the G by
%
%    W_Ij = (1/p_I) * G_Ij * p_j. (*)
%
% Here p_I and p_j are the prices of coarse-grained industry I and
% fine-grained industry j. To actually implement this, we need to decide on
% a price convention for the coarse-grained prices. There's nothing that
% determines canonically what the coarse-grained prices have to be, forcing
% us to choose them. Any choice will yield valid results. For example, the
% coarse-grained prices could all be set to 1, or to random values, and we
% would still obtain an internally consistent system of goods flow, money
% flows, and prices in the coarse-grained network. However, we would like
% the prices of the coarse-grained network to bear a close resemblence to
% those in the fine-grained network. One way to do this is to weight prices
% of nods in the fine-grained network by their expenditures. In this
% convention, the price for some coarse-grained node I is
%
%    p_I = G_I1*(Mhat_1/Mhat_I) * p_1 + G_I2*(Mhat_2/Mhat_I) * p_2 + ...
%        = sum_j G_Ij * (Mhat_j/Mhat_I) * p_j
%
% The extra factor G_Ij is needed to kill off any contributions from
% prices j that do not get merged in I. The factors in this sum turn out to
% be exactly the elements of the H matrix we just constructed above. So an
% easy way to compute the coarse-grained prices is to pCoarse = H*pFine. We
% can then use the coarse-grained prices with the (*) formula to get the
% elements of W.
pvecCoarse = H*e.pvec;
W = inv(diag(pvecCoarse)) * G * e.Pbar;

% Construct V matrix
% Note: Prices transform under coarse-graining as pCoarse = V*pFine. But
% above we chose a convention for setting the coarse-grained prices such
% that pCoarse = H*pFine. Thus, by choosing the price convention above,
% we've actually determined that V has to be equal H.
V = H;