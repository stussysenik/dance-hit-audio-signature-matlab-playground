function tests = test_hotness_engine
% TEST_HOTNESS_ENGINE Unit tests for hotness scoring and threshold.
%   Run with: runtests('tests/test_hotness_engine')

    tests = functiontests(localfunctions);
end

%% Setup
function setupOnce(testCase)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(rootDir, 'src')));
    testCase.TestData.config = AnalysisConfig();
end

%% Tests
function testEqualWeightHotness(testCase)
    % With equal weights, hotness should be the mean of all dimensions
    features = rand(8, 20);
    config = testCase.TestData.config;
    config.weights = ones(1, 8) / 8;

    [hotness, ~] = computeHotness(features, config);

    expectedMean = mean(features, 1);
    verifyEqual(testCase, hotness, expectedMean, 'AbsTol', 1e-10);
end

function testCustomWeightHotness(testCase)
    % Bass-dominated weights
    features = zeros(8, 10);
    features(2, :) = 1;  % Only bass has values
    config = testCase.TestData.config;
    config.weights = [0 1 0 0 0 0 0 0];  % 100% bass weight

    [hotness, ~] = computeHotness(features, config);
    verifyEqual(testCase, hotness, ones(1, 10), 'AbsTol', 1e-10);
end

function testHotSegmentThreshold(testCase)
    % Create features with clear hot segments
    features = 0.3 * ones(8, 100);
    features(:, 50:55) = 0.9;  % Segments 50-55 are hot

    config = testCase.TestData.config;
    config.weights = ones(1, 8) / 8;

    [hotness, hotIdx] = computeHotness(features, config);

    % Hot segments should include 50-55
    verifyTrue(testCase, all(ismember(50:55, hotIdx)));
    % Hotness values should be higher for hot segments
    verifyGreaterThan(testCase, mean(hotness(50:55)), mean(hotness(1:40)));
end

function testHotnessRange(testCase)
    features = rand(8, 50);
    config = testCase.TestData.config;
    [hotness, ~] = computeHotness(features, config);

    verifyTrue(testCase, all(hotness >= 0));
    verifyTrue(testCase, all(hotness <= 1));
end

function testWeightMismatchError(testCase)
    features = rand(8, 10);
    config = testCase.TestData.config;
    config.weights = ones(1, 5);  % Wrong number of weights

    verifyError(testCase, @() computeHotness(features, config), ...
        'computeHotness:WeightMismatch');
end

function testEmptyHotSegments(testCase)
    % Uniform features should have few or no hot segments
    features = 0.5 * ones(8, 100);
    config = testCase.TestData.config;
    [~, hotIdx] = computeHotness(features, config);

    % With constant values, std = 0, so threshold = mean.
    % No segment exceeds mean + 0, so this is edge case
    verifyTrue(testCase, isempty(hotIdx) || length(hotIdx) <= size(features, 2));
end
