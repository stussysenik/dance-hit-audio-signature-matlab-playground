# Capability: Hotness Heatmap Engine

Time-series analysis engine that computes parametric "hotness" scores from the 8D feature matrix and identifies mathematically calculated peak segments with probability statistics.

## ADDED Requirements

### Requirement: Hotness Score Computation
The system SHALL compute a hotness score H(t) for each time segment as the weighted sum of 8 dimensions with configurable weights.

#### Scenario: Equal-weight hotness scoring
- **Given** an 8xN feature matrix and equal weights
- **When** hotness is computed
- **Then** H(t) equals the arithmetic mean of all 8 dimensions for each segment t

#### Scenario: Custom weight hotness scoring
- **Given** an 8xN feature matrix and weights emphasizing bass (w2 = 0.5, others = 0.5/7)
- **When** hotness is computed
- **Then** H(t) is dominated by bass energy values

### Requirement: Hot Segment Classification
The system SHALL classify segments as "hot" when H(t) exceeds mean plus one standard deviation.

#### Scenario: Hot segment identification
- **Given** a hotness vector with known mean and standard deviation
- **When** hot segments are classified
- **Then** only segments exceeding the threshold are marked as hot and their indices are returned

### Requirement: Heatmap Visualization
The system SHALL render a time-by-dimension heatmap using imagesc with a colorbar, hot segment overlay bands, and per-dimension contribution breakdown.

#### Scenario: Heatmap rendering
- **Given** a completed feature extraction for a demo track
- **When** plotHeatmap is called
- **Then** a figure is displayed with time on x-axis, 8 dimensions on y-axis, and highlighted hot segment bands

### Requirement: ASCII Heatmap
The system SHALL provide a text-based heatmap using Unicode block characters suitable for MATLAB command window display.

#### Scenario: ASCII heatmap output
- **Given** a completed feature extraction
- **When** asciiHeatmap is called
- **Then** a text representation is printed to the command window with dimension labels and time progression visible

### Requirement: Configurable Weights
The system SHALL accept user-defined dimension weights and update hotness scores and heatmaps in response to weight changes.

#### Scenario: Weight adjustment updates results
- **Given** an analyzed track with default weights
- **When** the user changes bass weight from 0.125 to 0.5
- **Then** the hotness scores, hot segment indices, and heatmap all reflect the new weighting

## Related Capabilities
- `audio-feature-extraction` (provides the 8D feature matrix input)
- `interactive-matlab-gui` (displays heatmaps and weight sliders)
- `dj-blend-recommendations` (uses hot segments for blend scoring)
