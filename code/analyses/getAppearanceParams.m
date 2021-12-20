function appearanceParams = getAppearanceParams()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp
% appearanceParams = getAppearanceParams() sets universal appearance
% parameters to be used by a set of figure functions.

% Matlab default colors
% See https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html
matlabDefaultColors = [
         0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    ];

% Colors
appearanceParams.dataColor   = [234+5-1 88+13+10-1 0]/255 * 1.07;
appearanceParams.fitColor    = matlabDefaultColors(2,:);
appearanceParams.moneyColor  = [90+18+1 134+16-1 80+19+2]/255;
appearanceParams.dataAlpha   = 0.8;

% Sizes
appearanceParams.markerSize  = 11;
appearanceParams.lineWidth   = 2;

% Fonts
appearanceParams.fontSize    = 14;

