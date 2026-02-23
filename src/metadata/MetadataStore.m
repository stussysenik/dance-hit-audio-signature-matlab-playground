classdef MetadataStore < handle
% METADATASTORE In-memory metadata store with query methods.
%   store = MetadataStore() creates an empty store.
%   store = MetadataStore(jsonPath) loads metadata from JSON file.
%
%   Methods:
%     add(entry)          - Add a metadata entry
%     getAll()            - Get all entries
%     filterByGenre(g)    - Filter entries by genre
%     filterByArtist(a)   - Filter entries by artist name
%     filterByOrigin(o)   - Filter entries by origin/city
%     sortByYear()        - Sort entries by year ascending
%     findByFilename(f)   - Find entry by filename

    properties (Access = private)
        entries = struct([])
    end

    methods
        function obj = MetadataStore(jsonPath)
            if nargin > 0 && ~isempty(jsonPath)
                obj.entries = loadMetadata(jsonPath);
            end
        end

        function add(obj, entry)
            if isempty(obj.entries)
                obj.entries = entry;
            else
                obj.entries(end+1) = entry;
            end
        end

        function result = getAll(obj)
            result = obj.entries;
        end

        function result = filterByGenre(obj, genre)
            if isempty(obj.entries)
                result = struct([]);
                return;
            end
            mask = arrayfun(@(e) contains(lower(e.genre), lower(genre)), obj.entries);
            result = obj.entries(mask);
        end

        function result = filterByArtist(obj, artist)
            if isempty(obj.entries)
                result = struct([]);
                return;
            end
            mask = arrayfun(@(e) contains(lower(e.artist), lower(artist)), obj.entries);
            result = obj.entries(mask);
        end

        function result = filterByOrigin(obj, origin)
            if isempty(obj.entries)
                result = struct([]);
                return;
            end
            mask = arrayfun(@(e) contains(lower(e.origin), lower(origin)), obj.entries);
            result = obj.entries(mask);
        end

        function result = sortByYear(obj)
            if isempty(obj.entries)
                result = struct([]);
                return;
            end
            years = [obj.entries.year];
            [~, idx] = sort(years);
            result = obj.entries(idx);
        end

        function result = findByFilename(obj, filename)
            if isempty(obj.entries)
                result = struct([]);
                return;
            end
            mask = arrayfun(@(e) strcmp(e.filename, filename), obj.entries);
            result = obj.entries(mask);
        end

        function saveToJSON(obj, jsonPath)
            data.tracks = obj.entries;
            jsonStr = jsonencode(data, 'PrettyPrint', true);
            fid = fopen(jsonPath, 'w');
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
        end
    end
end
