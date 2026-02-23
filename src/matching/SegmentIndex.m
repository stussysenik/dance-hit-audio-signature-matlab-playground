classdef SegmentIndex < handle
% SEGMENTINDEX Precomputed index for O(1) segment lookup across N songs.
%   idx = SegmentIndex(allResults, config) builds a spatial hash index
%   over all segments from all tracks for instant similarity queries.
%
%   The index quantizes each 8D feature vector into a hash bucket,
%   enabling O(1) average-case lookups for "find segments similar to X."
%
%   Methods:
%     results = query(featureVec, K)       - Find K nearest segments
%     results = queryByDimension(dim, minVal, maxVal, K) - Filter by dimension range
%     results = queryHot(K)                - Get top-K hottest segments globally
%     results = queryBPMRange(bpmLow, bpmHigh, K) - Filter by BPM
%     stats   = getStats()                 - Index statistics
%
%   Each result is a struct: {songIdx, segIdx, songName, time, features, hotness}
%
%   Complexity:
%     Build:  O(totalSegments)
%     Query:  O(1) amortized for hash lookup + O(B*log(K)) for top-K in bucket
%     Memory: O(totalSegments)

    properties (Access = private)
        % Flat arrays for all segments across all songs
        allFeatures     % 8 x totalSegments
        allHotness      % 1 x totalSegments
        allSongIdx      % 1 x totalSegments (which song)
        allSegIdx       % 1 x totalSegments (segment index within song)
        allTimes        % 1 x totalSegments (time in seconds)
        songNames       % cell array of song names
        totalSegments   % scalar

        % Hash index: quantized feature vector -> segment indices
        hashMap         % containers.Map: hashKey -> array of flat indices
        hashBits        % number of quantization bits per dimension

        % Sorted indices for fast dimension-range queries
        dimSorted       % 8 x totalSegments: indices sorted by each dim value

        % Pre-sorted by hotness for queryHot
        hotnessSorted   % indices sorted by hotness descending

        config
    end

    methods
        function obj = SegmentIndex(allResults, config)
        % Build the index from analyzed results.
            if nargin < 2
                config = AnalysisConfig();
            end
            obj.config = config;
            obj.hashBits = 4;  % 4 bits per dim = 16 bins per dim

            N = length(allResults);
            obj.songNames = {allResults.name};

            % Count total segments
            totalSegs = 0;
            for i = 1:N
                totalSegs = totalSegs + size(allResults(i).features, 2);
            end
            obj.totalSegments = totalSegs;

            % Allocate flat arrays
            obj.allFeatures = zeros(8, totalSegs);
            obj.allHotness = zeros(1, totalSegs);
            obj.allSongIdx = zeros(1, totalSegs);
            obj.allSegIdx = zeros(1, totalSegs);
            obj.allTimes = zeros(1, totalSegs);

            % Flatten all segments into a single index
            pos = 1;
            for i = 1:N
                nSeg = size(allResults(i).features, 2);
                range = pos:pos+nSeg-1;
                obj.allFeatures(:, range) = allResults(i).features;
                obj.allHotness(range) = allResults(i).hotness;
                obj.allSongIdx(range) = i;
                obj.allSegIdx(range) = 1:nSeg;
                if ~isempty(allResults(i).timeAxis)
                    obj.allTimes(range) = allResults(i).timeAxis(1:nSeg);
                end
                pos = pos + nSeg;
            end

            % Build hash index: quantize each feature vector to a bucket
            obj.hashMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for s = 1:totalSegs
                key = obj.featureToHash(obj.allFeatures(:, s));
                if obj.hashMap.isKey(key)
                    obj.hashMap(key) = [obj.hashMap(key), s];
                else
                    obj.hashMap(key) = s;
                end
            end

            % Pre-sort each dimension for range queries
            obj.dimSorted = zeros(8, totalSegs);
            for d = 1:8
                [~, obj.dimSorted(d, :)] = sort(obj.allFeatures(d, :));
            end

            % Pre-sort by hotness descending
            [~, obj.hotnessSorted] = sort(obj.allHotness, 'descend');

            fprintf('SegmentIndex built: %d segments across %d songs (%d hash buckets)\n', ...
                totalSegs, N, obj.hashMap.Count);
        end

        function results = query(obj, featureVec, K)
        % QUERY Find K segments most similar to the given feature vector.
        %   O(1) hash lookup + O(B) scan within bucket + neighbor buckets.
            if nargin < 3; K = 10; end

            % Get bucket and neighboring buckets
            centerKey = obj.featureToHash(featureVec);
            candidates = [];

            if obj.hashMap.isKey(centerKey)
                candidates = obj.hashMap(centerKey);
            end

            % If not enough candidates, expand to neighbor buckets
            if length(candidates) < K
                neighbors = obj.getNeighborKeys(featureVec);
                for n = 1:length(neighbors)
                    nKey = neighbors{n};
                    if obj.hashMap.isKey(nKey)
                        candidates = [candidates, obj.hashMap(nKey)]; %#ok<AGROW>
                    end
                    if length(candidates) >= K * 3
                        break;
                    end
                end
            end

            % Fallback: if still too few, brute-force top-K
            if length(candidates) < K
                dists = sum((obj.allFeatures - featureVec).^2, 1);
                [~, sortIdx] = sort(dists);
                candidates = sortIdx(1:min(K*3, length(sortIdx)));
            end

            % Rank candidates by distance
            candidates = unique(candidates);
            candFeatures = obj.allFeatures(:, candidates);
            dists = sum((candFeatures - featureVec).^2, 1);
            [~, sortIdx] = sort(dists);
            topIdx = candidates(sortIdx(1:min(K, length(sortIdx))));

            results = obj.indicesToResults(topIdx);
        end

        function results = queryByDimension(obj, dim, minVal, maxVal, K)
        % QUERYBYDIMENSION Find segments where dimension dim is in [minVal, maxVal].
        %   Uses pre-sorted index for O(log(N)) range lookup.
            if nargin < 5; K = 20; end

            sorted = obj.dimSorted(dim, :);
            vals = obj.allFeatures(dim, sorted);

            % Binary search for range boundaries
            lo = find(vals >= minVal, 1, 'first');
            hi = find(vals <= maxVal, 1, 'last');

            if isempty(lo) || isempty(hi) || lo > hi
                results = struct([]);
                return;
            end

            rangeIdx = sorted(lo:hi);

            % Sort by hotness within range, take top-K
            rangeHotness = obj.allHotness(rangeIdx);
            [~, hotSort] = sort(rangeHotness, 'descend');
            topIdx = rangeIdx(hotSort(1:min(K, length(hotSort))));

            results = obj.indicesToResults(topIdx);
        end

        function results = queryHot(obj, K)
        % QUERYHOT Get top-K hottest segments globally. O(K).
            if nargin < 2; K = 20; end
            topIdx = obj.hotnessSorted(1:min(K, obj.totalSegments));
            results = obj.indicesToResults(topIdx);
        end

        function results = queryBPMRange(obj, bpmLow, bpmHigh, K)
        % QUERYBPMRANGE Find hot segments with BPM stability in range.
            if nargin < 4; K = 20; end
            results = obj.queryByDimension(1, bpmLow, bpmHigh, K);
        end

        function results = querySimilarToSegment(obj, songIdx, segIdx, K)
        % QUERYSIMILARTOSEGMENT Find segments similar to a specific segment.
            if nargin < 4; K = 10; end

            % Find the flat index for this segment
            mask = obj.allSongIdx == songIdx & obj.allSegIdx == segIdx;
            flatIdx = find(mask, 1);
            if isempty(flatIdx)
                results = struct([]);
                return;
            end

            featureVec = obj.allFeatures(:, flatIdx);
            allResults = obj.query(featureVec, K + 1);

            % Remove self from results
            keep = true(1, length(allResults));
            for r = 1:length(allResults)
                if allResults(r).songIdx == songIdx && allResults(r).segIdx == segIdx
                    keep(r) = false;
                end
            end
            results = allResults(keep);
            if length(results) > K
                results = results(1:K);
            end
        end

        function stats = getStats(obj)
        % GETSTATS Return index statistics.
            stats = struct();
            stats.totalSegments = obj.totalSegments;
            stats.numSongs = length(obj.songNames);
            stats.numBuckets = obj.hashMap.Count;
            stats.songNames = obj.songNames;

            % Bucket size distribution
            keys = obj.hashMap.keys;
            bucketSizes = zeros(1, length(keys));
            for i = 1:length(keys)
                bucketSizes(i) = length(obj.hashMap(keys{i}));
            end
            stats.meanBucketSize = mean(bucketSizes);
            stats.maxBucketSize = max(bucketSizes);
            stats.minBucketSize = min(bucketSizes);

            % Per-song segment counts
            stats.segmentsPerSong = zeros(1, stats.numSongs);
            for i = 1:stats.numSongs
                stats.segmentsPerSong(i) = sum(obj.allSongIdx == i);
            end
        end

        function printStats(obj)
        % PRINTSTATS Print index statistics to console.
            s = obj.getStats();
            fprintf('\n  SegmentIndex Statistics\n');
            fprintf('  ─────────────────────────────\n');
            fprintf('  Total segments:  %d\n', s.totalSegments);
            fprintf('  Songs indexed:   %d\n', s.numSongs);
            fprintf('  Hash buckets:    %d\n', s.numBuckets);
            fprintf('  Bucket size:     %.1f avg, %d max\n', s.meanBucketSize, s.maxBucketSize);
            fprintf('\n  Segments per song:\n');
            for i = 1:s.numSongs
                fprintf('    %s: %d segments\n', s.songNames{i}, s.segmentsPerSong(i));
            end
            fprintf('\n');
        end
    end

    methods (Access = private)
        function key = featureToHash(obj, featureVec)
        % Quantize 8D feature vector to a hash key string.
            bins = min(2^obj.hashBits - 1, floor(featureVec * 2^obj.hashBits));
            bins = max(0, bins);
            key = sprintf('%x', bins);
        end

        function neighbors = getNeighborKeys(obj, featureVec)
        % Get hash keys for neighboring buckets (offset by ±1 in each dim).
            bins = min(2^obj.hashBits - 1, floor(featureVec * 2^obj.hashBits));
            bins = max(0, bins);
            neighbors = {};
            for d = 1:8
                if bins(d) > 0
                    nb = bins;
                    nb(d) = nb(d) - 1;
                    neighbors{end+1} = sprintf('%x', nb); %#ok<AGROW>
                end
                if bins(d) < 2^obj.hashBits - 1
                    nb = bins;
                    nb(d) = nb(d) + 1;
                    neighbors{end+1} = sprintf('%x', nb); %#ok<AGROW>
                end
            end
        end

        function results = indicesToResults(obj, flatIndices)
        % Convert flat indices to result structs.
            K = length(flatIndices);
            results = struct('songIdx', {}, 'segIdx', {}, 'songName', {}, ...
                'time', {}, 'features', {}, 'hotness', {});
            for i = 1:K
                fi = flatIndices(i);
                results(i).songIdx = obj.allSongIdx(fi);
                results(i).segIdx = obj.allSegIdx(fi);
                results(i).songName = obj.songNames{obj.allSongIdx(fi)};
                results(i).time = obj.allTimes(fi);
                results(i).features = obj.allFeatures(:, fi);
                results(i).hotness = obj.allHotness(fi);
            end
        end
    end
end
