function generateDemoDataset(config)
% GENERATEDEMODATASET Generate 10 synthetic demo tracks with known properties.
%   generateDemoDataset(config) creates WAV files in data/demo/ and metadata JSON.
%
%   Each track has distinct characteristics to exercise all 8 feature dimensions.

    if nargin < 1
        config = AnalysisConfig();
    end

    demoDir = config.demoDir;
    metaDir = config.metadataDir;

    if ~isfolder(demoDir); mkdir(demoDir); end
    if ~isfolder(metaDir); mkdir(metaDir); end

    fs = config.targetSampleRate;

    % Track definitions: each emphasizes different dimensions
    tracks = struct();

    tracks(1).name = 'demo_track_01_deep_house';
    tracks(1).bpm = 122;
    tracks(1).duration = 45;
    tracks(1).bassLevel = 0.9;
    tracks(1).vocalLevel = 0.3;
    tracks(1).beatLevel = 0.6;
    tracks(1).complexity = 0.3;
    tracks(1).harmonics = 0.5;
    tracks(1).dynamics = 0.4;
    tracks(1).genre = 'Deep House';
    tracks(1).artist = 'Synth Collective';
    tracks(1).origin = 'Berlin';
    tracks(1).songwriters = {'A. Synth', 'B. Bass'};
    tracks(1).dominant = 'Bass Energy';

    tracks(2).name = 'demo_track_02_vocal_house';
    tracks(2).bpm = 126;
    tracks(2).duration = 40;
    tracks(2).bassLevel = 0.5;
    tracks(2).vocalLevel = 0.95;
    tracks(2).beatLevel = 0.6;
    tracks(2).complexity = 0.4;
    tracks(2).harmonics = 0.7;
    tracks(2).dynamics = 0.5;
    tracks(2).genre = 'Vocal House';
    tracks(2).artist = 'Aria Vox';
    tracks(2).origin = 'Chicago';
    tracks(2).songwriters = {'C. Voice'};
    tracks(2).dominant = 'Vocal Presence';

    tracks(3).name = 'demo_track_03_techno';
    tracks(3).bpm = 138;
    tracks(3).duration = 50;
    tracks(3).bassLevel = 0.7;
    tracks(3).vocalLevel = 0.1;
    tracks(3).beatLevel = 0.95;
    tracks(3).complexity = 0.5;
    tracks(3).harmonics = 0.3;
    tracks(3).dynamics = 0.6;
    tracks(3).genre = 'Techno';
    tracks(3).artist = 'Pulse Machine';
    tracks(3).origin = 'Detroit';
    tracks(3).songwriters = {'D. Kick'};
    tracks(3).dominant = 'Beat Strength';

    tracks(4).name = 'demo_track_04_progressive';
    tracks(4).bpm = 128;
    tracks(4).duration = 55;
    tracks(4).bassLevel = 0.5;
    tracks(4).vocalLevel = 0.3;
    tracks(4).beatLevel = 0.5;
    tracks(4).complexity = 0.4;
    tracks(4).harmonics = 0.6;
    tracks(4).dynamics = 0.95;
    tracks(4).genre = 'Progressive House';
    tracks(4).artist = 'Slow Build';
    tracks(4).origin = 'Amsterdam';
    tracks(4).songwriters = {'E. Rise', 'F. Drop'};
    tracks(4).dominant = 'Dynamic Range';

    tracks(5).name = 'demo_track_05_drum_n_bass';
    tracks(5).bpm = 174;
    tracks(5).duration = 35;
    tracks(5).bassLevel = 0.8;
    tracks(5).vocalLevel = 0.2;
    tracks(5).beatLevel = 0.8;
    tracks(5).complexity = 0.95;
    tracks(5).harmonics = 0.4;
    tracks(5).dynamics = 0.7;
    tracks(5).genre = 'Drum and Bass';
    tracks(5).artist = 'Break Freq';
    tracks(5).origin = 'London';
    tracks(5).songwriters = {'G. Break'};
    tracks(5).dominant = 'Rhythm Complexity';

    tracks(6).name = 'demo_track_06_trance';
    tracks(6).bpm = 140;
    tracks(6).duration = 50;
    tracks(6).bassLevel = 0.4;
    tracks(6).vocalLevel = 0.4;
    tracks(6).beatLevel = 0.6;
    tracks(6).complexity = 0.3;
    tracks(6).harmonics = 0.95;
    tracks(6).dynamics = 0.6;
    tracks(6).genre = 'Trance';
    tracks(6).artist = 'Harmonia';
    tracks(6).origin = 'Goa';
    tracks(6).songwriters = {'H. Chord', 'I. Pad'};
    tracks(6).dominant = 'Harmonic Richness';

    tracks(7).name = 'demo_track_07_electro';
    tracks(7).bpm = 130;
    tracks(7).duration = 40;
    tracks(7).bassLevel = 0.6;
    tracks(7).vocalLevel = 0.2;
    tracks(7).beatLevel = 0.7;
    tracks(7).complexity = 0.5;
    tracks(7).harmonics = 0.5;
    tracks(7).dynamics = 0.5;
    tracks(7).genre = 'Electro';
    tracks(7).artist = 'Flux State';
    tracks(7).origin = 'Paris';
    tracks(7).songwriters = {'J. Warp'};
    tracks(7).dominant = 'Spectral Flux';

    tracks(8).name = 'demo_track_08_minimal';
    tracks(8).bpm = 124;
    tracks(8).duration = 45;
    tracks(8).bassLevel = 0.5;
    tracks(8).vocalLevel = 0.1;
    tracks(8).beatLevel = 0.5;
    tracks(8).complexity = 0.2;
    tracks(8).harmonics = 0.3;
    tracks(8).dynamics = 0.3;
    tracks(8).genre = 'Minimal Techno';
    tracks(8).artist = 'Sparse Signal';
    tracks(8).origin = 'Bucharest';
    tracks(8).songwriters = {'K. Click'};
    tracks(8).dominant = 'BPM Stability';

    tracks(9).name = 'demo_track_09_afro_house';
    tracks(9).bpm = 118;
    tracks(9).duration = 50;
    tracks(9).bassLevel = 0.7;
    tracks(9).vocalLevel = 0.6;
    tracks(9).beatLevel = 0.7;
    tracks(9).complexity = 0.8;
    tracks(9).harmonics = 0.6;
    tracks(9).dynamics = 0.5;
    tracks(9).genre = 'Afro House';
    tracks(9).artist = 'Ubuntu Beat';
    tracks(9).origin = 'Johannesburg';
    tracks(9).songwriters = {'L. Drum', 'M. Shaker'};
    tracks(9).dominant = 'Rhythm Complexity';

    tracks(10).name = 'demo_track_10_EDM_festival';
    tracks(10).bpm = 150;
    tracks(10).duration = 40;
    tracks(10).bassLevel = 0.9;
    tracks(10).vocalLevel = 0.5;
    tracks(10).beatLevel = 0.9;
    tracks(10).complexity = 0.6;
    tracks(10).harmonics = 0.7;
    tracks(10).dynamics = 0.9;
    tracks(10).genre = 'EDM';
    tracks(10).artist = 'Drop Factory';
    tracks(10).origin = 'Las Vegas';
    tracks(10).songwriters = {'N. Build', 'O. Drop'};
    tracks(10).dominant = 'Dynamic Range';

    % Generate audio for each track
    metadata = struct('tracks', {{}});

    for i = 1:length(tracks)
        t = tracks(i);
        signal = synthesizeTrack(t, fs);
        filePath = fullfile(demoDir, [t.name '.wav']);
        audiowrite(filePath, signal, fs);

        % Build metadata entry
        entry = struct();
        entry.title = strrep(t.name, '_', ' ');
        entry.artist = t.artist;
        entry.bpm = t.bpm;
        entry.genre = t.genre;
        entry.origin = t.origin;
        entry.songwriters = t.songwriters;
        entry.dominant_features = t.dominant;
        entry.year = 2024;
        entry.label = 'Demo Records';
        entry.key = camelotKey(i);
        entry.subgenre = t.genre;
        entry.filename = [t.name '.wav'];
        metadata.tracks{end+1} = entry;
    end

    % Write metadata JSON
    jsonStr = jsonencode(metadata, 'PrettyPrint', true);
    fid = fopen(fullfile(metaDir, 'demo_tracks.json'), 'w');
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
end

