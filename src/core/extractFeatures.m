function [features, globalBPM] = extractFeatures(segments, fs, config)
% EXTRACTFEATURES Orchestrate all 8 feature extractors into an 8xN matrix.
%   [features, globalBPM] = extractFeatures(segments, fs, config)
%
%   Returns:
%     features  - 8 x N matrix (N segments), normalized to [0, 1]
%     globalBPM - detected global BPM of the track
%
%   Dimensions:
%     1: BPM Stability
%     2: Bass Energy
%     3: Vocal Presence
%     4: Beat Strength
%     5: Spectral Flux
%     6: Rhythm Complexity
%     7: Harmonic Richness
%     8: Dynamic Range

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    features = zeros(config.numDimensions, numSegments);

    % Dimension 1: BPM Stability
    [features(1, :), globalBPM] = computeBPM(segments, fs, config);

    % Dimension 2: Bass Energy
    features(2, :) = computeBassEnergy(segments, fs, config);

    % Dimension 3: Vocal Presence
    features(3, :) = computeVocalPresence(segments, fs, config);

    % Dimension 4: Beat Strength
    features(4, :) = computeBeatStrength(segments, fs, config);

    % Dimension 5: Spectral Flux
    features(5, :) = computeSpectralFlux(segments, fs, config);

    % Dimension 6: Rhythm Complexity
    features(6, :) = computeRhythmComplexity(segments, fs, config);

    % Dimension 7: Harmonic Richness
    features(7, :) = computeHarmonicRichness(segments, fs, config);

    % Dimension 8: Dynamic Range
    features(8, :) = computeDynamicRange(segments, fs, config);

    % Normalize all dimensions to [0, 1] per track
    features = normalizeFeatures(features);
end
