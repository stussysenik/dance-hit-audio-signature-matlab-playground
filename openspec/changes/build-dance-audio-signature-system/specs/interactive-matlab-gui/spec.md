# Capability: Interactive MATLAB GUI

MATLAB App Designer-based interactive interface combining visual heatmaps, ASCII displays, text explanations, criss-cross tables, and drag-and-drop song loading.

## ADDED Requirements

### Requirement: App Launcher
The system SHALL provide a DanceHitAnalyzer.mlapp that launches a multi-tab GUI application from a single command.

#### Scenario: Launch GUI
- **Given** MATLAB is open with the project on the path
- **When** the user runs DanceHitAnalyzer or quickstart
- **Then** the GUI application opens with all tabs visible and demo tracks pre-loaded

### Requirement: File Loading
The system SHALL support loading audio files via a file browser dialog and drag-and-drop onto the application window.

#### Scenario: Load via file browser
- **Given** the GUI is open
- **When** the user clicks Load Track and selects a WAV file
- **Then** the track is loaded, analyzed, and its results appear in the single-track tab

#### Scenario: Load demo tracks
- **Given** the GUI is open
- **When** the user clicks Load Demo Dataset
- **Then** all 10 demo tracks are loaded and available for analysis

### Requirement: Single Track Analysis Tab
The system SHALL display a single-track view with heatmap visualization, ASCII heatmap panel, text summary of key metrics, and dimension weight sliders.

#### Scenario: Analyze single track
- **Given** a track is loaded
- **When** the single-track tab is selected
- **Then** the heatmap, ASCII view, and text summary are displayed with weight sliders below

#### Scenario: Interactive weight adjustment
- **Given** a track heatmap is displayed
- **When** the user adjusts the bass energy weight slider
- **Then** the heatmap and hot segment markers update in real time

### Requirement: Multi-Song Comparison Tab
The system SHALL display the NxN similarity matrix as a criss-cross table with clickable cells that reveal segment-level detail.

#### Scenario: View comparison matrix
- **Given** 5+ tracks are loaded
- **When** the comparison tab is selected
- **Then** the NxN criss-cross table is shown with color-coded similarity scores

#### Scenario: Drill into pair detail
- **Given** the criss-cross table is displayed
- **When** the user clicks a cell
- **Then** a detail panel shows the top-5 compatible segments between those two songs

### Requirement: DJ Blend Tab
The system SHALL display blend recommendations with ranked pairings and a heatmap overlay showing optimal transition points.

#### Scenario: View blend recommendations
- **Given** 2+ tracks are loaded
- **When** the blend tab is selected
- **Then** ranked blend pairings are listed with timestamps, scores, and a visual heatmap of transition points

### Requirement: Metadata Tab
The system SHALL display artist, origin, songwriter, genre, and cultural context information for loaded tracks.

#### Scenario: View track metadata
- **Given** tracks with metadata are loaded
- **When** the metadata tab is selected
- **Then** a table shows all metadata fields for each track

### Requirement: Export Capabilities
The system SHALL support exporting analysis results as JSON, and visualizations as PNG images or standalone HTML with D3.js reports.

#### Scenario: Export HTML report
- **Given** analysis is complete for loaded tracks
- **When** the user clicks Export HTML Report
- **Then** a standalone HTML file with D3.js interactive visualizations is saved and opened in the browser

## Related Capabilities
- `audio-feature-extraction` (provides data for visualizations)
- `hotness-heatmap-engine` (provides heatmap data)
- `multi-song-pattern-matching` (provides comparison data)
- `dj-blend-recommendations` (provides blend data)
