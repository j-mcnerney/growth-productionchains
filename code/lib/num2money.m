function moneyString = num2money(value,centsFlag)
%NUM2MONEY   Converts a numeric value to a monetary value string.
%   STR = NUM2MONEY(X), for a numeric scalar X, returns a string
%   representation of X formatted as a monetary value.
%
%   STR = NUM2MONEY(X,'cents') will display the cents portion of the string
%   even when X is a whole dollar amount. By default, zero cents is not
%   displayed.
%
%   Examples:
%      num2money(200)          returns '$200'
%      num2money(200,'cents')  returns '$200.00'
%      num2money(-200.34)      returns '-$200.34'
%      num2money(2000.34)      returns '$2,000.34'
%      num2money(20000.1023)   returns '$20,000.10'

% Author: Ken Eaton
% Last modified: 4/2/08
%--------------------------------------------------------------------------

  switch nargin,
    case 0,
      error('num2money:notEnoughInputs','Not enough input arguments.');
    case 1,
      centsFlag = false;
    case 2,
      if (~ischar(centsFlag)),
        error('num2money:badArgumentType',...
              'Format argument should be of type char.');
      end
      if strcmpi(centsFlag(:).','cents'),
        centsFlag = true;
      else
        error('num2money:invalidFormat',...
              '''cents'' is the only valid format argument.');
      end
  end
  if (~isnumeric(value)),
    error('num2money:badArgumentType',...
          'Input argument should be of type numeric.');
  end
  if (numel(value) > 1),
    error('num2money:badArgumentSize',...
          'Input argument should be a scalar.');
  end
  cents = rem(abs(value),1);
  dollars = floor(abs(value));
  moneyString = sprintf(',%c%c%c',fliplr(num2str(dollars)));
  moneyString = ['$',fliplr(moneyString(2:end))];
  if (cents > 0),
    moneyString = [moneyString,'.',num2str(floor(cents*100),'%0.2i')];
  elseif centsFlag,
    moneyString = [moneyString,'.00'];
  end
  if (value < 0),
    moneyString = ['-',moneyString];
  end

end