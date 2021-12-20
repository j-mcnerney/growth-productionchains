function G = aggregationMatrix( nFine, kind, varargin )
% G = aggregationMatrix(kind, nFine, varargin) creates an aggregation
% matrix. nFine is the number of nodes in the "fine" (un-aggregated)
% matrix.
%
% G = aggregationMatrix(..., 'first-two') creates an aggregation matrix
% that will aggregate the first two nodes only.
%
% G = aggregationMatrix(..., 'first-k', k) will aggregate the first k
% nodes.
%
% G = aggregationMatrix(..., 'random', nGroups) will aggregate nodes
% into (approximately) nGroups number of groups.
%
% G = aggregationMatrix(..., 'custom', labelList) will aggregate nodes
% on the basis of a list of labels. The labelList should be of length nFine
% and for each node indicate the coarse-grained node the fine-grained node
% will be aggregated into.
%
% G = aggregationMatrix(nFine, 'kind', ..., true) will keep the last node
% from being merged with any other node. This is to account for cases where
% the last node represents the household sector, and should not be merged
% with other nodes during coarse-graining of industries.

% Check if the user requested to keep the last node separate from others.
% If so, pretend until the end that there are actually nFine - 1 nodes 
% instead of nFine nodes.
if nargin == 4   
   keepLastNodeSeparate = varargin{2};
   if keepLastNodeSeparate
      nFine = nFine - 1;
   end
end

switch kind
   case 'first-two'
      coarseIndexList = [1 1:nFine-1];
      nCoarse = nFine - 1;
      
   case 'first-k'
      k = varargin{1};
      coarseIndexList = [ones(1,k-1) 1:nFine-k+1];
      nCoarse = nFine - k + 1;

   case 'random'
      nGroups = varargin{1};
      
      % Generate list of coarse-grained indices for each fine-grained node
      withReplacement = 'true';
      labelList = randsample(nGroups,nFine,withReplacement);
      coarseIndexList = labels2indices(labelList);
      nCoarse         = length(unique(labelList));

   case 'custom'
      labelList = varargin{1};
      assert(length(labelList)==nFine,'labelList should be equal to number of industry nodes.')
      
      % Convert list of labels into a list of indices
      coarseIndexList = labels2indices(labelList);
      nCoarse         = length( unique(labelList) );

   otherwise
      error('genAggregationMatrix: Unrecognized kind.')
end
fineIndexList   = [1:nFine]';

% Create aggregation matrix. Use sparse function to assign 1s to appropriate elements
Irows   = coarseIndexList;
Icols   = fineIndexList;
values  = ones(nFine,1);
numRows = nCoarse;
numCols = nFine;
G       = sparse(Irows,Icols,values,numRows,numCols);
G       = full(G);

% If the 'keepLastNodeSeparate' flag was turned on, now add this node back in
% by adding one more row and column for this node.
if nargin == 4
   if keepLastNodeSeparate
      G = [[G              zeros(nCoarse,1)]
           [zeros(1,nFine)          1      ]];
   end
end

end


function coarseIndexList = labels2indices(labelList)
% Convert list of labels into a list of indices

nFine           = length(labelList);
nCoarse         = length(unique(labelList));
uniqueLabelList = unique(labelList);
coarseIndexList = zeros(nFine,1);

labelsAreNumeric = isnumeric(labelList);

% Obtain indices of LabelList that match iLabel'th label
for iLabel = 1:nCoarse
   thisLabel     = uniqueLabelList(iLabel);
   if labelsAreNumeric
      hasThisLabel = (thisLabel == labelList);
   else
      hasThisLabel = strcmp(thisLabel,labelList);
   end
   coarseIndexList(hasThisLabel) = iLabel;
end
end