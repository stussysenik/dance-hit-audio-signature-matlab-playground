# Capability: DJ Blend Recommendations

Scoring engine that evaluates blend compatibility between song segments and produces ranked lists of optimal transition points for DJ mixing.

## ADDED Requirements

### Requirement: Blend Score Computation
The system SHALL compute a composite blend score between segment pairs using BPM compatibility, key compatibility via Camelot wheel, energy curve match via cross-correlation, and spectral complement.

#### Scenario: Compatible BPM pair
- **Given** two segments at 128 BPM and 127 BPM
- **When** blend score is computed
- **Then** BPM compatibility component is greater than 0.95

#### Scenario: Incompatible BPM pair
- **Given** two segments at 128 BPM and 90 BPM
- **When** blend score is computed
- **Then** BPM compatibility component is less than 0.3

### Requirement: Ranked Blend Output
The system SHALL output a ranked list of blend recommendations sorted by composite score, each entry containing song pair, segment timestamps, individual component scores, and overall blend score.

#### Scenario: Top-5 blends between two songs
- **Given** two analyzed songs
- **When** rankBlends is called with K=5
- **Then** 5 blend pairs are returned sorted by score descending with start_time, end_time, and component scores

### Requirement: Blend Heatmap
The system SHALL produce a 2D heatmap showing blend compatibility across time for a selected song pair, with one song on each axis.

#### Scenario: Blend heatmap visualization
- **Given** two analyzed songs
- **When** the blend heatmap is rendered
- **Then** a figure shows time(song1) by time(song2) grid with color intensity representing blend score

### Requirement: Multi-Song Blend Discovery
The system SHALL find the best blend pairs across all loaded songs, producing a global ranked list.

#### Scenario: Global blend ranking across 10 songs
- **Given** 10 analyzed demo tracks
- **When** global blend discovery is run
- **Then** a ranked list shows the top blend pairs across all 45 song combinations

### Requirement: Export Blend List
The system SHALL export blend recommendations as JSON and formatted text suitable for DJ preparation notes.

#### Scenario: JSON export
- **Given** computed blend recommendations
- **When** exported as JSON
- **Then** a valid JSON file is produced with all blend pairs, timestamps in mm:ss format, and scores

## Related Capabilities
- `audio-feature-extraction` (provides feature data for scoring)
- `hotness-heatmap-engine` (hot segments are preferred blend points)
- `multi-song-pattern-matching` (provides DTW alignment for segment pairing)
- `interactive-matlab-gui` (displays blend results)
