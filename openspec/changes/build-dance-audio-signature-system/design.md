# Design: Dance Audio Signature System

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   MATLAB Application Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ GUI/MLAPP│  │ Live     │  │ ASCII    │  │ D3.js HTML │  │
│  │ Panels   │  │ Scripts  │  │ Display  │  │ Reports    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘  │
│       └──────────────┴─────────────┴──────────────┘          │
│                          │                                    │
│  ┌───────────────────────┴───────────────────────────────┐   │
│  │              Analysis Engine (Core)                    │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐  │   │
│  │  │ Feature     │  │ Hotness      │  │ Pattern     │  │   │
│  │  │ Extraction  │  │ Heatmap      │  │ Matcher     │  │   │
│  │  │ Pipeline    │  │ Engine       │  │             │  │   │
│  │  └─────────────┘  └──────────────┘  └─────────────┘  │   │
│  │  ┌─────────────┐  ┌──────────────┐                    │   │
│  │  │ DJ Blend    │  │ Metadata     │                    │   │
│  │  │ Recommender │  │ Manager      │                    │   │
│  │  └─────────────┘  └──────────────┘                    │   │
│  └───────────────────────────────────────────────────────┘   │
│                          │                                    │
│  ┌───────────────────────┴───────────────────────────────┐   │
│  │              Data Layer                                │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐  │   │
│  │  │ Audio I/O   │  │ Cache/MAT    │  │ Demo        │  │   │
│  │  │ (audioread) │  │ Storage      │  │ Dataset     │  │   │
│  │  └─────────────┘  └──────────────┘  └─────────────┘  │   │
│  └───────────────────────────────────────────────────────┘   │
│                          │                                    │
│  ┌───────────────────────┴───────────────────────────────┐   │
│  │              Web API Layer (Optional)                  │   │
│  │  webserver() ──► JSON endpoints ──► curl accessible    │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## The 8-Dimension Hot Source Matrix

Each audio segment (configurable window, default 500ms with 50% overlap) is scored across 8 parametric dimensions:

| Dim | Name | Method | Range |
|-----|------|--------|-------|
| 1 | **BPM Stability** | Autocorrelation-based tempo tracking, stability = 1/variance | 0-1 |
| 2 | **Bass Energy** | RMS energy in 20-250 Hz band via bandpass filter | 0-1 |
| 3 | **Vocal Presence** | Spectral centroid + harmonic-to-noise ratio in 300-3400 Hz | 0-1 |
| 4 | **Beat Strength** | Onset detection envelope peak amplitude | 0-1 |
| 5 | **Spectral Flux** | Frame-to-frame spectral change magnitude | 0-1 |
| 6 | **Rhythm Complexity** | Onset density + syncopation index | 0-1 |
| 7 | **Harmonic Richness** | Number of significant harmonic peaks / spectral flatness | 0-1 |
| 8 | **Dynamic Range** | Local crest factor (peak/RMS ratio) | 0-1 |

All dimensions are normalized to [0, 1] using min-max scaling per track. The **hotness score** is a weighted sum:

```
H(t) = Σ(i=1..8) w_i × D_i(t)
```

where weights `w_i` are user-configurable (default: equal weights). Segments with `H(t) > μ + σ` are classified as "hot".

## Multi-Song Similarity

Cross-song similarity uses a distance matrix approach:

1. For each song, compute the mean feature vector across its "hot" segments
2. Build an NxN distance matrix using cosine similarity
3. For segment-level matching (DJ blending), use Dynamic Time Warping (DTW) on feature sequences
4. Output: ranked list of compatible segments + visual heatmap

## DJ Blend Scoring

Blend compatibility between segment A (song 1) and segment B (song 2):

```
BlendScore = α × BPMcompat + β × KeyCompat + γ × EnergyCurveMatch + δ × SpectralComplement
```

- **BPMcompat**: 1 - |bpm_A - bpm_B| / max_bpm_diff (threshold: within 5% or integer ratio)
- **KeyCompat**: Camelot wheel distance (0 = same key, 1 = adjacent, lower = better)
- **EnergyCurveMatch**: Cross-correlation of energy envelopes at transition point
- **SpectralComplement**: Ensures frequency ranges don't clash (low correlation = good complement)

