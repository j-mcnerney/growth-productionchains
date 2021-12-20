function announceFunction()
% Output name of the function that this function has been placed in

functionStack      = dbstack(1);
callerFunctionName = functionStack.name;

disp( [newline,'--------------------------------------------------------------------'] )
disp(['RUNNING ',callerFunctionName,'...'])