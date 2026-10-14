function scene = helperCreateWideAreaSurveillanceScenario(groundRadar)
% Adapted from the R2026a Wide Area Surveillance Using Radars example.
% The supplied radar is cloned for the three stationary ground sites.

% Set random seed for predictable results
rng(2020);

% Create scenario
scene = radarScenario('IsEarthCentered',true,...
    'UpdateRate',1,'StopTime',100);
scene.SurfaceManager.UseOcclusion = true;

% Add ground radars at each ARTCC site
radarsitesLLA = [41.4228  -88.0583  100;...
    40.6989  -89.8258  100;...
    39.2219  -95.2461  100];

refFrames = ["NED","ENU","NED"];
yaw = [30 -15 10];
pitch = [0 0 0];
roll = [0 0 0];
platformOrient = rotmat(quaternion([yaw' pitch' roll'],'eulerd','ZYX','frame'),'frame');

for i = 1:3
    radar = clone(groundRadar);
    if strcmpi(refFrames(i),'ENU')
        radar.MechanicalElevationLimits = [0 20-1e-3];
    end
    radar.SensorIndex = i;
    traj = geoTrajectory(radarsitesLLA(i,:),'ReferenceFrame',refFrames(i),...
        'Orientation',platformOrient(:,:,i));
    platform(scene,'Trajectory',traj,...
        'Signatures',rcsSignature('Pattern',-50),'Sensors',{radar});
end

wp = [39.9187  -88.1086   10e3
   39.9672  -88.5993   10e3
   40.1058  -89.1765   10e3
   40.3124  -89.9155   10e3
   40.4117  -90.2386   10e3
   40.5338  -90.5222   10e3
   40.7433  -90.8611   10e3
   40.9717  -91.2950   10e3
   41.2275  -91.8688   10e3
   41.3591  -92.2271   10e3
   41.4218  -92.6535   10e3];
time = linspace(0,4720,size(wp,1));

radar = createAirborneRadar(4);

platform(scene,'Trajectory',geoTrajectory(wp,time,"ReferenceFrame","ENU"),'Sensors',{radar},...
    'Signatures',rcsSignature('Pattern',10));

wp = [41.7465  -92.0250   10e3
   41.1431  -91.1088   10e3
   40.7255  -90.8609   10e3
   40.3530  -90.6849   10e3
   39.8211  -90.6994   10e3
   39.3656  -90.7735   10e3
   39.9364  -90.9020   10e3
   38.5661  -91.0738   10e3
   38.2362  -91.1412   10e3];
time = linspace(0,4720,size(wp,1));

radar = createAirborneRadar(5);

platform(scene,'Trajectory',geoTrajectory(wp,time,"ReferenceFrame","ENU"),'Sensors',{radar},'Signatures',...
    rcsSignature('Pattern',10));

waypointFile = fullfile(fileparts(mfilename("fullpath")), ...
    "dWideAreaSurveillanceTargetWaypoints.mat");
waypointData = load(waypointFile, "tgts");
tgts = waypointData.tgts;

for i = 1:numel(tgts)
    wp = tgts(i).Position;
    t = tgts(i).Time;
    traj = geoTrajectory(wp,t);
    platform(scene,'Trajectory',traj);
end

function radar = createAirborneRadar(sensorIndex)
elevationAccuracy = atan2d(0.9,463);
elevationBiasFraction = 0.05;
radar = radarDataGenerator(sensorIndex,...
    'UpdateRate',1,...
    'FieldOfView',[30;20],...
    'HasElevation',true,...
    'ScanMode','Mechanical',...
    'MechanicalAzimuthLimits',[-90 90],...
    'MechanicalElevationLimits',[-10+1e-3 10-1e-3],...
    'HasINS',true,...
    'HasRangeRate',true,...
    'HasNoise',true,...
    'HasFalseAlarms',true,...
    'ReferenceRange',300000,...
    'ReferenceRCS',10,...
    'RangeLimits',[0 463000],...
    'AzimuthResolution',2.8,...
    'AzimuthBiasFraction',0.176/2.8,...
    'ElevationResolution',elevationAccuracy/elevationBiasFraction,...
    'ElevationBiasFraction',elevationBiasFraction,...
    'RangeResolution',323,...
    'RangeBiasFraction',116/323,...
    'RangeRateResolution',100,...
    'FalseAlarmRate',1e-7,...
    'RangeRateLimits',[-500 500],...
    'DetectionCoordinates','Sensor spherical');
radar.MountingAngles = [0 0 0];
end

end
