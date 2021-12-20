function consistentTickPrecision(theAxes, whichAxis, precision)
% consistentTickPrecision(theAxes, 'x', precision) or
% consistentTickPrecision(theAxes, 'y', precision) makes all tick labels on
% the given axis have consistent precision.  precision specifies the number
% of digits after the decimal point.

switch whichAxis
   case 'x'
      currentTickLabelsNumeric = get(theAxes,'XTick');
      newTickLabelsCell = arrayfun(@(x) num2str(x,'%3.1f'), currentTickLabelsNumeric, 'UniformOutput',false);
      set(theAxes, 'XTickLabel',newTickLabelsCell)
   case 'y'
      currentTickLabelsNumeric = get(theAxes,'YTick');
      tickFormat = ['%3.',num2str(precision),'f'];
      newTickLabelsCell = arrayfun(@(x) num2str(x,tickFormat), currentTickLabelsNumeric, 'UniformOutput',false);
      set(theAxes, 'YTickLabel',newTickLabelsCell)
end