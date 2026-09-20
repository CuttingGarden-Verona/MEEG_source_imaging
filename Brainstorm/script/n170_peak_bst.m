function peak = n170_peak_bst(ResultFile, tmin, tmax)
% N170_PEAK_BST
%
% Find the maximum absolute cortical source activity within the
% N170 time window and return its latency, amplitude and MNI coordinates.
%
% Usage:
%   peak = n170_peak_bst(ResultFile)
%   peak = n170_peak_bst(ResultFile, 0.120, 0.220)
%
% INPUT
% -----
% ResultFile : Brainstorm source result file
%              In Brainstorm:
%              right-click source result
%              -> File -> Copy file path to clipboard
%
% tmin, tmax : analysis window in seconds
%              default: 0.120 - 0.220 s
%
% OUTPUT
% ------
% peak : one-row table containing:
%        peak_hemi
%        peak_vertex
%        peak_latency_s
%        peak_amplitude
%        peak_abs_amplitude
%        mni_x, mni_y, mni_z   [mm]


%% ------------------------------------------------------------
% Defaults
% -------------------------------------------------------------

if nargin < 2 || isempty(tmin)
    tmin = 0.120;
end

if nargin < 3 || isempty(tmax)
    tmax = 0.220;
end


%% ------------------------------------------------------------
% 1. Load full source results
%
% The second argument (=1) asks Brainstorm to return the full
% source time series even when the result is stored as a kernel.
% -------------------------------------------------------------

ResultMat = in_bst_results(ResultFile, 1);

X    = ResultMat.ImageGridAmp;
Time = ResultMat.Time;

if isempty(X)
    error('No source time series found in ImageGridAmp.');
end


%% ------------------------------------------------------------
% 2. Select the N170 window
% -------------------------------------------------------------

iTime = find(Time >= tmin & Time <= tmax);

if isempty(iTime)
    error('No samples found between %.0f and %.0f ms.', ...
          tmin * 1000, tmax * 1000);
end

Xwin = X(:, iTime);


%% ------------------------------------------------------------
% 3. Find maximum ABSOLUTE activity across sources x time
% -------------------------------------------------------------

[~, linearIdx] = max(abs(Xwin(:)));

[peakVertex, localTimeIdx] = ind2sub(size(Xwin), linearIdx);

peakTimeIdx = iTime(localTimeIdx);

peakLatency     = Time(peakTimeIdx);
peakAmplitude   = X(peakVertex, peakTimeIdx);
peakAbsAmplitude = abs(peakAmplitude);


%% ------------------------------------------------------------
% 4. Load the cortical surface
% -------------------------------------------------------------

SurfMat = in_tess_bst(ResultMat.SurfaceFile);

if peakVertex > size(SurfMat.Vertices, 1)
    error(['Peak source index exceeds the number of vertices in the ' ...
           'associated cortical surface.']);
end

% Brainstorm surface coordinates are in SCS coordinates (meters)
peakScs = SurfMat.Vertices(peakVertex, :);


%% ------------------------------------------------------------
% 5. Get subject MRI
% -------------------------------------------------------------

sSubject = bst_get('SurfaceFile', ResultMat.SurfaceFile);

if isempty(sSubject)
    error('Could not identify the subject associated with the surface.');
end

if isempty(sSubject.Anatomy) || isempty(sSubject.iAnatomy)
    error('No MRI anatomy found for this subject.');
end

MriFile = sSubject.Anatomy(sSubject.iAnatomy).FileName;
sMri = in_mri_bst(MriFile);


%% ------------------------------------------------------------
% 6. Convert peak coordinates: SCS -> MNI
% -------------------------------------------------------------

peakMni = cs_convert(sMri, 'scs', 'mni', peakScs);

if isempty(peakMni)
    error(['MNI coordinates could not be computed. ' ...
           'Check that MNI normalization is available for the subject MRI.']);
end

% Brainstorm coordinate conversion returns coordinates in meters.
% Convert to millimeters for comparison with MNE.
peakMniMm = peakMni * 1000;


%% ------------------------------------------------------------
% 7. Determine hemisphere from MNI x coordinate
% -------------------------------------------------------------

if peakMniMm(1) < 0
    peakHemi = "lh";
elseif peakMniMm(1) > 0
    peakHemi = "rh";
else
    peakHemi = "midline";
end


%% ------------------------------------------------------------
% 8. Create output table
% -------------------------------------------------------------

peak = table( ...
    peakHemi, ...
    peakVertex, ...
    peakLatency, ...
    peakAmplitude, ...
    peakAbsAmplitude, ...
    peakMniMm(1), ...
    peakMniMm(2), ...
    peakMniMm(3), ...
    'VariableNames', { ...
        'peak_hemi', ...
        'peak_vertex', ...
        'peak_latency_s', ...
        'peak_amplitude', ...
        'peak_abs_amplitude', ...
        'mni_x', ...
        'mni_y', ...
        'mni_z'});


%% ------------------------------------------------------------
% 9. Display result
% -------------------------------------------------------------

fprintf('\nN170 source peak (%.0f-%.0f ms)\n', ...
        tmin * 1000, tmax * 1000);

disp(peak)

end