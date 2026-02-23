function tests = test_segment_index
% TEST_SEGMENT_INDEX Unit and performance tests for O(1) SegmentIndex.
%   Run with: runtests('tests/test_segment_index')

    tests = functiontests(localfunctions);
end

%% Setup
function setupOnce(testCase)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(rootDir, 'src')));
    config = AnalysisConfig();
    testCase.TestData.config = config;

    % Create synthetic test results (3 tracks, 5 seconds each)
    fs = 44100;
    allResults = struct();
    for i = 1:5
        dur = 5;
        t = (0:dur*fs-1)'/fs;
        signal = 0.5*sin(2*pi*(60+i*30)*t) + 0.1*randn(length(t),1);
        [segments, timeAxis] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [hotness, hotIdx] = computeHotness(features, config);

        allResults(i).name = sprintf('test_track_%d.wav', i);
        allResults(i).features = features;
        allResults(i).timeAxis = timeAxis;
        allResults(i).hotness = hotness;
        allResults(i).hotIdx = hotIdx;
        allResults(i).signal = signal;
        allResults(i).fs = fs;
    end
    testCase.TestData.allResults = allResults;
end

%% Index Build Test
function testBuildIndex(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;

    idx = SegmentIndex(allResults, config);
    stats = idx.getStats();

    verifyEqual(testCase, stats.numSongs, 5);
    verifyGreaterThan(testCase, stats.totalSegments, 0);
    verifyGreaterThan(testCase, stats.numBuckets, 0);
end

%% Query Similar Test
function testQuerySimilar(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    % Query with a known feature vector
    queryVec = allResults(1).features(:, 1);
    results = idx.query(queryVec, 5);

    verifyEqual(testCase, length(results), 5);
    % First result should be from song 1, segment 1 (exact match)
    verifyEqual(testCase, results(1).songIdx, 1);
    verifyEqual(testCase, results(1).segIdx, 1);
end

%% Query Hot Test
function testQueryHot(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    results = idx.queryHot(10);
    verifyEqual(testCase, length(results), 10);

    % Should be sorted by hotness descending
    for i = 1:length(results)-1
        verifyGreaterThanOrEqual(testCase, results(i).hotness, results(i+1).hotness);
    end
end

%% Query By Dimension Test
function testQueryByDimension(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    % Query bass energy (dim 2) in range [0.5, 1.0]
    results = idx.queryByDimension(2, 0.5, 1.0, 10);

    % All results should have bass energy >= 0.5
    for i = 1:length(results)
        verifyGreaterThanOrEqual(testCase, results(i).features(2), 0.5);
    end
end

%% Query Similar To Segment Test
function testQuerySimilarToSegment(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    results = idx.querySimilarToSegment(1, 5, 5);

    % Should not include the query segment itself
    for i = 1:length(results)
        if results(i).songIdx == 1
            verifyTrue(testCase, results(i).segIdx ~= 5);
        end
    end
end

%% Performance Test: O(1) Query Speed
function testQueryPerformance(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    queryVec = rand(8, 1);

    % Warm up
    idx.query(queryVec, 10);

    % Time 100 queries
    tic;
    for i = 1:100
        queryVec = rand(8, 1);
        idx.query(queryVec, 10);
    end
    elapsed = toc;

    avgQueryMs = elapsed / 100 * 1000;
    fprintf('Average query time: %.2f ms\n', avgQueryMs);

    % Should be fast (< 50ms per query even on slow machines)
    verifyLessThan(testCase, avgQueryMs, 50);
end

%% Stats Test
function testPrintStats(testCase)
    allResults = testCase.TestData.allResults;
    config = testCase.TestData.config;
    idx = SegmentIndex(allResults, config);

    % Just verify it doesn't error
    idx.printStats();
    verifyTrue(testCase, true);
end
