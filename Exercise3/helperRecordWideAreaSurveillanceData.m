function [sensorDataLog, truthDataLog] = helperRecordWideAreaSurveillanceData(scene)
% This is a helper function and may be removed or modified in a future
% release. 

% Counter for storing truth
count = 1;

% Allocate memory for truth and sensor logs
truthDataLog = cell(0,1);
sensorDataLog = cell(0,1);

% viewer = trackingGlobeViewer('NumCovarianceSigma',0);
% detBuffer = {};

% Run the scenario in a loop
while advance(scene)
    % Generate detections
    [dets, configs] = detect(scene);
    % detBuffer = [detBuffer;dets];
    % viewer.plotDetection([detBuffer;dets],'ECEF');
    % viewer.plotCoverage(coverageConfig(scene),'ECEF');

    for c = 1:numel(configs)
        configs(c).Time = scene.SimulationTime;
    end

    % Convert to the format required by the specs
    sensorData = convertToDataFormat(dets, configs, scene);

    % Truth data
    truthData = platformPoses(scene);
    % viewer.plotPlatform(truthData,'ECEF','TrajectoryMode','History');

    % Store data
    truthDataLog{count} = truthData;
    sensorDataLog{count} = sensorData;
    
    % Update counter
    count = count + 1;

    % Update display
    drawnow;
end
end

function sensorData = convertToDataFormat(detections, configs, scene)
numSensors = numel(unique([configs.SensorIndex]));
sensorData = cell(numSensors, 1);
cfgIndex = [configs.SensorIndex];
detIndex = cellfun(@(x)x.SensorIndex,detections);
numPlatforms = numel(scene.Platforms);
platIndex = zeros(numPlatforms,1);
for p = 1:numPlatforms
    if ~isempty(scene.Platforms{p}.Sensors)
        platIndex(p) = scene.Platforms{p}.Sensors{1}.SensorIndex;
    end
end
for i = 1:numSensors    
    cfgs = configs(cfgIndex == i);
    dets = detections(detIndex == i);
    plat = scene.Platforms{platIndex == i};
    sensorData{i} = convertToDataFormatOneSensor(dets, cfgs, plat);
end

end

function activeRadarData = convertToDataFormatOneSensor(detections, cfgs, plat)
% Reported config information
lookMountRot = cell(numel(cfgs),1);
for i = 1:numel(cfgs)
    if cfgs(i).MeasurementParameters(1).IsParentToChild
        lookMountRot{i} = cfgs(i).MeasurementParameters(1).Orientation;
    else
        lookMountRot{i} = cfgs(i).MeasurementParameters(1).Orientation';
    end
end
sensorRot = rotmat(quaternion(plat.Sensors{1}.MountingAngles,'eulerd','ZYX','frame'),'frame');
beamRot = cellfun(@(x)x*sensorRot',lookMountRot,UniformOutput=false);
ypr = cellfun(@(x)fusion.internal.frames.rotmat2ypr(x,"degrees"),beamRot,UniformOutput=false);
lookTime = arrayfun(@(x)x.Time,cfgs);
lookAzimuth = cellfun(@(x)x(1),ypr);
lookElevation = cellfun(@(x)-x(2),ypr);
isValid = arrayfun(@(x)x.IsValidTime, cfgs);
lookTime = lookTime(isValid);
lookAzimuth = lookAzimuth(isValid);
lookElevation = lookElevation(isValid);

% Reported measurement information
detectionTime = cellfun(@(x)x.Time,detections);
azimuth = cellfun(@(x)x.Measurement(1),detections);
elevation = cellfun(@(x)x.Measurement(2),detections);
range = cellfun(@(x)x.Measurement(3),detections);
rangeRate = cellfun(@(x)x.Measurement(4),detections);
azimuthAccuracy =  cellfun(@(x)x.MeasurementNoise(1,1),detections);
elevationAccuracy =  cellfun(@(x)x.MeasurementNoise(2,2),detections);
rangeAccuracy =  cellfun(@(x)x.MeasurementNoise(3,3),detections);
rangeRateAccuracy =  cellfun(@(x)x.MeasurementNoise(4,4),detections);

if size(plat.Trajectory.Waypoints,1) > 1
    [platformPos, platformOrient, platformVel, ~, platformAngVel] = lookupPose(plat.Trajectory, lookTime(:)');
    platformOrient = rotmat(platformOrient,'frame');
    for i = 1:size(platformAngVel,1)
        platformAngVel(i,:) = platformOrient(:,:,i)'*platformAngVel(i,:)';
    end
    activeRadarData = struct(LookTime=lookTime(:)',...
        PlatformPosition=platformPos',...
        PlatformOrientation = platformOrient,...
        PlatformVelocity=platformVel',...
        PlatformAngularVelocity = platformAngVel',...
        LookAzimuth=lookAzimuth(:)', ...
        LookElevation=lookElevation(:)', DetectionTime=detectionTime(:)', ...
        Azimuth=azimuth(:)',Elevation=elevation(:)', Range=range(:)', ...
        RangeRate=rangeRate(:)',AzimuthAccuracy=sqrt(azimuthAccuracy(:)'), ...
        ElevationAccuracy=sqrt(elevationAccuracy(:)'),RangeAccuracy=sqrt(rangeAccuracy(:)'), ...
        RangeRateAccuracy=sqrt(rangeRateAccuracy(:)'));
else
    activeRadarData = struct(LookTime=lookTime(:)',...
        LookAzimuth=lookAzimuth(:)', ...
        LookElevation=lookElevation(:)', DetectionTime=detectionTime(:)', ...
        Azimuth=azimuth(:)',Elevation=elevation(:)', Range=range(:)', ...
        RangeRate=rangeRate(:)',AzimuthAccuracy=sqrt(azimuthAccuracy(:)'), ...
        ElevationAccuracy=sqrt(elevationAccuracy(:)'),RangeAccuracy=sqrt(rangeAccuracy(:)'), ...
        RangeRateAccuracy=sqrt(rangeRateAccuracy(:)'));
end
end