## File Structure

```
dance-hit-audio-signature-matlab-playground/
├── src/
│   ├── core/                    % Analysis engine
│   │   ├── extractFeatures.m    % Main feature extraction pipeline
│   │   ├── computeBPM.m         % BPM detection
│   │   ├── computeBassEnergy.m  % Bass band energy
│   │   ├── computeVocalPresence.m
│   │   ├── computeBeatStrength.m
│   │   ├── computeSpectralFlux.m
│   │   ├── computeRhythmComplexity.m
│   │   ├── computeHarmonicRichness.m
│   │   ├── computeDynamicRange.m
│   │   ├── computeHotness.m     % Hotness heatmap from 8D matrix
│   │   └── normalizeFeatures.m  % Min-max normalization
│   ├── matching/                % Cross-song analysis
│   │   ├── buildSimilarityMatrix.m
│   │   ├── findBlendSegments.m
│   │   ├── computeDTW.m
│   │   └── rankBlends.m
│   ├── metadata/                % Cultural/metadata layer
│   │   ├── loadMetadata.m
│   │   ├── enrichWithMusicBrainz.m
│   │   └── MetadataStore.m
│   ├── gui/                     % Interactive interface
│   │   ├── DanceHitAnalyzer.mlapp  % Main App Designer GUI
│   │   ├── plotHeatmap.m
│   │   ├── plotCrissCross.m
│   │   ├── asciiHeatmap.m
│   │   └── generateHTMLReport.m   % D3.js hybrid output
│   ├── api/                     % Web API
│   │   ├── startServer.m
│   │   └── handleRequest.m
│   └── utils/                   % Shared utilities
│       ├── audioLoad.m
│       ├── windowSegment.m
│       └── cacheManager.m
├── data/
│   ├── demo/                    % Bundled demo audio files
│   │   ├── demo_track_01.wav
│   │   ├── ...
│   │   └── demo_track_10.wav
│   ├── metadata/                % Demo metadata JSON files
│   │   └── demo_tracks.json
│   └── cache/                   % Analysis cache (gitignored)
├── docs/
│   ├── llms.txt                 % Sonic Visualizer knowledge
│   ├── psychoacoustics_primer.md
│   └── getting_started.md
├── tests/
│   ├── test_feature_extraction.m
│   ├── test_hotness_engine.m
│   ├── test_pattern_matching.m
│   └── test_blend_scoring.m
├── templates/
│   └── d3_report.html           % D3.js visualization template
├── main.m                       % Entry point - run everything
├── quickstart.m                 % Zero-experience friendly launcher
└── README.md
```

## Key Design Decisions

### 1. Pure MATLAB with Optional Toolboxes
- **Minimum**: Signal Processing Toolbox (for `bandpass`, `stft`, `findpeaks`)
- **Optional**: Audio Toolbox (for `audioFeatureExtractor`), Parallel Computing Toolbox (for `parfor`)
- Fallback implementations provided for users without optional toolboxes

### 2. Synthetic Demo Dataset
- Generate 10 synthetic demo tracks using MATLAB's `audiowrite` with known characteristics
- Each track has distinct BPM, energy profile, and spectral signature
- Avoids licensing issues entirely
- `generateDemoDataset.m` creates reproducible demo data

### 3. Segment-Based Processing
- Default: 500ms windows, 50% overlap
- Configurable via `AnalysisConfig` struct
- Results cached in `.mat` files keyed by audio file hash

### 4. Web API via MATLAB's Built-in webserver
- Uses `webserver()` (R2024b+) or falls back to `tcpserver` with HTTP parsing
- JSON responses for all endpoints
- Endpoints: `/analyze`, `/compare`, `/blend`, `/heatmap`

### 5. D3.js Hybrid Visualization
- MATLAB generates JSON data + populates an HTML template
- Template uses D3.js for interactive heatmaps and chord diagrams
- Opened in system browser via `web()` command
