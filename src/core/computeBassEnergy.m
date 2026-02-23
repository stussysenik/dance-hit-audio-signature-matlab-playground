function bassEnergy = computeBassEnergy(segments, fs, config)
% COMPUTEBASSENERGY Compute RMS energy in 20-250 Hz band (Dimension 2).
%   bassEnergy = computeBassEnergy(segments, fs, config)
%
%   Uses FFT-based bandpass filtering to isolate the bass frequency range
%   and computes RMS energy per segment.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    bassEnergy = zeros(1, numSegments);

    % Frequency axis for FFT
    freqs = (0:winLen-1) * fs / winLen;

    % Bass band mask (20-250 Hz)
    bassMask = (freqs >= config.bassRange(1) & freqs <= config.bassRange(2)) | ...
               (freqs >= fs - config.bassRange(2) & freqs <= fs - config.bassRange(1));

    for i = 1:numSegments
        seg = segments(:, i) .* hann(winLen);
        spec = fft(seg);

        % Isolate bass frequencies
        bassSpec = spec .* bassMask';
        bassSignal = real(ifft(bassSpec));

        % RMS energy
        bassEnergy(i) = sqrt(mean(bassSignal.^2));
    end
end
