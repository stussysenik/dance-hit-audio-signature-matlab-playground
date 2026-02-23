# Getting Started with Dance Hit Audio Signature Analyzer

## Prerequisites

- **MATLAB R2020b** or newer
- **Signal Processing Toolbox** (required)
- Audio Toolbox (optional, enhances some features)
- Parallel Computing Toolbox (optional, speeds up multi-song analysis)

## Quick Start (30 seconds)

```matlab
% 1. Open MATLAB and navigate to the project folder
cd('path/to/dance-hit-audio-signature-matlab-playground')

% 2. Run the quickstart script
quickstart
```

That's it! The system will:
1. Generate 10 synthetic demo tracks (if not already present)
2. Analyze all tracks across 8 audio dimensions
3. Display a heatmap of the first track
4. Show an ASCII heatmap in the command window
5. Build a cross-song similarity matrix
6. Compute DJ blend recommendations

## What You'll See

### Heatmap
A color-coded visualization showing how each of the 8 audio dimensions varies over time. Hot segments (the most exciting parts) are highlighted.

### ASCII Heatmap
A text-based version using block characters (░▒▓█) that works in the command window — no GUI needed.

### Similarity Matrix
A 10x10 grid showing how similar each pair of tracks is, using cosine similarity on their audio signatures.

### Blend Recommendations
A ranked list of the best segments to blend together when DJing, with timestamps and compatibility scores.

## Interactive GUI

```matlab
% Launch the full interactive GUI
launchGUI()
```

The GUI has 4 tabs:
1. **Single Track** — Analyze one track with interactive weight sliders
2. **Comparison** — View the cross-song similarity matrix
3. **DJ Blend** — See ranked blend recommendations
4. **Metadata** — Browse track metadata and cultural context

## The 8 Dimensions

| # | Dimension | What It Measures |
|---|-----------|-----------------|
| 1 | BPM Stability | How consistent the tempo is |
| 2 | Bass Energy | Low-frequency (20-250 Hz) power |
| 3 | Vocal Presence | Voice-like content in 300-3400 Hz |
| 4 | Beat Strength | Kick/onset impact strength |
| 5 | Spectral Flux | Rate of timbral change |
| 6 | Rhythm Complexity | Syncopation and onset density |
| 7 | Harmonic Richness | Chord/tonal complexity |
| 8 | Dynamic Range | Loud-to-quiet variation |

## Analyze Your Own Music

```matlab
% Add source paths
addpath(genpath('src'));
config = AnalysisConfig();

% Load and analyze a track
[signal, fs] = audioLoad('path/to/your/song.wav', config);
[segments, timeAxis] = windowSegment(signal, fs, config);
[features, bpm] = extractFeatures(segments, fs, config);
[hotness, hotIdx] = computeHotness(features, config);

% Visualize
plotHeatmap(features, timeAxis, hotness, hotIdx, 'My Song', config);
asciiHeatmap(features, timeAxis, hotIdx, config);
```

## Custom Weights

```matlab
% Emphasize bass and beats for a club-focused analysis
config.weights = [0.05 0.30 0.05 0.30 0.10 0.10 0.05 0.05];
[hotness, hotIdx] = computeHotness(features, config);
```

## Web API

```matlab
% Start the API server
config = AnalysisConfig();
server = startServer(config);

% Then from terminal:
% curl http://localhost:8080/analyze?file=data/demo/demo_track_01_deep_house.wav
% curl http://localhost:8080/compare?files=track1.wav,track2.wav
% curl http://localhost:8080/blend?files=track1.wav,track2.wav&k=5
```

## D3.js HTML Report

```matlab
% Generate an interactive HTML report
outputPath = generateHTMLReport(allResults, config);
% Opens automatically in your browser
```

## Supported Audio Formats

- WAV (recommended)
- FLAC
- MP3
- OGG
- M4A

## File Structure

```
src/core/       — 8 feature extractors + pipeline
src/matching/   — Cross-song similarity + DTW + blend scoring
src/metadata/   — Cultural/artist metadata management
src/gui/        — Heatmaps, ASCII display, GUI, HTML reports
src/api/        — Web API server
src/utils/      — Audio loading, segmentation, caching, config
data/demo/      — 10 synthetic demo tracks
data/metadata/  — Track metadata JSON
docs/           — Sonic Visualizer knowledge, psychoacoustics primer
tests/          — Unit test suite
```

## Further Reading

- `docs/psychoacoustics_primer.md` — Why these 8 dimensions matter perceptually
- `docs/llms.txt` — How our dimensions map to Sonic Visualizer VAMP plugins
