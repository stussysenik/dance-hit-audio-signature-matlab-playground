classdef cacheManager < handle
% CACHEMANAGER Hash-based caching of analysis results in .mat files.
%   cm = cacheManager() creates a cache manager with default config.
%   cm = cacheManager(config) uses custom config.
%
%   Methods:
%     result = get(key)       - Retrieve cached result (empty if miss)
%     put(key, result)        - Store result in cache
%     hit = has(key)          - Check if key exists in cache
%     clear()                 - Clear all cached results
%     key = makeKey(filePath, config) - Generate cache key from file + config

    properties (Access = private)
        cacheDir
        enabled
    end

    methods
        function obj = cacheManager(config)
            if nargin < 1
                config = AnalysisConfig();
            end
            obj.cacheDir = config.cacheDir;
            obj.enabled = config.enableCache;
            if obj.enabled && ~isfolder(obj.cacheDir)
                mkdir(obj.cacheDir);
            end
        end

        function result = get(obj, key)
            result = [];
            if ~obj.enabled; return; end

            cachePath = obj.keyToPath(key);
            if isfile(cachePath)
                data = load(cachePath, 'result');
                result = data.result;
            end
        end

        function put(obj, key, result)
            if ~obj.enabled; return; end

            cachePath = obj.keyToPath(key);
            save(cachePath, 'result', '-v7.3');
        end

        function hit = has(obj, key)
            if ~obj.enabled
                hit = false;
                return;
            end
            hit = isfile(obj.keyToPath(key));
        end

        function clearAll(obj)
            if isfolder(obj.cacheDir)
                delete(fullfile(obj.cacheDir, '*.mat'));
            end
        end

        function key = makeKey(~, filePath, config)
            % Generate deterministic key from file path + analysis params
            fileInfo = dir(filePath);
            if isempty(fileInfo)
                key = '';
                return;
            end
            % Hash: file path + size + date + window config
            hashInput = sprintf('%s_%d_%s_w%d_o%.2f', ...
                filePath, fileInfo.bytes, datestr(fileInfo.datenum), ...
                config.windowSamples, config.overlapRatio); %#ok<DATST>
            % Simple hash using sum of char codes
            hashVal = mod(sum(hashInput .* (1:length(hashInput))), 2^32);
            key = sprintf('cache_%010u', hashVal);
        end
    end

    methods (Access = private)
        function p = keyToPath(obj, key)
            p = fullfile(obj.cacheDir, [key '.mat']);
        end
    end
end
