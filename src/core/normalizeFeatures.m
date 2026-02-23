function featNorm = normalizeFeatures(features)
% NORMALIZEFEATURES Min-max normalize each dimension to [0, 1].
%   featNorm = normalizeFeatures(features)
%
%   Input:  features - 8 x N matrix (raw feature values)
%   Output: featNorm - 8 x N matrix (normalized to [0, 1] per row)

    featNorm = features;
    numDims = size(features, 1);

    for d = 1:numDims
        row = features(d, :);
        minVal = min(row);
        maxVal = max(row);
        rangeVal = maxVal - minVal;

        if rangeVal > eps
            featNorm(d, :) = (row - minVal) / rangeVal;
        else
            % Constant dimension: set to 0.5
            featNorm(d, :) = 0.5;
        end
    end
end
