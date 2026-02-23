function blendPairs = findBlendSegments(feat1, feat2, hotIdx1, hotIdx2, timeAxis1, timeAxis2, K)
% FINDBLENDSEGMENTS Find top-K compatible segment pairs between two songs.
%   blendPairs = findBlendSegments(feat1, feat2, hotIdx1, hotIdx2, timeAxis1, timeAxis2, K)
%
%   Uses DTW alignment and hotness overlap to find the most compatible
%   segments for DJ blending between two songs.
%
%   Output:
%     blendPairs - struct array with fields: idx1, idx2, time1, time2, score

    if nargin < 7
        K = 5;
    end

    N1 = size(feat1, 2);
    N2 = size(feat2, 2);

    % Compute pairwise distance between hot segments
    % Focus on hot segments from both songs
    if isempty(hotIdx1); hotIdx1 = 1:N1; end
    if isempty(hotIdx2); hotIdx2 = 1:N2; end

    % Limit to valid indices
    hotIdx1 = hotIdx1(hotIdx1 <= N1);
    hotIdx2 = hotIdx2(hotIdx2 <= N2);

    % Compute feature distance for all hot-segment pairs
    numPairs = length(hotIdx1) * length(hotIdx2);
    pairScores = zeros(numPairs, 3);  % [idx1, idx2, distance]
    k = 0;

    for i = 1:length(hotIdx1)
        for j = 1:length(hotIdx2)
            k = k + 1;
            d = norm(feat1(:, hotIdx1(i)) - feat2(:, hotIdx2(j)));
            pairScores(k, :) = [hotIdx1(i), hotIdx2(j), d];
        end
    end

    pairScores = pairScores(1:k, :);

    % Sort by distance (ascending = most similar)
    [~, sortIdx] = sort(pairScores(:, 3));
    pairScores = pairScores(sortIdx, :);

    % Take top-K
    K = min(K, size(pairScores, 1));
    blendPairs = struct();

    for i = 1:K
        blendPairs(i).idx1 = pairScores(i, 1);
        blendPairs(i).idx2 = pairScores(i, 2);
        if ~isempty(timeAxis1) && pairScores(i, 1) <= length(timeAxis1)
            blendPairs(i).time1 = timeAxis1(pairScores(i, 1));
        else
            blendPairs(i).time1 = 0;
        end
        if ~isempty(timeAxis2) && pairScores(i, 2) <= length(timeAxis2)
            blendPairs(i).time2 = timeAxis2(pairScores(i, 2));
        else
            blendPairs(i).time2 = 0;
        end
        % Convert distance to similarity score [0, 1]
        maxDist = max(pairScores(:, 3)) + eps;
        blendPairs(i).score = 1 - pairScores(i, 3) / maxDist;
    end
end
