function US1997 = loadEconomy_US1997()

load( './save/IndustryCodes1997.mat' )
load( './save/IOtable1997.mat' )

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
US1997.name      = 'United States';
US1997.t         = 1997;
US1997.n         = n;
US1997.Xbar      = nan(n+1,n+1);
US1997.Mbar      = Mbar;
US1997.Phibar    = nan(n+1,n+1);
US1997.Abar      = Abar;
US1997.Pbar      = nan(n+1,n+1);
US1997.Xhatvec   = nan(n+1,1);
US1997.Mcheckvec = Mcheckvec;
US1997.Mhatvec   = Mhatvec;
US1997.Cvec      = nan(n+1,1);
US1997.Yvec      = Yvec;
US1997.Lvec      = nan(n+1,1);
US1997.Vvec      = Vvec;
US1997.pvec      = nan(n+1,1);
US1997.thetavec  = thetavec;
US1997.onesvec   = onesvec;
US1997.M_GO      = M_GO;
US1997.M_IC      = M_IC;
US1997.V         = V;
US1997.Y         = Y;
US1997.L         = nan;
US1997.ValueAddedRows  = ValueAddedRows;
US1997.FinalDemandCols = FinalDemandCols;

US1997.timeUnits             = 'years';
US1997.moneyUnits            = '1000 $';
US1997.goodsUnits            = {};
US1997.industryLabels        = [IndustryCodes; {'------','Scrap'}];
US1997.finalDemandCategories = FinalDemandCodes;
US1997.valueAddedComponents  = ValueAddedCodes;
US1997.doc                   = 'US 1997 benchmark IO data produced from make and use tables using product technology assumption.';