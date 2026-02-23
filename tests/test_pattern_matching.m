function tests = test_pattern_matching
% TEST_PATTERN_MATCHING Unit tests for similarity matrix and DTW.
%   Run with: runtests('tests/test_pattern_matching')

    tests = functiontests(localfunctions);
end

%% Setup
function setupOnce(testCase)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(rootDir, 'src')));
    testCase.TestData.config = AnalysisConfig();
end

%% Similarity Matrix Tests
function testSimilarityMatrixSize(testCase)
    N = 5;
    featureCell = cell(1, N);
    hotIdxCell = cell(1, N);
    for i = 1:N
        featureCell{i} = rand(8, 20);
        hotIdxCell{i} = [5 10 15];
    end

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);
    verifySize(testCase, simMatrix, [N N]);
end

function testSimilarityMatrixDiagonal(testCase)
    N = 3;
    featureCell = cell(1, N);
    hotIdxCell = cell(1, N);
    for i = 1:N
        featureCell{i} = rand(8, 20);
        hotIdxCell{i} = [5 10 15];
    end

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);

    % Diagonal should be 1.0
    for i = 1:N
        verifyEqual(testCase, simMatrix(i,i), 1.0, 'AbsTol', 1e-10);
    end
end

function testSimilarityMatrixSymmetric(testCase)
    N = 4;
    featureCell = cell(1, N);
    hotIdxCell = cell(1, N);
    for i = 1:N
        featureCell{i} = rand(8, 20);
        hotIdxCell{i} = randi(20, 1, 5);
    end

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);
    verifyEqual(testCase, simMatrix, simMatrix', 'AbsTol', 1e-10);
end

function testSimilarityIdenticalSongs(testCase)
    feat = rand(8, 20);
    featureCell = {feat, feat, feat};
    hotIdxCell = {[5 10], [5 10], [5 10]};

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);

    % All similarities should be 1.0 (identical songs)
    verifyEqual(testCase, simMatrix, ones(3), 'AbsTol', 1e-10);
end

%% DTW Tests
function testDTWSelfComparison(testCase)
    seq = rand(8, 15);
    [dist, path] = computeDTW(seq, seq);

    verifyLessThan(testCase, dist, 1e-10);
    % Path should be diagonal
    verifyEqual(testCase, path(:,1), path(:,2));
end

function testDTWDistance(testCase)
    seq1 = rand(8, 10);
    seq2 = rand(8, 12);

    [dist, path] = computeDTW(seq1, seq2);

    verifyGreaterThan(testCase, dist, 0);
    verifyGreaterThanOrEqual(testCase, size(path, 1), max(10, 12));
end

%% Blend Segment Tests
function testFindBlendSegments(testCase)
    feat1 = rand(8, 30);
    feat2 = rand(8, 25);
    hotIdx1 = [5 10 15 20 25];
    hotIdx2 = [3 8 13 18 23];
    timeAxis1 = (1:30) * 0.25;
    timeAxis2 = (1:25) * 0.25;

    pairs = findBlendSegments(feat1, feat2, hotIdx1, hotIdx2, ...
                              timeAxis1, timeAxis2, 5);

    verifyEqual(testCase, length(pairs), 5);
    for i = 1:5
        verifyGreaterThanOrEqual(testCase, pairs(i).score, 0);
        verifyLessThanOrEqual(testCase, pairs(i).score, 1);
    end
end
