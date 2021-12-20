function binStats = binDataBy(Y,X,binEdges)
% Group data into bins by X, and compute bin statistics for Y.

% Make both X and Y column vectors
if isrow(X); X = X'; end
if isrow(Y); Y = Y'; end

binStats.nBins  = length(binEdges) - 1;
binStats.Xdata  = cell(binStats.nBins, 1);
binStats.Ydata  = cell(binStats.nBins, 1);
binStats.count  = zeros(binStats.nBins, 1);
binStats.Xmean  = zeros(binStats.nBins, 1);
binStats.Ymean  = zeros(binStats.nBins, 1);
binStats.Ystd   = zeros(binStats.nBins, 1);
binStats.labels = nan(length(X),1);
for iBin = 1:binStats.nBins
   low     = binEdges(iBin);
   high    = binEdges(iBin+1);
   XisInBin = (X >= low) & (X < high);
   Yexists = ~isnan(Y);
   
   binStats.Xdata{iBin} = X(XisInBin & Yexists);
   binStats.Ydata{iBin} = Y(XisInBin & Yexists);
   
   binStats.Xmean(iBin) = nanmean( X(XisInBin & Yexists) );
   binStats.Ymean(iBin) = nanmean( Y(XisInBin & Yexists) );
   binStats.Ystd(iBin)  = nanstd(  Y(XisInBin & Yexists) );
   binStats.count(iBin) = nnz(       XisInBin & Yexists  );
   
   binStats.labels(XisInBin & Yexists) = iBin;
end