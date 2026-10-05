%% ASR-12 training radarDataGenerator configuration
% Values are taken from ASR-12-WorkshopRadar.pdf. This file only defines
% the generator object so it can be reused by a future radar scenario.

clear; clc;

asr12Radar = radarDataGenerator(1, ...
    "UpdateRate", 1, ...                                  % 60 rpm = 1 scan/s
    "ScanMode", "Mechanical", ...
    "MaxAzimuthScanRate", 360, ...                        % deg/s
    "MechanicalAzimuthLimits", [0 360], ...
    "DetectionMode", "Monostatic", ...
    "HasElevation", true, ...
    "CenterFrequency", 2.80e9, ...                        % Hz
    "Bandwidth", 1/2.15e-6, ...                           % Hz, from uncompressed pulse width
    "FieldOfView", [2.8 2.2], ...                         % deg, 3 dB az/el beamwidths
    "RangeLimits", [0 250*1852], ...                      % m, 250 nmi
    "RangeResolution", physconst("LightSpeed")*2.15e-6/2, ... % m
    "AzimuthResolution", 0.176, ...                       % deg
    "ElevationResolution", 2.2, ...                       % deg
    "DetectionProbability", 0.90, ...
    "FalseAlarmRate", 1.0e-6, ...
    "ReferenceRange", 463e3, ...                          % m
    "ReferenceRCS", pow2db(10), ...                       % dBsm
    "MountingLocation", [0 0 10], ...                     % m
    "HasNoise", true, ...
    "HasFalseAlarms", true, ...
    "TargetReportFormat", "Detections");

disp(asr12Radar);
