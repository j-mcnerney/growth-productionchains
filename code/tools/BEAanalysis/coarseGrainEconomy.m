function eCoarse = coarseGrainEconomy(G,eFine)

import tools.CoarseGrain.*

% Copy the original economy
eCoarse = eFine;

% Set NaNs to zeros for the purposes of coarse graining.
Abar = eFine.Abar;
Abar(isnan(Abar)) = 0;

% Apply coarse-graining transformations to variables
[H,W,V] = constructCoarseGrainingMatrices(G,eFine);

eCoarse.n         = size(G,1) - 1;
eCoarse.Xbar      = G*eFine.Xbar*W';
eCoarse.Mbar      = G*eFine.Mbar*G';
eCoarse.Phibar    = V*eFine.Phibar*W';
eCoarse.Abar      = G*Abar*H';
eCoarse.Pbar      = V*eFine.Pbar*G';
eCoarse.Xhatvec   = W*eFine.Xhatvec;
eCoarse.Mcheckvec = G*eFine.Mcheckvec;
eCoarse.Mhatvec   = G*eFine.Mhatvec;
eCoarse.Cvec      = W*eFine.Cvec;
eCoarse.Yvec      = G*eFine.Yvec;
eCoarse.Lvec      = G*eFine.Lvec;
eCoarse.Vvec      = G*eFine.Vvec;
eCoarse.pvec      = V*eFine.pvec;
eCoarse.thetavec  = G*eFine.thetavec;
eCoarse.onesvec   = ones(eCoarse.n+1,1);
eCoarse.M_GO      = eCoarse.pvec' * (eCoarse.Xhatvec - eCoarse.Cvec);%check
eCoarse.M_IC      = sum(sum(eCoarse.Mbar(1:eCoarse.n,1:eCoarse.n)));%check
eCoarse.V         = eCoarse.pvec(eCoarse.n+1) * sum(eCoarse.Lvec); %check
eCoarse.Y         = eCoarse.pvec' * eCoarse.Cvec;