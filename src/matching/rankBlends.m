function blends = rankBlends(allResults, config)
% RANKBLENDS Compute and rank DJ blend recommendations across all songs.
%   blends = rankBlends(allResults, config)
%
%   Evaluates blend compatibility for all song pairs using:
%     - BPM compatibility
%     - Energy curve match (cross-correlation)
%     - Feature vector similarity (spectral complement)
%
%   Input:
%     allResults - struct array from quickstart (one per track)
%     config     - AnalysisConfig struct
%
%   Output:
%     blends - struct array sorted by score descending, fields:
%              trackA, trackB, timeA, timeB, score, bpmCompat,
%              energyMatch, spectralComplement

    if nargin < 2
        config = AnalysisConfig();
    end

    N = length(allResults);
    allBlends = struct('trackA', {}, 'trackB', {}, ...
                       'timeA', {}, 'timeB', {}, ...
                       'score', {}, 'bpmCompat', {}, ...
                       'energyMatch', {}, 'spectralComplement', {});

    % Detect global BPM for each track
    bpms = zeros(1, N);
    for i = 1:N
        [~, bpms(i)] = computeBPM([], allResults(i).fs, config);
        % Fallback: estimate from onset envelope
        if bpms(i) == 0 || isnan(bpms(i))
            bpms(i) = 120;  % Default
        end
    end

    % Try to get BPM from feature extraction
    for i = 1:N
        sig = allResults(i).signal;
        segs = windowSegment(sig, allResults(i).fs, config);
        [~, bpms(i)] = extractFeatures(segs, allResults(i).fs, config);
    end

    for i = 1:N
        for j = i+1:N
            % BPM compatibility
            bpmDiff = abs(bpms(i) - bpms(j));
            maxBpmDiff = 30;
            bpmCompat = max(0, 1 - bpmDiff / maxBpmDiff);

            % Also check for integer ratio compatibility
            ratio = max(bpms(i), bpms(j)) / min(bpms(i), bpms(j));
            if abs(ratio - round(ratio)) < 0.05
                bpmCompat = max(bpmCompat, 0.8);
            end

            % Find compatible segments
            pairs = findBlendSegments(...
                allResults(i).features, allResults(j).features, ...
                allResults(i).hotIdx, allResults(j).hotIdx, ...
                allResults(i).timeAxis, allResults(j).timeAxis, 3);

            for p = 1:length(pairs)
                % Energy curve match at segment level
                idx1 = pairs(p).idx1;
                idx2 = pairs(p).idx2;

                % Local energy correlation (use hotness as proxy)
                winSize = 5;
                range1 = max(1, idx1-winSize):min(size(allResults(i).features, 2), idx1+winSize);
                range2 = max(1, idx2-winSize):min(size(allResults(j).features, 2), idx2+winSize);

                e1 = allResults(i).hotness(range1);
                e2 = allResults(j).hotness(range2);

                % Resample to same length for correlation
                minLen = min(length(e1), length(e2));
                e1 = e1(1:minLen);
                e2 = e2(1:minLen);

                if minLen > 1
                    energyCorr = abs(corr(e1(:), e2(:)));
                    if isnan(energyCorr); energyCorr = 0.5; end
                else
                    energyCorr = 0.5;
                end

                % Spectral complement: low similarity in frequency = good
                f1 = allResults(i).features(:, idx1);
                f2 = allResults(j).features(:, idx2);
                featureSim = dot(f1, f2) / (norm(f1) * norm(f2) + eps);
                spectralComplement = 1 - abs(featureSim - 0.5);  % Best around 0.5 similarity

                % Composite blend score
                w = config.blendWeights;
                blendScore = w.bpm * bpmCompat + ...
                             w.energy * energyCorr + ...
                             w.spectral * spectralComplement + ...
                             w.key * pairs(p).score;

                entry = struct();
                entry.trackA = allResults(i).name;
                entry.trackB = allResults(j).name;
                entry.timeA = pairs(p).time1;
                entry.timeB = pairs(p).time2;
                entry.score = blendScore;
                entry.bpmCompat = bpmCompat;
                entry.energyMatch = energyCorr;
                entry.spectralComplement = spectralComplement;

                allBlends(end+1) = entry; %#ok<AGROW>
            end
        end
    end

    % Sort by score descending
    if ~isempty(allBlends)
        scores = [allBlends.score];
        [~, sortIdx] = sort(scores, 'descend');
        blends = allBlends(sortIdx);
    else
        blends = allBlends;
    end
end
