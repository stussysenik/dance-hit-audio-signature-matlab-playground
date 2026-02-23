function dynamicRange = computeDynamicRange(segments, ~, ~)
% COMPUTEDYNAMICRANGE Compute local dynamic range via crest factor (Dimension 8).
%   dynamicRange = computeDynamicRange(segments, fs, config)
%
%   Crest factor = peak / RMS for each segment.
%   Higher values indicate more dynamic content.

    numSegments = size(segments, 2);
    dynamicRange = zeros(1, numSegments);

    for i = 1:numSegments
        seg = segments(:, i);
        peakVal = max(abs(seg));
        rmsVal = sqrt(mean(seg.^2));

        if rmsVal > eps
            crest = peakVal / rmsVal;
            % Typical crest factor range: 1 (square wave) to ~10 (very dynamic)
            % Normalize to [0, 1] using tanh scaling
            dynamicRange(i) = tanh((crest - 1) / 3);
        else
            dynamicRange(i) = 0;
        end
    end
end
