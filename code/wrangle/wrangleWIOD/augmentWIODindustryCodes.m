% Augment WIOD struct with 3-letter industry codes from
%
%   'World Input Output Network', Francesca Cerina, Zhen Zhu, Alessandro
%   Chessa, Massimo Riccaboni, IMT LUCCA EIC WORKING PAPER SERIES 06 (2014) 

announceFunction()

% Load WIOD data
clear
load('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')

industryCodes =  {'Agr' 'Min' 'Fod' 'Tex' 'Lth' 'Wod' 'Pup' 'Cok' 'Chm' 'Rub' 'Omn' 'Met' 'Mch' 'Elc' 'Tpt' 'Mnf' 'Ele' 'Cst' 'Sal' 'Whl' 'Rtl' 'Htl' 'Ldt' 'Wtt' 'Ait' 'Otr' 'Pst' 'Fin' 'Est' 'Obs' 'Pub' 'Edu' 'Hth' 'Ocm' 'Pvt'}';
countryCodes  = WIOD(1).countryCodes;

nYears = length(WIOD);
for iYear = 1:nYears
   WIOD(iYear).industryCodes     = industryCodes;
   WIOD(iYear).industryCodesFull = repmat(industryCodes, [41 1]);
   
   WIOD(iYear).countryNamesFull  = repmat(countryCodes,  [41 1]);
end

save('./wrangle/wrangleWIOD/WIOD.mat', 'WIOD')