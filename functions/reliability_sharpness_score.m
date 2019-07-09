function Result = reliability_sharpness_score(ProbabilisticPrognose)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    ProbabilisticPrognose.Indicator_10(find(ProbabilisticPrognose.Leistung <= ProbabilisticPrognose.Quantile_10)) = 1;

end

