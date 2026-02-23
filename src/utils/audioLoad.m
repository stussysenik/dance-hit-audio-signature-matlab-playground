function [signal, fs] = audioLoad(filePath, config)
% AUDIOLOAD Load an audio file, convert to mono, resample to target rate.
%   [signal, fs] = audioLoad(filePath) loads the audio file at filePath,
%   converts to mono (if stereo), and resamples to 44100 Hz.
%
%   [signal, fs] = audioLoad(filePath, config) uses custom config.

    if nargin < 2
        config = AnalysisConfig();
    end

    % Validate file exists
    if ~isfile(filePath)
        error('audioLoad:FileNotFound', 'File not found: %s', filePath);
    end

    % Check supported format
    [~, ~, ext] = fileparts(filePath);
    if ~ismember(lower(ext), config.supportedFormats)
        error('audioLoad:UnsupportedFormat', ...
            'Unsupported format: %s. Supported: %s', ...
            ext, strjoin(config.supportedFormats, ', '));
    end

    % Read audio
    [signal, fs] = audioread(filePath);

    % Convert to mono if stereo
    if size(signal, 2) > 1
        signal = mean(signal, 2);
    end

    % Resample if needed
    if fs ~= config.targetSampleRate
        signal = resample(signal, config.targetSampleRate, fs);
        fs = config.targetSampleRate;
    end
end
