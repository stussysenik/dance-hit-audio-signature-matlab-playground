function metadata = loadMetadata(jsonPath)
% LOADMETADATA Load track metadata from a JSON file.
%   metadata = loadMetadata(jsonPath) parses the JSON file and returns
%   a struct array with fields: title, artist, bpm, genre, origin,
%   songwriters, dominant_features, year, label, key, subgenre, filename.

    if nargin < 1
        config = AnalysisConfig();
        jsonPath = fullfile(config.metadataDir, 'demo_tracks.json');
    end

    if ~isfile(jsonPath)
        error('loadMetadata:FileNotFound', 'Metadata file not found: %s', jsonPath);
    end

    raw = fileread(jsonPath);
    data = jsondecode(raw);

    if isfield(data, 'tracks')
        if iscell(data.tracks)
            metadata = [data.tracks{:}];
        else
            metadata = data.tracks;
        end
    else
        metadata = data;
    end
end
