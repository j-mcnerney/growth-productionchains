function dispc(X,vargin)

% Get first input
varName = inputname(1);

% Check if this is a variable name or a string
isVariable = ~isempty(varName);

% Print string
if isVariable
   nRows = size(X,1);
   if nRows == 1
      S = [varName,': ',num2str(X)];
      disp(S)
   else
      disp( [varName,':'] )
      disp(X)
   end
   
else
   disp(X)
end