function signal = synthesizeTrack(t, fs)
% SYNTHESIZETRACK Create a synthetic audio track with specified characteristics.
    duration = t.duration;
    numSamples = round(duration * fs);
    time = (0:numSamples-1)' / fs;
    signal = zeros(numSamples, 1);
    beatPeriod = 60 / t.bpm;

    % Layer 1: Bass (sine waves at fundamental + harmonics in 20-250 Hz range)
    bassFreq = 55 + randi(40);  % Random fundamental in bass range
    bass = t.bassLevel * 0.4 * sin(2 * pi * bassFreq * time);
    bass = bass + t.bassLevel * 0.15 * sin(2 * pi * bassFreq * 2 * time);
    % Add pulsing rhythm to bass
    bassEnv = 0.5 + 0.5 * cos(2 * pi * (t.bpm / 60) * time);
    bass = bass .* bassEnv;
    signal = signal + bass;

    % Layer 2: Kick drum (short burst at beat positions)
    kickTimes = 0:beatPeriod:duration;
    for ki = 1:length(kickTimes)
        kickStart = round(kickTimes(ki) * fs) + 1;
        kickLen = round(0.05 * fs);  % 50ms kick
        if kickStart + kickLen - 1 <= numSamples
            kickTime = (0:kickLen-1)' / fs;
            kick = t.beatLevel * 0.6 * sin(2 * pi * 60 * kickTime) .* exp(-40 * kickTime);
            signal(kickStart:kickStart+kickLen-1) = signal(kickStart:kickStart+kickLen-1) + kick;
        end
    end

    % Layer 3: Hi-hats / percussion (noise bursts for rhythm complexity)
    if t.complexity > 0.3
        subdiv = round(beatPeriod * fs / (2 + round(t.complexity * 4)));
        hihatLen = round(0.01 * fs);
        for h = 1:subdiv:numSamples-hihatLen
            if rand < t.complexity
                hihat = t.beatLevel * 0.15 * randn(hihatLen, 1) .* exp(-200 * (0:hihatLen-1)' / fs);
                signal(h:h+hihatLen-1) = signal(h:h+hihatLen-1) + hihat;
            end
        end
    end

    % Layer 4: Vocal simulation (formant-like filtered noise in 300-3400 Hz)
    if t.vocalLevel > 0.2
        vocalNoise = randn(numSamples, 1);
        % Simple bandpass via sinusoidal modulation
        formant1 = 800 + 200 * rand;
        formant2 = 2200 + 300 * rand;
        vocal = t.vocalLevel * 0.15 * sin(2 * pi * formant1 * time) .* (0.5 + 0.5 * sin(2 * pi * 2.3 * time));
        vocal = vocal + t.vocalLevel * 0.08 * sin(2 * pi * formant2 * time) .* (0.5 + 0.5 * sin(2 * pi * 1.7 * time));
        % Add breathy quality
        vocal = vocal + t.vocalLevel * 0.05 * vocalNoise .* (0.3 + 0.7 * abs(sin(2 * pi * 0.5 * time)));
        signal = signal + vocal;
    end

    % Layer 5: Harmonic pad (chord simulation)
    if t.harmonics > 0.3
        chordFreqs = [261.6, 329.6, 392.0, 523.3];  % C major chord
        for ci = 1:length(chordFreqs)
            pad = t.harmonics * 0.06 * sin(2 * pi * chordFreqs(ci) * time);
            % Slow modulation
            pad = pad .* (0.5 + 0.5 * sin(2 * pi * 0.1 * ci * time));
            signal = signal + pad;
        end
    end

    % Layer 6: Dynamic variation (crescendo/decrescendo for dynamic range)
    if t.dynamics > 0.5
        % Create build-up and drop pattern
        envTime = time / duration;
        dynEnv = ones(numSamples, 1);
        % Build from 0.3 to 1.0 in first third
        buildMask = envTime < 0.33;
        dynEnv(buildMask) = 0.3 + 0.7 * (envTime(buildMask) / 0.33);
        % Drop at 2/3 point
        dropMask = envTime > 0.6 & envTime < 0.7;
        dynEnv(dropMask) = 0.3;
        % Rebuild
        rebuildMask = envTime >= 0.7;
        dynEnv(rebuildMask) = 0.3 + 0.7 * ((envTime(rebuildMask) - 0.7) / 0.3);
        signal = signal .* (dynEnv .^ t.dynamics);
    end

    % Layer 7: Spectral flux events (filter sweeps for spectral change)
    if t.name(end) == 'o'  % electro track
        sweepFreq = 200 + 2000 * sin(2 * pi * 0.2 * time).^2;
        sweep = 0.1 * sin(2 * pi * cumsum(sweepFreq) / fs);
        signal = signal + sweep;
    end

    % Normalize to prevent clipping
    signal = signal / (max(abs(signal)) + eps) * 0.9;
end

function k = camelotKey(idx)
% CAMELOTKEY Return a Camelot wheel key notation for given index.
    keys = {'1A', '2B', '3A', '4B', '5A', '6B', '7A', '8B', '9A', '10B', ...
            '11A', '12B'};
    k = keys{mod(idx-1, 12) + 1};
end
