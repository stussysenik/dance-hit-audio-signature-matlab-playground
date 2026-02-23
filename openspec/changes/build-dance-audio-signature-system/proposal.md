# Proposal: Build Dance Audio Signature System

## Change ID
`build-dance-audio-signature-system`

## Summary
Build a MATLAB-based interactive audio signature analysis system for dance music. The system extracts multidimensional audio features (BPM, bass, vocals, beats, energy, spectral content, rhythm complexity, harmonic structure), computes a parametric "hotness" score across time, and identifies optimal blending segments for DJ mixing across multiple songs.

## Motivation
DJs and music enthusiasts need scientific, data-driven tools to analyze dance tracks beyond simple BPM matching. Current tools lack the multidimensional parametric analysis needed to find the *best* segments for blending. This system combines psychoacoustics research with interactive MATLAB visualizations to deliver staff-level engineering quality analysis that is accessible to users with zero prior signal processing experience.

## Goals
1. Extract 8 parametric audio features per time window forming a "hot source matrix"
2. Compute time-series hotness heatmaps showing mathematically calculated peak segments
3. Compare 10+ songs simultaneously with criss-cross similarity tables
4. Provide DJ blend recommendations: ranked segment pairings with heatmap overlay
5. Interactive MATLAB GUI with drag-and-drop, ASCII visualization, and rich text explanations
6. Bundle open demo dataset so the system works out of the box
7. Integrate cultural/metadata context (artist origin, songwriters, genre lineage)
8. Expose a lightweight web API for programmatic curl access to results

## Non-Goals
- Real-time live DJ performance tool (this is an analysis/preparation tool)
- Full DAW or audio editing functionality
- Streaming audio playback sync with external hardware
- Mobile app or browser-only deployment (MATLAB desktop is primary)
- Machine learning model training (we use deterministic DSP + statistics)

## Approach
Six capabilities delivered in phases across a 6-month roadmap:

| Phase | Months | Capabilities |
|-------|--------|-------------|
| 1 - Foundation | 1-2 | Audio Feature Extraction, Demo Dataset, Metadata Layer |
| 2 - Intelligence | 2-3 | Hotness Heatmap Engine, Multi-Song Pattern Matching |
| 3 - Experience | 4-5 | Interactive MATLAB GUI, DJ Blend Recommendations |
| 4 - Integration | 5-6 | Web API Endpoints, D3.js hybrid visualizations, Polish |

## Risks
- **Audio codec support**: MATLAB's `audioread` supports WAV/FLAC/MP3/OGG but not all formats. Mitigated by documenting supported formats and providing conversion guidance.
- **Demo dataset licensing**: Must use royalty-free/CC-licensed audio. Mitigated by generating synthetic demo tracks or using permissively licensed samples.
- **MATLAB toolbox dependencies**: Signal Processing Toolbox is required. Audio Toolbox is optional but enhances capabilities. Will document minimum vs recommended toolbox set.
- **Performance with 10+ songs**: Large multi-song analysis could be slow. Mitigated by segment-level caching and parallel computing toolbox support where available.

## Capabilities Affected
All new capabilities:
- `audio-feature-extraction` — Core DSP pipeline
- `hotness-heatmap-engine` — Parametric hotness scoring
- `multi-song-pattern-matching` — Cross-song similarity analysis
- `interactive-matlab-gui` — User interface layer
- `demo-dataset` — Bundled sample data
- `dj-blend-recommendations` — Mixing segment recommendations
- `metadata-cultural-layer` — Artist/cultural metadata
- `web-api-endpoints` — HTTP API layer
