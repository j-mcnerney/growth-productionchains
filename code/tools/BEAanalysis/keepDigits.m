function newCodeList = keepDigits(codeList, d)
% newCodeList = keepDigits(codeList, d) returns a new code list which
% retains the first d digits of the passed-in codeList.

assert(d>=0,'d must be non-negative')

nCodes = length(codeList);
newCodeList = cell(size(codeList,1), size(codeList,2));
for iCode = 1:nCodes
   newCodeList{iCode} = codeList{iCode}(1:d);
end