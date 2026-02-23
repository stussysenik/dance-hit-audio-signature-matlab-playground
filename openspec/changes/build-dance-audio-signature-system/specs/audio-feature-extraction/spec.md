# Capability: Audio Feature Extraction

Core DSP pipeline that extracts 8 parametric audio dimensions from any input audio file, forming the foundation "hot source matrix" for all downstream analysis.

## ADDED Requirements

### Requirement: Audio Loading
The system SHALL load audio files in WAV, FLAC, MP3, and OGG formats, resample to 44100 Hz, and convert to mono.

#### Scenario: Load a stereo MP3 file
- **Given** a stereo MP3 file at 48000 Hz sample rate
- **When** the file is loaded via `audioLoad`
- **Then** the output is a mono signal at 44100 Hz with length proportional to original duration

#### Scenario: Unsupported format error
- **Given** an audio file in an unsupported format (e.g., `.midi`)
- **When** the file is loaded via `audioLoad`
- **Then** a descriptive error message is returned indicating supported formats

### Requirement: Windowed Segmentation
The system SHALL segment audio into configurable windows (default 500ms, 50% overlap) for per-segment feature extraction.

#### Scenario: Default segmentation of a 10-second track
- **Given** a 10-second mono audio signal at 44100 Hz
- **When** segmented with default parameters (500ms window, 50% overlap)
- **Then** approximately 39 segments are produced, each containing 22050 samples

### Requirement: BPM Detection
The system SHALL detect tempo (BPM) using autocorrelation-based analysis and compute per-segment BPM stability as dimension 1.

#### Scenario: Detect BPM of a 128 BPM track
- **Given** a demo track with known ground-truth BPM of 128
- **When** BPM detection is run
- **Then** detected BPM is within ±2 of 128 and stability score is in [0, 1]

### Requirement: Bass Energy
The system SHALL compute RMS energy in the 20-250 Hz band via bandpass filtering as dimension 2.

#### Scenario: Bass-heavy track scores highest
- **Given** a set of demo tracks with varying bass levels
- **When** bass energy is computed for all tracks
- **Then** the bass-heavy track has the highest mean bass energy score

### Requirement: Vocal Presence
The system SHALL estimate vocal presence using spectral centroid and harmonic-to-noise ratio in the 300-3400 Hz band as dimension 3.

#### Scenario: Vocal track detection
- **Given** a track with prominent vocals and a purely instrumental track
- **When** vocal presence is computed
- **Then** the vocal track scores significantly higher than the instrumental track

### Requirement: Beat Strength
The system SHALL measure beat strength via onset detection envelope peak amplitude as dimension 4.

#### Scenario: Strong-beat track identification
- **Given** tracks with varying percussive intensity
- **When** beat strength is computed
- **Then** the strongly percussive track scores highest

### Requirement: Spectral Flux
The system SHALL compute frame-to-frame spectral magnitude change as dimension 5.

#### Scenario: Transition-heavy segment detection
- **Given** a track with both static and rapidly changing spectral sections
- **When** spectral flux is computed per segment
- **Then** segments with rapid spectral change score higher than static segments

### Requirement: Rhythm Complexity
The system SHALL compute rhythm complexity via onset density and syncopation index as dimension 6.

#### Scenario: Complex vs simple rhythm
- **Given** a track with syncopated polyrhythm and a four-on-the-floor track
- **When** rhythm complexity is computed
- **Then** the polyrhythmic track scores higher

### Requirement: Harmonic Richness
The system SHALL compute harmonic richness via significant harmonic peak count and spectral flatness as dimension 7.

#### Scenario: Rich harmonic content detection
- **Given** a track with dense chord voicings and a single-note bassline track
- **When** harmonic richness is computed
- **Then** the harmonically rich track scores higher

### Requirement: Dynamic Range
The system SHALL compute local dynamic range via crest factor (peak/RMS) per segment as dimension 8.

#### Scenario: Dynamic vs compressed track
- **Given** a highly dynamic track and a heavily compressed track
- **When** dynamic range is computed
- **Then** the dynamic track scores higher

### Requirement: Feature Matrix Output
The system SHALL combine all 8 dimensions into an 8xN matrix (N = number of segments) with min-max normalization to [0, 1] per track.

#### Scenario: Complete feature extraction
- **Given** any valid audio file
- **When** `extractFeatures` is called
- **Then** an 8xN matrix is returned where all values are in [0, 1] and N matches the expected segment count

## Related Capabilities
- `hotness-heatmap-engine` (consumes the 8D feature matrix)
- `multi-song-pattern-matching` (uses feature vectors for similarity)
- `demo-dataset` (provides test inputs)
