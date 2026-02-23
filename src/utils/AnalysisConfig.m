function config = AnalysisConfig()
% ANALYSISCONFIG Returns default analysis configuration struct.
%   config = AnalysisConfig() returns a struct with all configurable
%   parameters for the Dance Hit Audio Signature system.

    config = struct();

    % Audio loading
    config.targetSampleRate = 44100;       % Hz
    config.supportedFormats = {'.wav', '.flac', '.mp3', '.ogg', '.m4a'};

    % Segmentation
    config.windowDuration = 0.5;           % seconds (500ms)
    config.overlapRatio = 0.5;             % 50% overlap
    config.windowSamples = round(config.windowDuration * config.targetSampleRate);
    config.hopSamples = round(config.windowSamples * (1 - config.overlapRatio));

    % Feature extraction
    config.fftSize = 2048;
    config.numDimensions = 8;
    config.dimensionNames = {'BPM Stability', 'Bass Energy', 'Vocal Presence', ...
                             'Beat Strength', 'Spectral Flux', 'Rhythm Complexity', ...
                             'Harmonic Richness', 'Dynamic Range'};

    % Frequency bands
    config.bassRange = [20 250];           % Hz
    config.vocalRange = [300 3400];        % Hz

    % Hotness scoring
    config.weights = ones(1, 8) / 8;       % Equal weights by default
    config.hotThresholdSigma = 1.0;        % Segments > mean + 1*sigma are "hot"

    % BPM detection
    config.bpmRange = [60 200];            % Search range for tempo

    % Blend scoring weights
    config.blendWeights = struct();
    config.blendWeights.bpm = 0.3;
    config.blendWeights.key = 0.2;
    config.blendWeights.energy = 0.3;
    config.blendWeights.spectral = 0.2;

    % Cache
    config.cacheDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'data', 'cache');
    config.enableCache = true;

    % API
    config.apiPort = 8080;

    % Demo
    config.demoDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'data', 'demo');
    config.metadataDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'data', 'metadata');
    config.numDemoTracks = 10;
end
