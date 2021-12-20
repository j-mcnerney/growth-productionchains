function printLatexTable(tableCell, varargin)
% printLatexTable(tableCell) prints a Latex table using the information in
% tableCell, which must be a cell array of strings. The table can be copied
% and pasted from the command window into a latex document.
%
% printLatexTable(tableCell, headerCell) prints a Latex table with the
% column titles in headerCell. Column titles are made bold in Latex.
%
% printLatexTable(tableCell, headerCell, rowCell) also includes the row
% labels in rowCell. 

% Determine dimensions of table
numRows = size(tableCell,1);  
numCols = size(tableCell,2);
if nargin == 3
   %numCols = numCols + 1;  % add column for row labels
   rowCell = varargin{2};
end

% Store a genuine tab string for use in table
S_tab = '	';

% Start tabular environment
S_columnAlignment = repmat('l',1,numCols);
disp( ['\begin{tabular}{', S_columnAlignment, '}'] )

% Print header line, if passed-in
if nargin >= 2
   headerCell = varargin{1};
   disp('\hline')
   
   % Build up header row string by concatenating header elements
   S_header = '';
   for col = 1:numCols
      S_header = [S_header, S_tab, '&\textbf{', escapedString(num2str(headerCell{col})), '}'];
   end
   S_header = [S_header, '\\'];
   
   % Correct beginning of string if no row labels
   if nargin < 3
      S_header = S_header(3:end);   %lop-off unneeded initial '&'
   end
   
   disp(S_header)
end

% Print body and end of table
disp('\hline')
for row = 1:numRows
   % Build up a row string by concatenating row data
   % Note: num2str is harmless if argument is already a string, and fixes
   % elements that are not strings.
   S_row = '';
   for col = 1:numCols
      S_row = [S_row, S_tab, '&', escapedString(num2str(tableCell{row,col},'%4.3f'))];
   end
   S_row = [S_row, '\\'];
   
   % Correct beginning of string to either include or exclude row label
   if nargin < 3
      S_row = S_row(3:end);         %lop-off unneeded initial tab and '&'
   else
      S_row = [rowCell{row},S_row]; %prepend row label
   end
   
   disp(S_row)
end
disp('\hline')
disp('\end{tabular}')
end

function S_out = escapedString(S_in)
% Helper function to convert strings with characters like '&', '\', and '$'
% into escape versions '\&', '\\', and '\$'.

S_out = S_in;
S_out = strrep(S_out,'&','\&');
end