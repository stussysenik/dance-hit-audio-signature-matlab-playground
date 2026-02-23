function server = startServer(config)
% STARTSERVER Start HTTP API server for audio analysis.
%   server = startServer() starts on default port 8080.
%   server = startServer(config) uses custom config.
%
%   Endpoints:
%     GET /analyze?file=<path>           - Feature matrix + hotness as JSON
%     GET /compare?files=<p1>,<p2>,...   - Similarity matrix as JSON
%     GET /blend?files=<p1>,<p2>&k=<n>  - Blend recommendations as JSON
%     GET /heatmap?file=<path>&format=json|png - Heatmap data or image
%
%   Stop with: delete(server) or server.stop()

    if nargin < 1
        config = AnalysisConfig();
    end

    port = config.apiPort;

    % Use tcpserver-based HTTP server (compatible with most MATLAB versions)
    server = tcpserver('0.0.0.0', port, 'ConnectionChangedFcn', ...
        @(src, evt) handleConnection(src, evt, config));

    fprintf('Dance Hit API Server started on port %d\n', port);
    fprintf('Endpoints:\n');
    fprintf('  GET http://localhost:%d/analyze?file=<path>\n', port);
    fprintf('  GET http://localhost:%d/compare?files=<path1>,<path2>\n', port);
    fprintf('  GET http://localhost:%d/blend?files=<path1>,<path2>&k=5\n', port);
    fprintf('  GET http://localhost:%d/heatmap?file=<path>&format=json\n', port);
    fprintf('\nStop server: delete(server)\n');
end

function handleConnection(server, ~, config)
    if server.Connected
        % Read HTTP request
        pause(0.1);  % Wait for data
        if server.NumBytesAvailable > 0
            rawData = read(server, server.NumBytesAvailable, 'char');
            request = char(rawData);

            % Parse HTTP request line
            lines = strsplit(request, newline);
            if isempty(lines)
                return;
            end
            requestLine = strtrim(lines{1});
            parts = strsplit(requestLine, ' ');
            if length(parts) < 2
                return;
            end
            method = parts{1};
            fullPath = parts{2};

            if ~strcmp(method, 'GET')
                sendResponse(server, 405, struct('error', 'Method not allowed'));
                return;
            end

            % Parse path and query
            pathParts = strsplit(fullPath, '?');
            endpoint = pathParts{1};
            params = struct();
            if length(pathParts) > 1
                params = parseQuery(pathParts{2});
            end

            % Route to handler
            response = handleRequest(endpoint, params, config);
            sendResponse(server, response.status, response.body);
        end
    end
end

function params = parseQuery(queryStr)
    params = struct();
    pairs = strsplit(queryStr, '&');
    for i = 1:length(pairs)
        kv = strsplit(pairs{i}, '=');
        if length(kv) == 2
            key = strrep(kv{1}, '-', '_');
            params.(key) = urldecode(kv{2});
        end
    end
end

function sendResponse(server, statusCode, body)
    statusTexts = struct('s200', 'OK', 's400', 'Bad Request', ...
                         's404', 'Not Found', 's500', 'Internal Server Error', ...
                         's405', 'Method Not Allowed');
    field = sprintf('s%d', statusCode);
    if isfield(statusTexts, field)
        statusText = statusTexts.(field);
    else
        statusText = 'Unknown';
    end

    jsonBody = jsonencode(body);

    httpResponse = sprintf(['HTTP/1.1 %d %s\r\n' ...
        'Content-Type: application/json\r\n' ...
        'Access-Control-Allow-Origin: *\r\n' ...
        'Content-Length: %d\r\n' ...
        '\r\n' ...
        '%s'], ...
        statusCode, statusText, length(jsonBody), jsonBody);

    write(server, uint8(httpResponse));
end

function decoded = urldecode(str)
    decoded = strrep(str, '+', ' ');
    decoded = strrep(decoded, '%20', ' ');
    decoded = strrep(decoded, '%2F', '/');
    decoded = strrep(decoded, '%2C', ',');
end
