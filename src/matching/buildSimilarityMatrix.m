function simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell)
% BUILDSIMILARITYMATRIX Build NxN cosine similarity matrix across songs.
%   simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell)
%
%   Input:
%     featureCell - cell array of 8xN feature matrices (one per song)
%     hotIdxCell  - cell array of hot segment index vectors
%
%   Output:
%     simMatrix - NxN symmetric matrix with cosine similarities

    N = length(featureCell);
    simMatrix = eye(N);

    % Compute mean feature vector across hot segments for each song
    meanVectors = zeros(size(featureCell{1}, 1), N);
    for i = 1:N
        feat = featureCell{i};
        hotIdx = hotIdxCell{i};

        if ~isempty(hotIdx)
            validIdx = hotIdx(hotIdx <= size(feat, 2));
            if ~isempty(validIdx)
                meanVectors(:, i) = mean(feat(:, validIdx), 2);
            else
                meanVectors(:, i) = mean(feat, 2);
            end
        else
            meanVectors(:, i) = mean(feat, 2);
        end
    end

    % Compute pairwise cosine similarity
    for i = 1:N
        for j = i+1:N
            a = meanVectors(:, i);
            b = meanVectors(:, j);
            sim = dot(a, b) / (norm(a) * norm(b) + eps);
            simMatrix(i, j) = sim;
            simMatrix(j, i) = sim;
        end
    end
end
