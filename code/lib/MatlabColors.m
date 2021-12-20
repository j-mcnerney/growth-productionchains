function C = MatlabColors(varargin)
% C = MatlabColors() returns a matrix whose rows contain the default colors
% Matlab uses for its plotting lines.  (These are nice colors.)
%
% C = MatlabColors(i) returns just the i'th color.

if nargin == 0
   C = [
      0         0.4470    0.7410
      0.8500    0.3250    0.0980
      0.9290    0.6940    0.1250
      0.4940    0.1840    0.5560
      0.4660    0.6740    0.1880
      0.3010    0.7450    0.9330
      0.6350    0.0780    0.1840
      ];
elseif nargin == 1
   ipick = varargin{1};
   C = [
      0         0.4470    0.7410
      0.8500    0.3250    0.0980
      0.9290    0.6940    0.1250
      0.4940    0.1840    0.5560
      0.4660    0.6740    0.1880
      0.3010    0.7450    0.9330
      0.6350    0.0780    0.1840
      ];
   C = C(ipick,:);
else
   error('MatlabColors: too many inputs')
end