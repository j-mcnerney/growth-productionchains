function Xmean = nangeomean(X)

mask = ~isnan(X);
Xmean = geomean( X(mask) );
