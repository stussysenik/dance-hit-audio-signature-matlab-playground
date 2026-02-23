function C = vizColors()
% VIZCOLORS Centralized color palette for all visualizations.
%   C = vizColors() returns a struct with all color definitions.
%
%   Color Psychology Rationale (each dimension color chosen for meaning):
%
%   1. BPM Stability  → Steel Blue     — Trust, reliability, steadiness
%   2. Bass Energy    → Deep Crimson   — Power, physical force, primal
%   3. Vocal Presence → Warm Amber     — Human warmth, emotional connection
%   4. Beat Strength  → Burnt Orange   — Impact, urgency, percussive action
%   5. Spectral Flux  → Electric Cyan  — Change, movement, transformation
%   6. Rhythm Complex → Deep Purple    — Sophistication, layered complexity
%   7. Harmonic Rich  → Emerald Green  — Organic fullness, tonal balance
%   8. Dynamic Range  → Hot Magenta    — Contrast, drama, extremes

    C = struct();

    % --- Dimension colors (8 colors, psychologically mapped) ---
    C.dim = [
        0.231 0.510 0.769;   % 1 BPM Stability  - Steel Blue   #3B82C4
        0.753 0.224 0.169;   % 2 Bass Energy     - Deep Crimson #C0392B
        0.910 0.659 0.220;   % 3 Vocal Presence  - Warm Amber   #E8A838
        0.878 0.408 0.125;   % 4 Beat Strength   - Burnt Orange #E06820
        0.000 0.722 0.831;   % 5 Spectral Flux   - Electric Cyan#00B8D4
        0.494 0.341 0.761;   % 6 Rhythm Complex  - Deep Purple  #7E57C2
        0.153 0.682 0.376;   % 7 Harmonic Rich   - Emerald      #27AE60
        0.914 0.118 0.388;   % 8 Dynamic Range   - Hot Magenta  #E91E63
    ];

    % Hex versions for HTML/D3
    C.dimHex = {'#3B82C4','#C0392B','#E8A838','#E06820','#00B8D4','#7E57C2','#27AE60','#E91E63'};

    % Faded versions (30% opacity equivalent on white)
    C.dimFaded = C.dim * 0.3 + 0.7;

    % --- Heatmap colormap (perceptual: cold → warm → hot) ---
    % Deep navy → indigo → teal → amber → vermilion → white
    C.heatmapAnchors = [
        0.04 0.04 0.10;    % 0.0  Near-black (silence)
        0.08 0.08 0.28;    % 0.15 Deep navy
        0.12 0.18 0.42;    % 0.25 Indigo
        0.06 0.35 0.45;    % 0.35 Deep teal
        0.10 0.52 0.38;    % 0.45 Teal-green
        0.65 0.55 0.12;    % 0.55 Warm amber
        0.85 0.38 0.08;    % 0.65 Burnt orange
        0.88 0.18 0.12;    % 0.78 Vermilion
        0.95 0.35 0.50;    % 0.88 Hot pink
        1.00 0.96 0.90;    % 1.0  Near-white (peak)
    ];
    C.heatmapPositions = [0 0.15 0.25 0.35 0.45 0.55 0.65 0.78 0.88 1.0];

    % --- Similarity matrix colormap (distance → closeness) ---
    % Slate charcoal → muted blue → warm gold
    C.simAnchors = [
        0.14 0.14 0.18;    % 0.0  Slate (distant)
        0.18 0.22 0.34;    % 0.3  Muted navy
        0.25 0.45 0.55;    % 0.5  Teal mid
        0.60 0.72 0.35;    % 0.7  Olive gold
        0.95 0.82 0.28;    % 0.9  Warm gold
        1.00 0.96 0.70;    % 1.0  Light gold (identical)
    ];
    C.simPositions = [0 0.3 0.5 0.7 0.9 1.0];

    % --- Hotness chart colors (10% accent) ---
    C.hotnessLine = [0.231 0.510 0.769]; % Steel Blue (matches BPM — trust)
    C.hotDot      = [0.914 0.118 0.388]; % Hot Magenta (drama, extremes)
    C.hotFill     = [0.914 0.118 0.388 0.12]; % Magenta fill (with alpha)
    C.threshold   = [0.914 0.118 0.388]; % Threshold line (Hot Magenta)
    C.coolZone    = [0.231 0.510 0.769 0.06]; % Steel Blue tint for cool zone

    % --- Background / chrome (60% dominant) ---
    C.figureBg    = [0.98 0.98 0.99];    % Warm off-white
    C.panelBg     = [0.94 0.94 0.96];    % Light panel
    C.gridColor   = [0.85 0.85 0.88];    % Subtle grid
    C.textPrimary = [0.12 0.12 0.15];    % Near-black
    C.textSecondary = [0.45 0.45 0.50];  % Muted gray
    C.hotOverlay  = [0.20 0.90 0.40 0.20]; % Green hot overlay

    % --- Color psychology labels (for legend use) ---
    C.dimPsychology = { ...
        'Trust & Reliability', ...       % Steel Blue
        'Power & Primal Force', ...      % Deep Crimson
        'Human Warmth & Emotion', ...    % Warm Amber
        'Impact & Urgency', ...          % Burnt Orange
        'Change & Movement', ...         % Electric Cyan
        'Sophistication & Depth', ...    % Deep Purple
        'Organic Fullness & Balance', ...% Emerald Green
        'Contrast & Drama' ...           % Hot Magenta
    };

    % --- Dimension display order (grouped by category) ---
    %   RHYTHM:  BPM Stability(1), Beat Strength(4), Rhythm Complexity(6)
    %   TONAL:   Bass Energy(2), Vocal Presence(3), Harmonic Richness(7)
    %   TEXTURE: Spectral Flux(5), Dynamic Range(8)
    C.dimDisplayOrder = [1, 4, 6, 2, 3, 7, 5, 8];
    C.dimCategoryNames = {'RHYTHM', 'TONAL', 'TEXTURE'};
    C.dimCategoryBounds = [1 3; 4 6; 7 8]; % row ranges in display order

    % --- Pre-built colormaps (256-step) ---
    C.heatmapCmap = interpColormap(C.heatmapAnchors, C.heatmapPositions, 256);
    C.simCmap = interpColormap(C.simAnchors, C.simPositions, 256);
end

function cmap = interpColormap(anchors, positions, nSteps)
% INTERPCOLORMAP Interpolate anchor colors into a smooth Nx3 colormap.
    if nargin < 3; nSteps = 256; end
    t = linspace(0, 1, nSteps)';
    cmap = zeros(nSteps, 3);
    for ch = 1:3
        cmap(:, ch) = interp1(positions, anchors(:, ch), t, 'pchip');
    end
    cmap = max(0, min(1, cmap));
end
