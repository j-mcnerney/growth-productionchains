% Loads the WIOD input-output data, saves it to struct array, and save this
% to a .mat file for later use.

announceFunction()

clear all
tic

% Construct list of files to load
dataDirectory = '../data/WIOD';

% Order files in chronological order
fileList = [
    {'WIOT95_ROW_Apr12.xlsx'}
    {'WIOT96_ROW_Apr12.xlsx'}
    {'WIOT97_ROW_Apr12.xlsx'}
    {'WIOT98_ROW_Apr12.xlsx'}
    {'WIOT99_ROW_Apr12.xlsx'}
    {'WIOT00_ROW_Apr12.xlsx'}
    {'WIOT01_ROW_Apr12.xlsx'}
    {'WIOT02_ROW_Apr12.xlsx'}
    {'WIOT03_ROW_Apr12.xlsx'}
    {'WIOT04_ROW_Apr12.xlsx'}
    {'WIOT05_ROW_Apr12.xlsx'}
    {'WIOT06_ROW_Apr12.xlsx'}
    {'WIOT07_ROW_Apr12.xlsx'}
    {'WIOT08_ROW_Sep12.xlsx'}
    {'WIOT09_ROW_Sep12.xlsx'}
    {'WIOT10_ROW_Sep12.xlsx'}
    {'WIOT11_ROW_Sep12.xlsx'}
];
nFiles = length(fileList);

% Set parameters for grabbing data
row0 = 7;  % These give the upper left cell for selecting the
col0 = 5;  % IO table itself

nCountries   = 41;
nIndustries  = 35;
nWorldIndustries = nCountries * nIndustries;
nFinalDemandCategories = 5;

% Grab data for each year
for iFile = 1:nFiles
   file = fileList{iFile}
   [~,~,rawWorksheetCell] = xlsread( [dataDirectory,'/',file] );
   
   WIOD(iFile).fileName = file;
   
   % Get year
   WIOD(iFile).year = str2num( rawWorksheetCell{1,1}(end-3:end) )
   
   % # countries and industries
   WIOD(iFile).nCountries  = nCountries;
   WIOD(iFile).nIndustries = nIndustries;
   
   % Get IO table
   dataRangeRows = [row0 : row0 + nWorldIndustries - 1];
   dataRangeCols = [col0 : col0 + nWorldIndustries - 1];
   WIOD(iFile).IOtable = rawWorksheetCell(dataRangeRows, dataRangeCols);
   WIOD(iFile).IOtable = cell2mat(WIOD(iFile).IOtable);
   
   % Get value added rows
   dataRangeRows = [row0 + nWorldIndustries + 1 : row0 + nWorldIndustries + 5];
   dataRangeCols = [col0 : col0 + nWorldIndustries - 1];
   WIOD(iFile).ValueAddedRows = rawWorksheetCell(dataRangeRows, dataRangeCols);
   WIOD(iFile).ValueAddedRows = cell2mat(WIOD(iFile).ValueAddedRows);
   
   % Get international transport margins
   dataRangeRows = [row0 + nWorldIndustries + 6 : row0 + nWorldIndustries + 6];
   dataRangeCols = [col0 : col0 + nWorldIndustries - 1];
   WIOD(iFile).transportMargins = rawWorksheetCell(dataRangeRows, dataRangeCols);
   WIOD(iFile).transportMargins = cell2mat(WIOD(iFile).transportMargins);
   
   % Get final demand columns
   dataRangeRows = [row0 : row0 + nWorldIndustries - 1];
   dataRangeCols = [col0 + nWorldIndustries : col0 + nWorldIndustries + nFinalDemandCategories * nCountries - 1];
   WIOD(iFile).FinalDemandCols = rawWorksheetCell(dataRangeRows, dataRangeCols);
   WIOD(iFile).FinalDemandCols = cell2mat(WIOD(iFile).FinalDemandCols);
   
   % Get other cells
   dataRangeRows = [row0 + nWorldIndustries + 1 : row0 + nWorldIndustries + 6];
   dataRangeCols = [col0 + nWorldIndustries : col0 + nWorldIndustries + nFinalDemandCategories * nCountries - 1];
   WIOD(iFile).OtherCells = rawWorksheetCell(dataRangeRows, dataRangeCols);
   WIOD(iFile).OtherCells = cell2mat(WIOD(iFile).OtherCells);
   
   % Country names and industry names
   WIOD(iFile).countryCodesFull  = rawWorksheetCell(7:7 + nCountries*nIndustries - 1,3);
   WIOD(iFile).countryCodes      = unique(WIOD(iFile).countryCodesFull, 'stable');

   WIOD(iFile).industryNamesFull = rawWorksheetCell(7:7 + nCountries*nIndustries - 1,2);
   WIOD(iFile).industryNames     = rawWorksheetCell(7:7+nIndustries-1,2);
   
   % Units and documentation
   WIOD(iFile).units = 'millions of US$, current prices';
   WIOD(iFile).doc   = 'Industry-by-industry IO tables from the World Input Output Database (WIOD)';
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')
toc
