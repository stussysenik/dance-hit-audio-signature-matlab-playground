# Capability: Demo Dataset

Bundled synthetic audio samples and metadata that allow the system to work out of the box with zero setup, demonstrating all analysis capabilities.

## ADDED Requirements

### Requirement: Synthetic Track Generation
The system SHALL include a generateDemoDataset.m script that produces 10 synthetic WAV files with controlled, known audio characteristics.

#### Scenario: Generate demo dataset
- **Given** MATLAB is open with Signal Processing Toolbox
- **When** generateDemoDataset is run
- **Then** 10 WAV files are created in data/demo/ with 44100 Hz sample rate, mono, 30-60 seconds each

### Requirement: Diverse Audio Profiles
The demo tracks SHALL span a diverse range of BPM (110-150), bass levels, vocal presence, beat strength, and rhythm complexity to exercise all 8 feature dimensions.

#### Scenario: Profile diversity verification
- **Given** the 10 demo tracks
- **When** feature extraction is run on all tracks
- **Then** each of the 8 dimensions has at least one track where it is the dominant feature

### Requirement: Ground Truth Metadata
Each demo track SHALL have a corresponding metadata entry in data/metadata/demo_tracks.json including known BPM, dominant features, artist name, genre, and expected hotness profile.

#### Scenario: Metadata completeness
- **Given** the demo metadata JSON file
- **When** it is loaded
- **Then** all 10 tracks have entries with fields: title, artist, bpm, genre, origin, songwriters, dominant_features

### Requirement: Zero-Setup Experience
The system SHALL detect missing demo files on first run and offer to generate them automatically.

#### Scenario: First-run auto-generation
- **Given** a fresh install with empty data/demo/ directory
- **When** quickstart is run
- **Then** the user is prompted to generate demo data, and upon confirmation, all demo files are created

## Related Capabilities
- `audio-feature-extraction` (demo tracks are primary test inputs)
- `metadata-cultural-layer` (demo metadata exercises the metadata system)
