%% dataGenerator
% Reusable radarDataGenerator configured from SurveillanceRadar.pdf values.

radar = radarDataGenerator(1, ...
    UpdateRate=1, ...                              % 1 Hz reporting update
    ScanMode="Mechanical and electronic", ...
    MechanicalAzimuthLimits=[-180 180], ...        % 360 deg mechanical coverage
    ElectronicElevationLimits=[-20 0], ...        % Centered 20 deg elevation sector
    FieldOfView=[30 20], ...                        % [azimuth elevation], deg
    HasElevation=true, ...
    HasRangeRate=true, ...
    AzimuthResolution=2.8, ...                      % Datasheet reporting resolution, deg
    ElevationResolution=2.23, ...                   % Datasheet reporting resolution, deg
    RangeResolution=323, ...                        % Datasheet reporting resolution, m
    RangeRateResolution=100, ...                    % Datasheet reporting resolution, m/s
    DetectionProbability=0.90, ...
    FalseAlarmRate=1e-6, ...
    ReferenceRange=463e3, ...                       % Exercise evaluation range, m
    ReferenceRCS=pow2db(10), ...                    % Representative 10 m^2 target, dBsm
    RangeLimits=[0 500e3]);                         % Datasheet nominal unambiguous span, m