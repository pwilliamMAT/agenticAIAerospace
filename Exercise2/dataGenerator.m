% DATAGENERATOR Create the reusable ASR-12 training radar object.

% Datasheet values are kept in their documented property units: Hz, m, deg.
radar = radarDataGenerator(1, ...
    UpdateRate=1.0, ...                    % Hz; one update per 60 rpm scan
    ScanMode="Mechanical", ...
    MaxAzimuthScanRate=360, ...            % deg/s; 60 rpm
    MechanicalAzimuthLimits=[0 360], ...   % deg
    HasElevation=true, ...
    HasRangeAmbiguities=true, ...
    CenterFrequency=2.80e9, ...            % Hz; 2.80 GHz
    DetectionProbability=0.90, ...
    FalseAlarmRate=1.0e-6, ...
    ReferenceRange=444e3, ...              % m; 240 nmi instrumented range
    ReferenceRCS=pow2db(10), ...           % dBsm; datasheet value is 10 m^2
    FieldOfView=[1.4 20], ...              % deg; az beamwidth, vertical FOV
    AzimuthResolution=0.176, ...           % deg exercise measurement accuracy
    RangeResolution=323, ...               % m; c*tau/2 nominal resolution
    RangeLimits=[0 444e3], ...             % m; instrumented reporting gate
    MaxUnambiguousRange=461e3);            % m; applicable with ambiguities on
