function [coeff,expo,latex_string] = coeff_and_expo(x,varargin)
% [coeff,expnt,latex_string] = coeff_and_expo(x) returns the coefficient
% and exponent of x. It also returns a latex string for the quantity.
%
% Modified by James McNerney.

% TEST DATA:
% arg = (0.5 - rand) * 10^fix(10*(0.5-rand))
% sprintf('\n\t%23.15E\n',arg)

sgn   = sign(x);
expo  = fix(log10(abs(x)));
coeff = sgn * 10^(log10(abs(x)) - expo);
if abs(coeff) < 1
    coeff = coeff * 10;
    expo  = expo - 1;
end

if nargin == 2
   formatString = varargin{1};
   latex_string = [num2str(coeff,formatString),' \times 10^{',num2str(expo),'}'];
else
   latex_string = [num2str(coeff,'%3.2f'),' \times 10^{',num2str(expo),'}'];
end