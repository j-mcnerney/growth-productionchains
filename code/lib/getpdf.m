function [x,fx,dx] = getpdf(D,edges,varargin)
% [x,fx,dx] = getpdf(D,edges) computes the probability density function of
% the data in vector 'D' using bin edges given in 'edges'. It returns three
% arguments:
%
% x  = locations of bin centers
% fx = PDF values for each bin
% dx = length of each bin
%
% getpdf(D,edges,'linear') or getpdf(D,edges,'log') computes bin centers
% based on either a linear scale or a logarithmic scale. That is, each bin
% center can be computed as the arithmetic mean of the two surrounding
% edges or the geometric mean. If no third argument is passed in, then
% getpdf uses linear bin centers by default.

% Make data and edges both column vectors.
if size(D,2) > size(D,1)
   D = D';
end
if size(edges,2) > size(edges,1)
   edges = edges';
end

% Compute bin lengths.
dx = diff(edges);

% Set either linear-based bin centers (default) or log-based bin centers.
if nargin == 2
   logcenters = false;
elseif nargin == 3 & strmatch(varargin{1}, 'linear')
   logcenters = false;
elseif nargin == 3 & strmatch(varargin{1}, 'log')
   logcenters = true;
else
   error('Incorrect argument list. See help.')
end

% Compute bin centers.
B  = length(edges) - 1; % # of bins
if logcenters == true
   logdx = diff( log(edges) );
   x     = exp( log(edges(1:B)) + logdx/2 );
else
   x     = edges(1:B) + dx/2;
end

% Compute pdf values.
H  = histc(D,edges); % get histogram counts for each bin
H  = H(1:B);         % histc returns B+1 bins, with the final bin representing counts exceeding the given range of bins. Lop off this last bin.
fx = H./dx/sum(H);   % convert bin counts to probability densities