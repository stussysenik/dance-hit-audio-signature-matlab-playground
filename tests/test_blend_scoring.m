function tests = test_blend_scoring
% TEST_BLEND_SCORING Unit tests for blend score computation.
%   Run with: runtests('tests/test_blend_scoring')

    tests = functiontests(localfunctions);
end

%% Setup
function setupOnce(testCase)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(rootDir, 'src')));
    testCase.TestData.config = AnalysisConfig();
end

%% Tests
function testRankBlendsOutput(testCase)
    config = testCase.TestData.config;
    fs = 44100;

    % Create 3 synthetic tracks
    allResults = struct();
    for i = 1:3
        dur = 5;  % 5 seconds
        t = (0:dur*fs-1)'/fs;
        signal = 0.5*sin(2*pi*(80+i*20)*t) + 0.1*randn(length(t),1);
        [segments, timeAxis] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [hotness, hotIdx] = computeHotness(features, config);

        allResults(i).name = sprintf('test_track_%d', i);
        allResults(i).filePath = '';
        allResults(i).features = features;
        allResults(i).timeAxis = timeAxis;
        allResults(i).hotness = hotness;
        allResults(i).hotIdx = hotIdx;
        allResults(i).signal = signal;
        allResults(i).fs = fs;
    end

    blends = rankBlends(allResults, config);

    % Should have blend recommendations
    verifyGreaterThan(testCase, length(blends), 0);

    % Each blend should have required fields
    for i = 1:length(blends)
        verifyTrue(testCase, isfield(blends(i), 'trackA'));
        verifyTrue(testCase, isfield(blends(i), 'trackB'));
        verifyTrue(testCase, isfield(blends(i), 'score'));
        verifyTrue(testCase, isfield(blends(i), 'timeA'));
        verifyTrue(testCase, isfield(blends(i), 'timeB'));
    end
end

function testBlendScoresSorted(testCase)
    config = testCase.TestData.config;
    fs = 44100;

    allResults = struct();
    for i = 1:3
        dur = 5;
        t = (0:dur*fs-1)'/fs;
        signal = 0.5*sin(2*pi*(80+i*20)*t) + 0.1*randn(length(t),1);
        [segments, timeAxis] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [hotness, hotIdx] = computeHotness(features, config);

        allResults(i).name = sprintf('test_track_%d', i);
        allResults(i).filePath = '';
        allResults(i).features = features;
        allResults(i).timeAxis = timeAxis;
        allResults(i).hotness = hotness;
        allResults(i).hotIdx = hotIdx;
        allResults(i).signal = signal;
        allResults(i).fs = fs;
    end

    blends = rankBlends(allResults, config);

    % Verify sorted descending by score
    scores = [blends.score];
    verifyTrue(testCase, issorted(scores, 'descend'));
end

function testMetadataStore(testCase)
    store = MetadataStore();

    entry1 = struct('title', 'Test Track', 'artist', 'Test Artist', ...
        'bpm', 128, 'genre', 'House', 'origin', 'Berlin', ...
        'songwriters', {{'A. Writer'}}, 'dominant_features', 'Bass', ...
        'year', 2024, 'label', 'Test', 'key', '5A', ...
        'subgenre', 'Deep House', 'filename', 'test.wav');

    entry2 = struct('title', 'Test Track 2', 'artist', 'Other Artist', ...
        'bpm', 140, 'genre', 'Techno', 'origin', 'Detroit', ...
        'songwriters', {{'B. Writer'}}, 'dominant_features', 'Beat', ...
        'year', 2023, 'label', 'Test', 'key', '8B', ...
        'subgenre', 'Techno', 'filename', 'test2.wav');

    store.add(entry1);
    store.add(entry2);

    all = store.getAll();
    verifyEqual(testCase, length(all), 2);

    house = store.filterByGenre('house');
    verifyEqual(testCase, length(house), 1);
    verifyEqual(testCase, house.genre, 'House');

    berlin = store.filterByOrigin('Berlin');
    verifyEqual(testCase, length(berlin), 1);
end
