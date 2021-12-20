function US2002 = loadEconomy_US2002()

load( './save/IndustryCodes2002.mat' )
load( './save/IOtable2002.mat' )

Yvec = sum(FinalDemandCols,2);

useOnlyLabor = true
if useOnlyLabor
   Vvec = ValueAddedRows(1,:)';     % Only labor
else
   Vvec = sum(ValueAddedRows,1)';   % All value added
end

Mbar = [[M    Yvec]
        [Vvec' 0  ]];
Yvec = [Yvec; 0];
Vvec = [Vvec; 0];
Mhatvec   = sum(Mbar,1)';
Mcheckvec = sum(Mbar,2);

% Some industries in the actual data have zero expenditures. We therefore
% cannot compute Abar the normal way of Abar = Mbar*inv(diag(Mhatvec));,
% because inv(diag(Mhatvec)) will contain Inf's on the diagonal.
Abar = zeros(n+1,n+1);
for i = 1:n+1
   Abar(:,i) = Mbar(:,i) / Mhatvec(i);
end


V         = sum(Vvec);
Y         = sum(Yvec);
M_GO      = sum(M(:)) + Y;
M_IC      = sum(M(:));
thetavec  = Yvec/Y;
onesvec   = ones(n+1,1);

% Package variables into an outgoing struct
US2002.name      = 'United States';
US2002.t         = 2002;
US2002.n         = n;
US2002.Xbar      = nan(n+1,n+1);
US2002.Mbar      = Mbar;
US2002.Phibar    = nan(n+1,n+1);
US2002.Abar      = Abar;
US2002.Pbar      = nan(n+1,n+1);
US2002.Xhatvec   = nan(n+1,1);
US2002.Mcheckvec = Mcheckvec;
US2002.Mhatvec   = Mhatvec;
US2002.Cvec      = nan(n+1,1);
US2002.Yvec      = Yvec;
US2002.Lvec      = nan(n+1,1);
US2002.Vvec      = Vvec;
US2002.pvec      = nan(n+1,1);
US2002.thetavec  = thetavec;
US2002.onesvec   = onesvec;
US2002.M_GO      = M_GO;
US2002.M_IC      = M_IC;
US2002.V         = V;
US2002.Y         = Y;
US2002.L         = nan;
US2002.ValueAddedRows  = ValueAddedRows;
US2002.FinalDemandCols = FinalDemandCols;

US2002.timeUnits             = 'years';
US2002.moneyUnits            = '1000 $';
US2002.goodsUnits            = {};
US2002.industryLabels        = [IndustryCodes; {'------','Scrap'}];
US2002.finalDemandCategories = FinalDemandCodes;
US2002.valueAddedComponents  = ValueAddedCodes;
US2002.doc                   = 'US 2002 benchmark IO data produced from make and use tables using product technology assumption.';