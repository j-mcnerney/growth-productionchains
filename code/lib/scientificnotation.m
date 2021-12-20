function [latex_string,coeff,expo] = scientificnotation(x)
% latex_string = scientificnotation(x) returns a latex string for x in scientific
% notation.
%
% [latex_string,coeff,expo] = scientificnotation(x) also returns the coefficient
% and exponent of x.
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

latex_string = [num2str(coeff,'%3.2f'),' \times 10^{',num2str(expo),'}'];