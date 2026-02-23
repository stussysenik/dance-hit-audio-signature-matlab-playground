% MAIN  Entry point for the Dance Hit Audio Signature system.
%   Adds all source directories to path, then launches the quickstart demo.

% Add source paths
rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir, 'src')));

fprintf('=============================================================\n');
fprintf('  Dance Hit Audio Signature Analyzer\n');
fprintf('  Multidimensional Audio Feature Extraction & DJ Blend Tool\n');
fprintf('=============================================================\n\n');

% Run quickstart
quickstart;
