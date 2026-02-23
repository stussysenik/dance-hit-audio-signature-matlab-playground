function [dist, path] = computeDTW(seq1, seq2)
% COMPUTEDTW Dynamic Time Warping between two feature sequences.
%   [dist, path] = computeDTW(seq1, seq2)
%
%   Input:
%     seq1 - D x M feature matrix (D dimensions, M time steps)
%     seq2 - D x N feature matrix (D dimensions, N time steps)
%
%   Output:
%     dist - DTW distance (scalar)
%     path - Kx2 matrix of aligned index pairs [i, j]

    M = size(seq1, 2);
    N = size(seq2, 2);

    % Cost matrix: Euclidean distance between feature vectors
    costMatrix = zeros(M, N);
    for i = 1:M
        for j = 1:N
            costMatrix(i, j) = norm(seq1(:, i) - seq2(:, j));
        end
    end

    % Accumulated cost matrix
    D = inf(M + 1, N + 1);
    D(1, 1) = 0;

    for i = 1:M
        for j = 1:N
            D(i+1, j+1) = costMatrix(i, j) + min([D(i, j+1), D(i+1, j), D(i, j)]);
        end
    end

    dist = D(M+1, N+1);

    % Traceback to find optimal path
    path = zeros(M + N, 2);
    k = 1;
    i = M;
    j = N;
    path(k, :) = [i, j];

    while i > 1 || j > 1
        if i == 1
            j = j - 1;
        elseif j == 1
            i = i - 1;
        else
            [~, idx] = min([D(i, j), D(i, j+1), D(i+1, j)]);
            switch idx
                case 1
                    i = i - 1;
                    j = j - 1;
                case 2
                    i = i - 1;
                case 3
                    j = j - 1;
            end
        end
        k = k + 1;
        path(k, :) = [i, j];
    end

    path = flipud(path(1:k, :));
end
