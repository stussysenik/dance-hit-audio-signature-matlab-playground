# Capability: Metadata and Cultural Layer

Artist origin, songwriting credits, genre lineage, and cultural context integrated into the analysis for enriched curation and discovery.

## ADDED Requirements

### Requirement: Metadata Schema
The system SHALL support a metadata schema including title, artist, origin, songwriters, genre, subgenre, year, label, key, and custom tags.

#### Scenario: Complete metadata record
- **Given** a track metadata JSON entry
- **When** it is loaded via loadMetadata
- **Then** all schema fields are accessible as struct fields in MATLAB

### Requirement: Metadata Store
The system SHALL provide an in-memory MetadataStore with query methods for filtering by genre, artist, origin, and sorting by year.

#### Scenario: Filter by genre
- **Given** 10 demo tracks with varying genres loaded in MetadataStore
- **When** filtered by genre house
- **Then** only house tracks are returned

#### Scenario: Filter by origin
- **Given** tracks from multiple origins
- **When** filtered by origin Berlin
- **Then** only Berlin-origin tracks are returned

### Requirement: Metadata Display
The system SHALL display metadata alongside analysis results, showing cultural context next to audio signatures.

#### Scenario: Enriched analysis output
- **Given** a track with metadata and completed feature extraction
- **When** results are displayed
- **Then** metadata including artist, origin, and genre appears alongside the heatmap and scores

### Requirement: Manual Metadata Entry
The system SHALL support manual metadata entry and editing through the GUI for tracks without pre-existing metadata.

#### Scenario: Add metadata for new track
- **Given** a loaded track without metadata
- **When** the user fills in metadata fields in the GUI
- **Then** the metadata is saved and associated with the track for future sessions

## Related Capabilities
- `demo-dataset` (demo tracks have pre-populated metadata)
- `interactive-matlab-gui` (metadata tab displays and edits metadata)
- `dj-blend-recommendations` (metadata enriches blend context)
