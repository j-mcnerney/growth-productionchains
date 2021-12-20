% This scripts computes a number of aggregates from the WIOD data which
% are important and present in the data but not available in varaibles that
% make them obvious to see.  It creates a set of variables and store them
% in the WIOD struct.

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')

nCountries       = WIOD(1).nCountries;
nIndustries      = WIOD(1).nIndustries;
nIndustriesFull  = nCountries * nIndustries;
nYears           = length(WIOD);

for iYear = 1:nYears
   % Grab 4 basic parts of the data:
   %  1- IO-table
   %  2- final demand columns
   %  3- value added rows
   %  4- transport margins
   IOtable          = WIOD(iYear).IOtable;
   FinalDemandCols  = WIOD(iYear).FinalDemandCols;
   ValueAddedRows   = WIOD(iYear).ValueAddedRows;
   transportMargins = WIOD(iYear).transportMargins;
   nValAddedRows    = size(ValueAddedRows,1);
   nFinDemandCols   = size(FinalDemandCols,2);
   
   
   % Construct a SAM-like matrix for easy-checking that row sums equal col
   % sums and to show how components fit together.
   cornerZeros1  = zeros(nValAddedRows, nFinDemandCols);
   cornerZeros2  = zeros(1, nFinDemandCols);
   SAMmatrix     = [     IOtable       FinalDemandCols      
                      ValueAddedRows     cornerZeros1
                     transportMargins    cornerZeros2  ];
                  
   % Check that row sums equal column sums
   rowSum = sum(SAMmatrix(1:41,:), 2)';
   colSum = sum(SAMmatrix(:,1:41), 1);
   rowSums_over_colSums = [colSum ./ rowSum]   %check
   
   
   % Compute some basic aggregates on the income side
   valueAddedBasicPrices = ValueAddedRows(end,:);
   netTaxesOnProducts    = ValueAddedRows(1,:);
   
   % Compute some basic aggregates on the expenditure side
   finalDemandLessNX     = sum(FinalDemandCols, 2);
   
   imports          = zeros(nIndustriesFull,1);
   exports          = zeros(nIndustriesFull,1);
   countryCodesFull = WIOD(1).countryCodesFull;
   for i = 1:nIndustriesFull
      % Locate indices of foreign countries for this industry
      countryOf_i       = countryCodesFull(i);
      isForeignIndustry = ~strcmp(countryOf_i, countryCodesFull);
      
      imports(i) = sum( IOtable(isForeignIndustry, i) );
      exports(i) = sum( IOtable(i, isForeignIndustry) );
   end
   netExports = exports - imports;
   
   
   % Compute GDP for each industry using the income approach and the
   % expenditure approach
   GDPincome = valueAddedBasicPrices + netTaxesOnProducts + transportMargins;
   GDPexpend = finalDemandLessNX + netExports;
   
   
   % Compute GDP for each country using the income approach and the
   % expenditure approach
   GDPincome_byCountry = zeros(nCountries,1);
   GDPexpend_byCountry = zeros(nCountries,1);
   countryCodes = WIOD(1).countryCodes;
   for c = 1:nCountries
      thisCountry        = countryCodes(c);
      isDomesticIndustry = strcmp(thisCountry, countryCodesFull);
      
      GDPincome_byCountry(c) = sum( GDPincome(isDomesticIndustry) );
      GDPexpend_byCountry(c) = sum( GDPexpend(isDomesticIndustry) );
   end
   GDPincome_over_GDPexpend = [GDPincome_byCountry ./ GDPexpend_byCountry]  %check
   
   
   % Show SAM matrix
   %seematrix( log10(abs(SAMmatrixSmall)) )
   %todo: Why are there off-diagonal elements in the final demand matrix?
   
   
   % Store
   WIOD(iYear).nIndustriesFull       = nIndustriesFull;
   WIOD(iYear).nValAddedRows         = nValAddedRows;
   WIOD(iYear).nFinDemandCols        = nFinDemandCols;
   WIOD(iYear).SAMmatrix             = SAMmatrix;
   WIOD(iYear).valueAddedBasicPrices = valueAddedBasicPrices;
   WIOD(iYear).netTaxesOnProducts    = netTaxesOnProducts;
   WIOD(iYear).finalDemandLessNX     = finalDemandLessNX;
   WIOD(iYear).imports               = imports;
   WIOD(iYear).exports               = exports;
   WIOD(iYear).netExports            = netExports;
   WIOD(iYear).GDPincome             = GDPincome;
   WIOD(iYear).GDPexpend             = GDPexpend;
   WIOD(iYear).GDPincome_byCountry   = GDPincome_byCountry;
   WIOD(iYear).GDPexpend_byCountry   = GDPexpend_byCountry;
   WIOD(iYear).SAMdocumentation      = ['SAMmatrix = [     IOtable       FinalDemandCols ] = [       IOtable          FinalDemandCols ]'
                                        '            [  ValueAddedRows       (zeros)     ]   [   netTaxesOnProducts       (zeros)     ]'
                                        '            [ transportMargins      (zeros)     ]   [ valueAddedBasicPrices      (zeros)     ]'
                                        '                                                    [    transportMargins        (zeros)     ]'
                                        '                                                                                              '
                                        'netExports = exports - imports                                                                '
                                        'GDPincome = valueAddedBasicPrices + netTaxesOnProducts + transportMargins                     '
                                        'GDPexpend = finalDemandLessNX + netExports                                                    '];
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')



%for iYear = 1:nYears
%   WIOD = rmfield(WIOD, 'SAMstructure');
%end