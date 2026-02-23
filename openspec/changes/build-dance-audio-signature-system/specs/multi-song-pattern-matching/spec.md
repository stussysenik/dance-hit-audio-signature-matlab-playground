# Capability: Multi-Song Pattern Matching

Cross-song similarity analysis using cosine similarity on feature vectors and Dynamic Time Warping for segment-level alignment across 10+ songs simultaneously.

## ADDED Requirements

### Requirement: Similarity Matrix
The system SHALL build an NxN cosine similarity matrix from the mean feature vectors of hot segments across N songs.

#### Scenario: 10-song similarity matrix
- **Given** 10 analyzed demo tracks with feature matrices
- **When** buildSimilarityMatrix is called
- **Then** a 10x10 symmetric matrix is returned with 1.0 on the diagonal and values in [0, 1] elsewhere

### Requirement: Dynamic Time Warping
The system SHALL compute DTW distance between feature sequences of any two songs for segment-level temporal alignment.

#### Scenario: Self-comparison via DTW
- **Given** a song compared against itself
- **When** DTW is computed
- **Then** the DTW distance is approximately 0 and the alignment path is diagonal

#### Scenario: Different songs via DTW
- **Given** two songs with different structures
- **When** DTW is computed
- **Then** the DTW distance is greater than 0 and the alignment path shows structural correspondences

### Requirement: Segment-Level Matching
The system SHALL find the top-K most compatible segment pairs between any two songs based on DTW alignment and hotness overlap.

#### Scenario: Find best blending points between two songs
- **Given** two analyzed demo tracks
- **When** findBlendSegments is called with K=5
- **Then** 5 segment pairs are returned with timestamps and compatibility scores sorted by score descending

### Requirement: Criss-Cross Comparison Table
The system SHALL display an NxN comparison table with color-coded similarity scores and song labels.

#### Scenario: Visual comparison table
- **Given** a similarity matrix for 10 songs
- **When** plotCrissCross is called
- **Then** a figure shows a color-coded table with song names on both axes and similarity values annotated in cells

### Requirement: Scalability to 10+ Songs
The system SHALL handle simultaneous analysis of at least 10 songs without exceeding 60 seconds processing time on a modern desktop machine.

#### Scenario: 10-song batch processing
- **Given** 10 demo tracks of 30-60 seconds each
- **When** full similarity analysis is run
- **Then** processing completes within 60 seconds

## Related Capabilities
- `audio-feature-extraction` (provides feature matrices)
- `hotness-heatmap-engine` (provides hot segment indices)
- `dj-blend-recommendations` (uses segment matches for blend scoring)
