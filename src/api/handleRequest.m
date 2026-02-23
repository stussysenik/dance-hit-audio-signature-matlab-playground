function response = handleRequest(endpoint, params, config)
% HANDLEREQUEST Route API requests to analysis functions.
%   response = handleRequest(endpoint, params, config)
%
%   Returns struct with .status (HTTP code) and .body (JSON-serializable struct).

    if nargin < 3
        config = AnalysisConfig();
    end

    try
        switch endpoint
            case '/analyze'
                response = handleAnalyze(params, config);
            case '/compare'
                response = handleCompare(params, config);
            case '/blend'
                response = handleBlend(params, config);
            case '/heatmap'
                response = handleHeatmapAPI(params, config);
            case '/health'
                response.status = 200;
                response.body = struct('status', 'ok', 'service', 'dance-hit-analyzer');
            otherwise
                response.status = 404;
                response.body = struct('error', 'Endpoint not found', 'path', endpoint);
        end
    catch ME
        response.status = 500;
        response.body = struct('error', ME.message, 'identifier', ME.identifier);
    end
end

function response = handleAnalyze(params, config)
    if ~isfield(params, 'file')
        response.status = 400;
        response.body = struct('error', 'Missing required parameter: file');
        return;
    end

    filePath = params.file;
    if ~isfile(filePath)
        response.status = 404;
        response.body = struct('error', 'File not found', 'path', filePath);
        return;
    end

    [signal, fs] = audioLoad(filePath, config);
    [segments, timeAxis] = windowSegment(signal, fs, config);
    [features, globalBPM] = extractFeatures(segments, fs, config);
    [hotness, hotIdx] = computeHotness(features, config);

    response.status = 200;
    response.body = struct();
    response.body.file = filePath;
    response.body.bpm = globalBPM;
    response.body.numSegments = size(features, 2);
    response.body.features = round(features, 4);
    response.body.hotness = round(hotness, 4);
    response.body.hot_segments = hotIdx;
    response.body.timeAxis = round(timeAxis, 3);
    response.body.dimensionNames = {config.dimensionNames};

    % Include metadata if available
    try
        meta = loadMetadata();
        [~, fname, ext] = fileparts(filePath);
        metaEntry = [];
        for m = 1:length(meta)
            if contains(meta(m).filename, fname)
                metaEntry = meta(m);
                break;
            end
        end
        if ~isempty(metaEntry)
            response.body.metadata = metaEntry;
        end
    catch
        % Metadata not available — skip
    end
end

function response = handleCompare(params, config)
    if ~isfield(params, 'files')
        response.status = 400;
        response.body = struct('error', 'Missing required parameter: files (comma-separated paths)');
        return;
    end

    filePaths = strsplit(params.files, ',');
    N = length(filePaths);

    if N < 2
        response.status = 400;
        response.body = struct('error', 'At least 2 files required for comparison');
        return;
    end

    featureCell = cell(1, N);
    hotIdxCell = cell(1, N);
    names = cell(1, N);

    for i = 1:N
        fp = strtrim(filePaths{i});
        if ~isfile(fp)
            response.status = 404;
            response.body = struct('error', 'File not found', 'path', fp);
            return;
        end
        [signal, fs] = audioLoad(fp, config);
        [segments, ~] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [~, hotIdx] = computeHotness(features, config);
        featureCell{i} = features;
        hotIdxCell{i} = hotIdx;
        [~, names{i}, ~] = fileparts(fp);
    end

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);

    response.status = 200;
    response.body = struct();
    response.body.similarity_matrix = round(simMatrix, 4);
    response.body.songs = names;
    response.body.size = N;
end

function response = handleBlend(params, config)
    if ~isfield(params, 'files')
        response.status = 400;
        response.body = struct('error', 'Missing required parameter: files');
        return;
    end

    K = 5;
    if isfield(params, 'k')
        K = str2double(params.k);
    end

    filePaths = strsplit(params.files, ',');
    if length(filePaths) < 2
        response.status = 400;
        response.body = struct('error', 'At least 2 files required');
        return;
    end

    allResults = struct();
    for i = 1:length(filePaths)
        fp = strtrim(filePaths{i});
        if ~isfile(fp)
            response.status = 404;
            response.body = struct('error', 'File not found', 'path', fp);
            return;
        end
        [signal, fs] = audioLoad(fp, config);
        [segments, timeAxis] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [hotness, hotIdx] = computeHotness(features, config);
        allResults(i).name = fp;
        allResults(i).filePath = fp;
        allResults(i).features = features;
        allResults(i).timeAxis = timeAxis;
        allResults(i).hotness = hotness;
        allResults(i).hotIdx = hotIdx;
        allResults(i).signal = signal;
        allResults(i).fs = fs;
    end

    blends = rankBlends(allResults, config);
    numShow = min(K, length(blends));

    blendList = struct();
    for i = 1:numShow
        b = blends(i);
        blendList(i).rank = i;
        blendList(i).trackA = b.trackA;
        blendList(i).trackB = b.trackB;
        blendList(i).score = round(b.score, 4);
        blendList(i).timeA = sprintf('%d:%05.2f', floor(b.timeA/60), mod(b.timeA, 60));
        blendList(i).timeB = sprintf('%d:%05.2f', floor(b.timeB/60), mod(b.timeB, 60));
        blendList(i).bpmCompat = round(b.bpmCompat, 4);
        blendList(i).energyMatch = round(b.energyMatch, 4);
        blendList(i).spectralComplement = round(b.spectralComplement, 4);
    end

    response.status = 200;
    response.body = struct('blends', blendList, 'total', length(blends));
end

function response = handleHeatmapAPI(params, config)
    if ~isfield(params, 'file')
        response.status = 400;
        response.body = struct('error', 'Missing required parameter: file');
        return;
    end

    filePath = params.file;
    if ~isfile(filePath)
        response.status = 404;
        response.body = struct('error', 'File not found', 'path', filePath);
        return;
    end

    format = 'json';
    if isfield(params, 'format')
        format = params.format;
    end

    [signal, fs] = audioLoad(filePath, config);
    [segments, timeAxis] = windowSegment(signal, fs, config);
    features = extractFeatures(segments, fs, config);
    [hotness, hotIdx] = computeHotness(features, config);

    if strcmp(format, 'json')
        response.status = 200;
        response.body = struct();
        response.body.timeAxis = round(timeAxis, 3);
        response.body.dimensionNames = {config.dimensionNames};
        response.body.features = round(features, 4);
        response.body.hotness = round(hotness, 4);
        response.body.hotSegments = hotIdx;
    else
        % PNG: generate figure, save, return path
        fig = plotHeatmap(features, timeAxis, hotness, hotIdx, filePath, config);
        pngPath = fullfile(tempdir, 'heatmap.png');
        saveas(fig, pngPath);
        close(fig);
        response.status = 200;
        response.body = struct('format', 'png', 'path', pngPath, ...
            'note', 'PNG saved to temp directory');
    end
end
