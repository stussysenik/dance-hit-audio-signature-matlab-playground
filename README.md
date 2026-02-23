# Dance Hit Audio Signature Analysis

A MATLAB-based 8-dimensional audio signature analysis system for dance music. Extracts psychoacoustically-grounded features from tracks, computes per-segment "hotness" scores, and recommends DJ blend points between songs.

## The 8 Dimensions

| # | Dimension | What It Measures | Perceptual Basis |
|---|-----------|-----------------|------------------|
| 1 | **BPM Stability** | Tempo consistency (autocorrelation) | Rhythmic entrainment confidence |
| 2 | **Bass Energy** | 20–250 Hz RMS power | Physical "chest thump" via bone conduction |
| 3 | **Vocal Presence** | 300–3400 Hz spectral centroid + HNR | Emotional connection, voice isolation |
| 4 | **Beat Strength** | Onset detection envelope amplitude | Kick drum impact, danceability |
| 5 | **Spectral Flux** | Frame-to-frame spectral change | Transitions, builds, drops |
| 6 | **Rhythm Complexity** | Onset density + syncopation index | Cognitive engagement, groove |
| 7 | **Harmonic Richness** | Harmonic peaks + spectral flatness | Warmth, timbral depth |
| 8 | **Dynamic Range** | Crest factor (peak/RMS) | Tension-release cycles |

**Hotness** = weighted sum of all 8 dimensions. Segments above mean + σ are classified as "hot" (peak dance moments).

## Quick Start

```matlab
cd('dance-hit-audio-signature-matlab-playground')
main    % adds paths and runs quickstart
```

The `quickstart.m` pipeline runs 8 steps:
1. Check/generate 10 synthetic demo tracks
2. Extract 8D features from all tracks
3. Print hot segment timestamps per song
4. Generate per-track heatmaps
5. ASCII heatmaps in terminal
6. Build O(1) segment index + query top-10 hottest
7. Cross-song similarity matrix (criss-cross table)
8. DJ blend recommendations (top 10 pairs)

## Requirements

- MATLAB R2020b or later
- Signal Processing Toolbox
- Audio Toolbox (optional — fallbacks provided)

## Architecture

```
Application Layer
  ├── 4-tab Interactive GUI (launchGUI.m)
  ├── ASCII Terminal Heatmaps
  ├── D3.js HTML Reports
  └── Web API (port 8080)
        ↓
Analysis Engine
  ├── 8D Feature Extraction Pipeline
  ├── Hotness Scoring (weighted sum + threshold)
  ├── O(1) Hash-Indexed Segment Queries
  ├── Cross-Song Similarity (cosine + DTW)
  └── DJ Blend Ranking (BPM + key + energy + spectral)
        ↓
Data Layer
  ├── Audio I/O (WAV/FLAC/MP3/OGG/M4A → 44.1kHz mono)
  ├── 10 Synthetic Demo Tracks (genre-specific)
  ├── Metadata JSON (artist, BPM, key, energy)
  └── MAT File Cache (O(1) retrieval)
```

## Project Structure

```
├── main.m                   # Entry point
├── quickstart.m             # Zero-experience 8-step pipeline
├── src/
│   ├── core/                # 8D feature extractors + hotness
│   ├── matching/            # Similarity, DTW, blend scoring
│   ├── gui/                 # Heatmaps, criss-cross, GUI, D3.js
│   ├── api/                 # HTTP server + request handling
│   ├── metadata/            # Track metadata management
│   └── utils/               # Config, audio I/O, caching, segmentation
├── data/
│   ├── demo/                # 10 synthetic demo tracks (auto-generated)
│   ├── metadata/            # Track annotations (JSON)
│   └── cache/               # Analysis cache (gitignored)
├── templates/               # D3.js report template
├── tests/                   # Unit tests for all modules
├── docs/                    # Getting started, psychoacoustics primer
├── openspec/                # Spec-driven development artifacts
└── nvim-portable/           # Portable Neovim configuration
```

## Analyze Your Own Music

```matlab
addpath(genpath('src'));
config = AnalysisConfig();
[signal, fs] = audioLoad('your_song.wav', config);
[segments, timeAxis] = windowSegment(signal, fs, config);
features = extractFeatures(segments, fs, config);
[hotness, hotIdx] = computeHotness(features, config);
plotHeatmap(features, timeAxis, hotness, hotIdx, 'Your Song', config);
```

## Web API

```bash
# Start server (from MATLAB)
# server = startServer(AnalysisConfig());

curl http://localhost:8080/analyze?file=data/demo/demo_track_01_deep_house.wav
curl http://localhost:8080/compare
curl http://localhost:8080/blend
```
