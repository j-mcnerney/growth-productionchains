function productivityStats = computeProductivityStatistics(PWTselectedData)

announceFunction()

% TFP levels
TFPlevel_MXR_ST = PWTselectedData.TFPlevel;                    % market exchange rates, standard
TFPlevel_PPP_ST = PWTselectedData.TFPlevelPPP;                 % PPP, standard
TFPlevel_MXR_WR = PWTselectedData.TFPlevel_welfareRelevant;    % market exchange rates, welfare-relevant
TFPlevel_PPP_WR = PWTselectedData.TFPlevelPP_welfareRelevant;  % PP, welfare-relevant

% Annual TFP growth rates
TFPgrowthMXRST_overTime = diff( log(TFPlevel_MXR_ST), 1, 2);   %log return
TFPgrowthPPPST_overTime = diff( log(TFPlevel_PPP_ST), 1, 2);   %log return
TFPgrowthMXRWR_overTime = diff( log(TFPlevel_MXR_WR), 1, 2);   %log return
TFPgrowthPPPWR_overTime = diff( log(TFPlevel_PPP_WR), 1, 2);   %log return

% Time-averaged TFP growth rate over whole period
TFPgrowthMXRST_timeAve  = sum(TFPgrowthMXRST_overTime(:,1:end-2), 2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)
TFPgrowthPPPST_timeAve  = sum(TFPgrowthPPPST_overTime(:,1:end-2), 2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)
TFPgrowthMXRWR_timeAve  = sum(TFPgrowthMXRWR_overTime(:,1:end-2), 2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)
TFPgrowthPPPWR_timeAve  = sum(TFPgrowthPPPWR_overTime(:,1:end-2), 2) / 14;   % Average returns over the period 1995-2009 (last 2 years have NaN price indices)

% Store quantities
productivityStats.TFPlevel_MXR_ST         = TFPlevel_MXR_ST;
productivityStats.TFPlevel_PPP_ST         = TFPlevel_PPP_ST;
productivityStats.TFPlevel_MXR_WR         = TFPlevel_MXR_WR;
productivityStats.TFPlevel_PPP_WR         = TFPlevel_PPP_WR;

productivityStats.TFPgrowthMXRST_overTime = TFPgrowthMXRST_overTime;
productivityStats.TFPgrowthPPPST_overTime = TFPgrowthPPPST_overTime;
productivityStats.TFPgrowthMXRWR_overTime = TFPgrowthMXRWR_overTime;
productivityStats.TFPgrowthPPPWR_overTime = TFPgrowthPPPWR_overTime;

productivityStats.TFPgrowthMXRST_timeAve  = TFPgrowthMXRST_timeAve;
productivityStats.TFPgrowthPPPST_timeAve  = TFPgrowthPPPST_timeAve;
productivityStats.TFPgrowthMXRWR_timeAve  = TFPgrowthMXRWR_timeAve;
productivityStats.TFPgrowthPPPWR_timeAve  = TFPgrowthPPPWR_timeAve;

