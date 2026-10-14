function helperPlotSensorData(mapViewer, radarSpec, radarData, args)
% This is a helper function and may be removed or modified in a future
% release.
%
% This function is used to plot sensor data from a monostatic radar
% specification on a trackingGlobeViewer

% Copyright 2025 The MathWorks, Inc.

arguments
    mapViewer
    radarSpec
    radarData
    args.PlotCoverage = true;
    args.PersistentDetections = true;
    args.DetectionHistoryTime = 50;
end

persistent detBuffer

if isempty(detBuffer)
    detBuffer = {};
end

if args.PlotCoverage
    coverages = [];
    for i = 1:numel(radarSpec)
        covActive = coverageConfig(radarSpec{i}, radarData{i});
        covActive.Index = i;
        coverages = [coverages;covActive]; %#ok<AGROW>
    end
    plotCoverage(mapViewer, coverages, 'ECEF', 'Alpha', 0.25);
end

radarDets = {};
for i = 1:numel(radarSpec)
    radarDetsI = radarDataToObjectDetection(radarSpec{i}, radarData{i});
    for k = 1:numel(radarDetsI)
        radarDetsI{k}.SensorIndex = i;
    end
    radarDets = [radarDets;radarDetsI]; %#ok<AGROW>
end

if args.PersistentDetections
    detBuffer = [detBuffer;radarDets];
else
    detBuffer = radarDets;
end
if ~isempty(detBuffer)
    timestamps = cellfun(@(x)x.Time,detBuffer);
    maxTime = max(timestamps);
    toKeep = timestamps > maxTime - args.DetectionHistoryTime;
    detBuffer = detBuffer(toKeep);
end

plotDetection(mapViewer, detBuffer, 'ECEF','MarkerSize',6);

end


function detections = radarDataToObjectDetection(radarSpec, radarData)
n = size(radarData.Azimuth,2);
mp = struct('Frame','spherical',...
    'OriginPosition',zeros(3,1),...
    'OriginVelocity',zeros(3,1),...
    'Orientation',eye(3),...
    'HasAzimuth',true,...
    'HasElevation',true,...
    'HasRange',true,...
    'HasVelocity',true,...
    'IsParentToChild',true);
mp = repmat(mp,2,1);

sampleDet = objectDetection(0,zeros(4,1),'MeasurementParameters',mp,'SensorIndex',1);
detections = repmat({sampleDet},n,1);
for i = 1:n
    detections{i}.Time = radarData.DetectionTime(i);
    detections{i}.Measurement = [radarData.Azimuth(i);radarData.Elevation(i);radarData.Range(i);radarData.RangeRate(i)];
    detections{i}.MeasurementNoise = blkdiag(radarData.AzimuthAccuracy(i)^2,radarData.ElevationAccuracy(i)^2,radarData.RangeAccuracy(i)^2,radarData.RangeRateAccuracy(i)^2);
    detections{i}.MeasurementParameters(1).OriginPosition = radarSpec.MountingLocation(:);
    
    [~,scanIdx] = min(abs(radarData.LookTime - radarData.DetectionTime(i)));
    lookAng = [radarData.LookAzimuth(scanIdx);radarData.LookElevation(scanIdx)];
    ypr = zeros(1,3,'like',lookAng);
    ypr(1:2) = lookAng;
    ypr(2) = -ypr(2); % Elevation is opposite the sign of pitch
    lookRot = fusion.internal.frames.ypr2rotmat(ypr,'degrees');

    detections{i}.MeasurementParameters(1).OriginVelocity = zeros(3,1);
    detections{i}.MeasurementParameters(1).Orientation = lookRot*fusion.internal.frames.ypr2rotmat(radarSpec.MountingAngles,'degrees');
    
    if radarSpec.IsPlatformStationary
        platVel = zeros(3,1);
        platLLA = radarSpec.PlatformPosition(:);
        platOrient = radarSpec.PlatformOrientation;
    else
        platVel = radarData.PlatformVelocity(:,1);
        platLLA = radarData.PlatformPosition(:,1);
        platOrient = radarData.PlatformOrientation(:,:,1);
    end
    if strcmpi(radarSpec.GeographicReferenceFrame,'NED')
        Rref2ecef = fusion.internal.frames.ned2ecefrotmat(platLLA(1),platLLA(2));
    elseif strcmpi(radarSpec.GeographicReferenceFrame,'ENU')
        Rref2ecef = fusion.internal.frames.enu2ecefrotmat(platLLA(1),platLLA(2));
    else
        Rref2ecef = eye(3);
    end

    platformRot = platOrient*Rref2ecef';
    platformPos = fusion.internal.frames.lla2ecef(platLLA');
    platVel = Rref2ecef*platVel;
    detections{i}.MeasurementParameters(2).OriginVelocity = platVel;
    detections{i}.MeasurementParameters(2).OriginPosition = platformPos(:);
    detections{i}.MeasurementParameters(2).Orientation = platformRot;
    detections{i}.MeasurementParameters(2).Frame = 'rectangular';
end

end


function cvg = coverageConfig(spec, data)
cvg = struct('Index',1,...
    'LookAngle',zeros(2,1),...
    'FieldOfView',zeros(2,1),...
    'ScanLimits',[360 30],...
    'Range',5e4,...
    'Position',[0 0 0],...
    'Orientation',quaternion.ones(1,1));
pos = zeros(3,1);
sensorRot = rotmat(quaternion(spec.MountingAngles,'eulerd','ZYX','frame'),'frame');
sensorPos = spec.MountingLocation;

if spec.IsPlatformStationary
    platLLA = spec.PlatformPosition(:);
    platOrient = spec.PlatformOrientation;
else
    platLLA = data.PlatformPosition(:,1);
    platOrient = data.PlatformOrientation(:,:,1);
end
if strcmpi(spec.GeographicReferenceFrame,'NED')
    Rref2ecef = fusion.internal.frames.ned2ecefrotmat(platLLA(1),platLLA(2));
elseif strcmpi(spec.GeographicReferenceFrame,'ENU')
    Rref2ecef = fusion.internal.frames.enu2ecefrotmat(platLLA(1),platLLA(2));
else
    Rref2ecef = eye(3);
end

platformRot = platOrient*Rref2ecef';
platformPos = fusion.internal.frames.lla2ecef(platLLA');

pos = fusion.tracker.internal.utils.transformToParent(pos, sensorPos(:), sensorRot);
pos = fusion.tracker.internal.utils.transformToParent(pos, platformPos(:), platformRot);
rot = quaternion(sensorRot*platformRot,'rotmat','frame');
cvg.Position = pos';
cvg.Orientation = rot;
az = data.LookAzimuth;
fovAz = abs(wrapTo360(az(end) - az(1)));
el = data.LookElevation;
fovEl = abs(wrapTo180(el(end) - el(1)));
fov = [fovAz;fovEl] + spec.FieldOfView(:);
idx = max(1,floor(numel(az)/2));
cvg.LookAngle = [data.LookAzimuth;data.LookElevation];
cvg.LookAngle = [wrapTo180(az(idx));wrapTo180(el(idx))];
cvg.FieldOfView = fov;
cvg.Range = spec.RangeLimits(2);
cvg.Range = 100e3;
end
