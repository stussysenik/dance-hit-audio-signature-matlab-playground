# Technical Documentation

## Feature Extraction Pipeline

Each audio file flows through:

```
audioLoad → windowSegment → extractFeatures → normalizeFeatures → computeHotness
```

### Audio Loading (`audioLoad.m`)
- Supports WAV, FLAC, MP3, OGG, M4A
- Resamples to 44,100 Hz, converts stereo → mono

### Segmentation (`windowSegment.m`)
- 500ms windows with 50% overlap
- ~39 segments per 10-second track
- Returns segment cell array + time axis

### Feature Extraction (`extractFeatures.m`)
Orchestrates 8 dimension extractors, returns 8×N matrix:

| Extractor | Method | Output Range |
|-----------|--------|-------------|
| `computeBPM` | Autocorrelation tempo tracking | BPM stability [0,1] |
| `computeBassEnergy` | Bandpass 20–250 Hz, RMS | Energy [0,1] |
| `computeVocalPresence` | Spectral centroid + HNR in 300–3400 Hz | Presence [0,1] |
| `computeBeatStrength` | Onset detection envelope peaks | Strength [0,1] |
| `computeSpectralFlux` | Euclidean distance between spectral frames | Flux [0,1] |
| `computeRhythmComplexity` | Onset density + inter-onset variance | Complexity [0,1] |
| `computeHarmonicRichness` | Harmonic peak count + spectral flatness | Richness [0,1] |
| `computeDynamicRange` | Crest factor (peak / RMS) | Range [0,1] |

### Normalization (`normalizeFeatures.m`)
Per-track min-max normalization scales each dimension to [0,1].

### Hotness (`computeHotness.m`)
- Formula: `H(t) = Σ(w_i × D_i(t))` where w_i defaults to 1/8
- Threshold: segments above `mean + σ` are "hot" (~top 16%)
- Weights are user-configurable (e.g., club focus: bass=0.30, beats=0.30)

## Pattern Matching

### SegmentIndex (`SegmentIndex.m`)
O(1) hash-indexed lookup over all 8D feature vectors:
- Quantizes features into 16 bins per dimension
- Methods: `query(vec, K)`, `queryHot(K)`, `queryBPMRange(lo, hi, K)`, `queryByDimension(dim, min, max, K)`, `querySimilarToSegment(songIdx, segIdx, K)`

### Similarity (`buildSimilarityMatrix.m`)
Cosine similarity on mean hot-segment feature vectors → N×N matrix.

### DTW (`computeDTW.m`)
Dynamic Time Warping aligns feature sequences between song pairs, finding optimal matching paths despite tempo variations.

### Blend Scoring (`rankBlends.m`)
```
Score = α·BPMcompat + β·KeyCompat + γ·EnergyMatch + δ·SpectralComplement
```
- BPM: within 5% or integer harmonic ratio
- Key: Camelot wheel distance
- Energy: cross-correlation of envelope
- Spectral: frequency clash avoidance
- Default weights: BPM 0.3, Key 0.2, Energy 0.3, Spectral 0.2

## Visualization

### Heatmap (`plotHeatmap.m`)
Two-layer display:
1. **Fingerprint layer** — 8 dimensions color-coded by category (rhythm/tonal/texture)
2. **Hotness layer** — combined score with threshold line and hot segment markers

### Criss-Cross (`plotCrissCross.m`)
N×N grid showing cosine similarity between all track pairs.

### ASCII (`asciiHeatmap.m`)
Terminal-friendly block characters (░▒▓█) for text-only environments.

### HTML Report (`generateHTMLReport.m`)
D3.js interactive report with heatmaps, chord diagrams, similarity networks.

## Interactive GUI (`launchGUI.m`)

4-tab interface:
1. **Single Track** — analyze one track with interactive weight sliders + heatmap
2. **Comparison** — cross-song similarity matrix
3. **DJ Blend** — ranked blend recommendations table
4. **Metadata** — track info and cultural context

## Web API

Endpoints on port 8080:
- `GET /analyze?file=<path>` — analyze a single track → JSON
- `GET /compare` — similarity matrix → JSON
- `GET /blend` — DJ blend recommendations → JSON
- `GET /heatmap` — visualization data → JSON

## Configuration (`AnalysisConfig.m`)

Central config struct with all tunable parameters:
- `targetSampleRate`: 44100 Hz
- `windowDuration`: 0.5 sec
- `overlapRatio`: 0.5
- `fftSize`: 2048
- Frequency bands, blend weights, paths, API port

## Testing

5 test files in `tests/`:
- `test_feature_extraction.m` — all 8 dimension extractors
- `test_hotness_engine.m` — scoring, thresholding, hot segment identification
- `test_pattern_matching.m` — similarity, DTW, segment queries
- `test_blend_scoring.m` — blend computation and ranking
- `test_segment_index.m` — O(1) hash index correctness and performance
