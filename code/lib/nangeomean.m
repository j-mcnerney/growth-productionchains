function Xmean = nangeomean(X)

mask = ~isnan(X);
Xmean = geo_mean( X(mask) );