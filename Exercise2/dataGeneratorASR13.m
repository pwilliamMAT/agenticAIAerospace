% DATAGENERATORASR13 Create the baseline ASR-13 surveillance radar object.

% ASR-13 baseline mode: a 12.5 rpm mechanically scanned 1.4 x 4.5 deg beam.
% The datasheet's 0-30 deg elevation coverage requires external beam scheduling;
% this reusable radarDataGenerator object represents one physical beam.
radar = radarDataGenerator(13, ...
    UpdateRate=1/4.8, ...                 % Hz; one report opportunity per revolution
    ScanMode="Mechanical", ...
    MaxAzimuthScanRate=75, ...            % deg/s; 12.5 rpm
    MechanicalAzimuthLimits=[0 360], ...  % deg; total azimuth coverage
    HasElevation=true, ...
    HasRangeAmbiguities=true, ...
    CenterFrequency=2.80e9, ...           % Hz
    DetectionProbability=0.90, ...
    FalseAlarmRate=1.0e-6, ...
    ReferenceRange=50*1852, ...           % m; 50 nmi Pd reference condition
    ReferenceRCS=pow2db(10), ...          % dBsm; 10 m^2 target
    FieldOfView=[1.4 4.5], ...            % deg; instantaneous physical beam
    AzimuthResolution=0.12, ...           % deg; exercise 1-sigma accuracy
    RangeResolution=120, ...              % m; c*tau/2 for 0.80 us pulse
    RangeLimits=[1.5*1852 60*1852], ...   % m; documented instrumented reporting gate
    MaxUnambiguousRange=150e3);           % m; 1,000 Hz baseline waveform
