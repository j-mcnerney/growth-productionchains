function reportWIODstats()
global WorldEconomy trophicStats returnStats gammaStats growthStats H_overTime covarianceStats ap pp

announceFunction()

iYear = 15; % choose year
chosenYear = WorldEconomy(iYear).t;

% Number of industries and regions
nIndustries = WorldEconomy(1).nIndustries;
nCountries  = WorldEconomy(1).nCountries;
dispc( ['Number of industries: ',num2str(nIndustries)] )
dispc( ['Number of regions:    ',num2str(nCountries)] )

% Percent of world GDP represented by WIOD
countriesGDP = WorldEconomy(iYear).GDPvec;
countriesGDP = sum( countriesGDP( 1 : (nCountries-1)*nIndustries ) );   %All countries except ROW
worldGDP     = WorldEconomy(iYear).GDP;
countriesGDPshareOfWorldGDP = countriesGDP / worldGDP;
dispc( ['% of world GDP of 40 countries (less ROW) in ',num2str(WorldEconomy(iYear).t),': ',num2str(countriesGDPshareOfWorldGDP)] )

% Labor fraction of value added
mask = ~isnan(WorldEconomy(iYear).LaborIncome)' & ~isnan(WorldEconomy(iYear).Vvec);
totalLaborPayments = sum( WorldEconomy(iYear).LaborIncome(mask) );
totalValueAdded    = sum( WorldEconomy(iYear).Vvec(mask)        );
aveLaborFraction   = totalLaborPayments / totalValueAdded;
dispc( ['Aver. labor income fraction of value added in year ',num2str(chosenYear),': ',num2str(aveLaborFraction)] )