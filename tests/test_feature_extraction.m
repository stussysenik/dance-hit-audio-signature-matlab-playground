function tests = test_feature_extraction
% TEST_FEATURE_EXTRACTION Unit tests for all 8 feature extractors.
%   Run with: runtests('tests/test_feature_extraction')

    tests = functiontests(localfunctions);
end

%% Setup
function setupOnce(testCase)
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(rootDir, 'src')));
    testCase.TestData.config = AnalysisConfig();
    testCase.TestData.fs = 44100;

    % Generate a simple test signal: 2 seconds of sine + noise
    fs = 44100;
    t = (0:2*fs-1)' / fs;
    testCase.TestData.signal = 0.5 * sin(2*pi*100*t) + 0.1 * randn(length(t), 1);
    [testCase.TestData.segments, testCase.TestData.timeAxis] = ...
        windowSegment(testCase.TestData.signal, fs, testCase.TestData.config);
end

%% Audio Loading Tests
function testAudioLoadMono(testCase)
    % Create a temporary WAV file
    fs = 44100;
    signal = randn(fs, 1);  % 1 second
    tmpFile = [tempname '.wav'];
    audiowrite(tmpFile, signal, fs);

    [loaded, loadedFs] = audioLoad(tmpFile, testCase.TestData.config);
    verifyEqual(testCase, loadedFs, fs);
    verifyEqual(testCase, size(loaded, 2), 1);  % Mono

    delete(tmpFile);
end

function testAudioLoadStereo(testCase)
    fs = 44100;
    signal = randn(fs, 2);  % 1 second stereo
    tmpFile = [tempname '.wav'];
    audiowrite(tmpFile, signal, fs);

    [loaded, ~] = audioLoad(tmpFile, testCase.TestData.config);
    verifyEqual(testCase, size(loaded, 2), 1);  % Converted to mono

    delete(tmpFile);
end

function testAudioLoadUnsupported(testCase)
    verifyError(testCase, @() audioLoad('fake.midi', testCase.TestData.config), ...
        'audioLoad:UnsupportedFormat');
end

%% Segmentation Tests
function testSegmentCount(testCase)
    config = testCase.TestData.config;
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    sigLen = length(testCase.TestData.signal);

    expectedSegs = floor((sigLen - config.windowSamples) / config.hopSamples) + 1;
    verifyEqual(testCase, size(segments, 2), expectedSegs);
end

function testSegmentSize(testCase)
    config = testCase.TestData.config;
    segments = testCase.TestData.segments;
    verifyEqual(testCase, size(segments, 1), config.windowSamples);
end

%% Feature Extractor Tests
function testBPMDetection(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    [bpmStab, globalBPM] = computeBPM(segments, fs, config);
    verifySize(testCase, bpmStab, [1 size(segments, 2)]);
    verifyGreaterThan(testCase, globalBPM, 0);
    verifyTrue(testCase, all(bpmStab >= 0 & bpmStab <= 1.01));
end

function testBassEnergy(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    bass = computeBassEnergy(segments, fs, config);
    verifySize(testCase, bass, [1 size(segments, 2)]);
    verifyTrue(testCase, all(bass >= 0));
end

function testVocalPresence(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    vocal = computeVocalPresence(segments, fs, config);
    verifySize(testCase, vocal, [1 size(segments, 2)]);
    verifyTrue(testCase, all(vocal >= 0));
end

function testBeatStrength(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    beat = computeBeatStrength(segments, fs, config);
    verifySize(testCase, beat, [1 size(segments, 2)]);
    verifyTrue(testCase, all(beat >= 0));
end

function testSpectralFlux(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    flux = computeSpectralFlux(segments, fs, config);
    verifySize(testCase, flux, [1 size(segments, 2)]);
    verifyTrue(testCase, all(flux >= 0));
end

function testRhythmComplexity(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    rhythm = computeRhythmComplexity(segments, fs, config);
    verifySize(testCase, rhythm, [1 size(segments, 2)]);
    verifyTrue(testCase, all(rhythm >= 0));
end

function testHarmonicRichness(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    harmonic = computeHarmonicRichness(segments, fs, config);
    verifySize(testCase, harmonic, [1 size(segments, 2)]);
    verifyTrue(testCase, all(harmonic >= 0));
end

function testDynamicRange(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    dynamic = computeDynamicRange(segments, fs, config);
    verifySize(testCase, dynamic, [1 size(segments, 2)]);
    verifyTrue(testCase, all(dynamic >= 0 & dynamic <= 1));
end

%% Pipeline Test
function testExtractFeatures(testCase)
    segments = testCase.TestData.segments;
    fs = testCase.TestData.fs;
    config = testCase.TestData.config;

    [features, bpm] = extractFeatures(segments, fs, config);
    verifySize(testCase, features, [8 size(segments, 2)]);
    verifyTrue(testCase, all(features(:) >= 0 & features(:) <= 1));
    verifyGreaterThan(testCase, bpm, 0);
end

%% Normalization Test
function testNormalizeFeatures(testCase)
    raw = rand(8, 50) * 100;  % Random values 0-100
    normed = normalizeFeatures(raw);
    verifyTrue(testCase, all(normed(:) >= 0 & normed(:) <= 1));

    % Check that min is 0 and max is 1 for each row
    for d = 1:8
        verifyEqual(testCase, min(normed(d,:)), 0, 'AbsTol', 1e-10);
        verifyEqual(testCase, max(normed(d,:)), 1, 'AbsTol', 1e-10);
    end
end
