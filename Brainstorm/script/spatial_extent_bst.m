function extent = spatial_extent_bst(ResultFile, time, threshold)
% SPATIAL_EXTENT_BST
%
% Descriptive index of the spatial extent of a Brainstorm source map.
%
% It returns the fraction and percentage of cortical sources whose
% absolute amplitude is greater than or equal to a given fraction
% of the maximum absolute source amplitude.
%
% Usage:
%   extent = spatial_extent_bst(ResultFile)
%   extent = spatial_extent_bst(ResultFile, 0.170, 0.5)
%
% Defaults:
%   time      = 0.170 s
%   threshold = 0.5

if nargin < 2 || isempty(time)
    time = 0.170;
end

if nargin < 3 || isempty(threshold)
    threshold = 0.5;
end

%% Load full source results

ResultMat = in_bst_results(ResultFile, 1);

X    = ResultMat.ImageGridAmp;
Time = ResultMat.Time;

if isempty(X)
    error('No source time series found in ImageGridAmp.');
end

%% Find sample closest to requested time

[~, timeIdx] = min(abs(Time - time));
actualTime = Time(timeIdx);

%% Absolute source amplitudes

frame = abs(X(:, timeIdx));
maxAmplitude = max(frame);

if maxAmplitude == 0
    error('Maximum source amplitude is zero.');
end

%% Fraction of sources above threshold

mask = frame >= threshold * maxAmplitude;

nSources = numel(frame);
nAboveThreshold = sum(mask);

extentFraction = nAboveThreshold / nSources;
extentPercent  = 100 * extentFraction;

%% Output

extent = table( ...
    actualTime, ...
    threshold, ...
    nSources, ...
    nAboveThreshold, ...
    extentFraction, ...
    extentPercent, ...
    'VariableNames', { ...
    'time_s', ...
    'threshold', ...
    'n_sources', ...
    'n_above_threshold', ...
    'extent_fraction', ...
    'extent_percent'});

fprintf('\nSpatial extent descriptive index at %.1f ms\n', ...
    actualTime * 1000);

fprintf('Sources >= %.0f%% of maximum: %.2f%%\n\n', ...
    threshold * 100, extentPercent);

disp(extent)

end