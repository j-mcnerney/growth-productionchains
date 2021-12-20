function binEdges = equalCountBinning(X, nBins)
% binEdges = equalCountBinning(X, nBins) generates an equal-count binning
% scheme for the data in vector X.  It returns a set of nBins+1 bin edges
% for nBins # of bins.

% Eliminate NaNs and sort data
X = X(~isnan(X));
X = sort(X,'ascend');


% Lay first edge and last edges just outside range of points
binEdges          = zeros(1,nBins+1);
nudge             = 1e-6;
binEdges(1)       = X(1)   * (1-nudge);
binEdges(nBins+1) = X(end) * (1+nudge);

% Determine bin edges in between
% Algorithm:
% 1- Determine the average number of counts per bin, which in general is
%    not an integer
% 2- Go thru bins from left to right.  Count the "ideal" number of data
%    we would like to have binned so far using the true (non-integer) mean
%    count per bin.  Take the floor of this number to create an integer
%    index into the data iData.  Set the next edge halfway between the
%    iData and iData+1'th data points.
% 3- Repeat for all bins
N             = length(X);
meanBinCount  = N/nBins;
cumIdealCount = 0;
cumActualCount = 0;
for iBin = 1:nBins-1
   cumIdealCount    = cumIdealCount + meanBinCount;
   iData            = floor(cumIdealCount);
   %binEdges(iBin+1) = X(iData) * (1+nudge);
   binEdges(iBin+1) = (X(iData) + X(iData + 1)) / 2;
end
