function varargout = newFigure(figName)

% Check if figure has been created already
h = findobj('Name',figName);

% Make this figure current, or create anew
if ~isempty(h)
   figure(h);
else
   h = figure;
   set(h,'Name',figName)
   set(h,'IntegerHandle','off')
end

% Return handle if asked for
if nargout == 1
   varargout{1} = h;
end
