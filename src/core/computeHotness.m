function [hotness, hotIdx, threshold] = computeHotness(features, config)
% COMPUTEHOTNESS Compute weighted hotness score and identify hot segments.
%   [hotness, hotIdx, threshold] = computeHotness(features, config)
%
%   Input:
%     features - 8 x N normalized feature matrix
%     config   - AnalysisConfig struct (uses config.weights, config.hotThresholdSigma)
%
%   Output:
%     hotness   - 1 x N hotness score vector
%     hotIdx    - indices of "hot" segments (H > mean + sigma*std)
%     threshold - the computed threshold value

    if nargin < 2
        config = AnalysisConfig();
    end

    weights = config.weights(:);  % Column vector
    numDims = size(features, 1);

    % Ensure weights match dimensions
    if length(weights) ~= numDims
        error('computeHotness:WeightMismatch', ...
            'Weight vector length (%d) must match number of dimensions (%d).', ...
            length(weights), numDims);
    end

    % Normalize weights to sum to 1
    weights = weights / sum(weights);

    % Weighted sum: H(t) = Σ w_i × D_i(t)
    hotness = weights' * features;  % 1 x N

    % Threshold: mean + sigma * std
    mu = mean(hotness);
    sigma = std(hotness);
    threshold = mu + config.hotThresholdSigma * sigma;

    % Classify hot segments
    hotIdx = find(hotness > threshold);
end
