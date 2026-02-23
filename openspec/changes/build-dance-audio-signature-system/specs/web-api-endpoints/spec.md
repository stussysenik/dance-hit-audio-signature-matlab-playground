# Capability: Web API Endpoints

Lightweight HTTP API layer exposing analysis results via curl-accessible JSON endpoints for programmatic integration.

## ADDED Requirements

### Requirement: Server Startup
The system SHALL start an HTTP server on a configurable port (default 8080) via startServer(port).

#### Scenario: Start server on default port
- **Given** MATLAB is running with the project on the path
- **When** startServer() is called
- **Then** an HTTP server starts listening on port 8080 and prints a confirmation message

#### Scenario: Start server on custom port
- **Given** MATLAB is running
- **When** startServer(9090) is called
- **Then** the server listens on port 9090

### Requirement: Analyze Endpoint
The system SHALL provide GET /analyze that returns the 8D feature matrix and hotness scores as JSON.

#### Scenario: Analyze a demo track via curl
- **Given** the server is running
- **When** curl localhost:8080/analyze with a file parameter is executed
- **Then** a JSON response is returned containing features, hotness, hot_segments, bpm, and metadata

### Requirement: Compare Endpoint
The system SHALL provide GET /compare that returns the similarity matrix as JSON for multiple files.

#### Scenario: Compare 3 tracks
- **Given** the server is running and 3 demo tracks exist
- **When** the compare endpoint is called with 3 file paths
- **Then** a JSON response with a 3x3 similarity matrix and song labels is returned

### Requirement: Blend Endpoint
The system SHALL provide GET /blend that returns top-K blend recommendations as JSON for two files.

#### Scenario: Get top-5 blends
- **Given** the server is running
- **When** the blend endpoint is called with two file paths and k=5
- **Then** a JSON response with 5 blend pairs including timestamps, component scores, and total score is returned

### Requirement: Heatmap Endpoint
The system SHALL provide GET /heatmap that returns heatmap data as JSON or a rendered PNG image.

#### Scenario: Get heatmap as JSON
- **Given** the server is running
- **When** the heatmap endpoint is called with format=json
- **Then** a JSON response with time axis, dimension labels, and value matrix is returned

#### Scenario: Get heatmap as PNG
- **Given** the server is running
- **When** the heatmap endpoint is called with format=png
- **Then** a PNG image of the heatmap is returned with correct Content-Type header

### Requirement: Error Handling
The system SHALL return appropriate HTTP status codes with descriptive JSON error messages for bad requests, file not found, and processing errors.

#### Scenario: File not found
- **Given** the server is running
- **When** a request references a non-existent file
- **Then** HTTP 404 is returned with a JSON error message

## Related Capabilities
- `audio-feature-extraction` (analysis results served via API)
- `hotness-heatmap-engine` (heatmap data served via API)
- `multi-song-pattern-matching` (comparison results served via API)
- `dj-blend-recommendations` (blend results served via API)
