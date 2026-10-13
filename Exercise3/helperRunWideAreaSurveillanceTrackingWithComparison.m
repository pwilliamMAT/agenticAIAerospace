function results = helperRunWideAreaSurveillanceTrackingWithComparison(scene, groundRadar, viewerFigure, metricAxes, characterizedLine, baselineResults)
%HELPERRUNWIDEAREASURVEILLANCETRACKINGWITHCOMPARISON Run the updated scenario with live metric comparison.
[targetSpec, sensorSpecs] = localCreateTrackerSpecifications(groundRadar);
tracker = multiSensorTargetTracker(targetSpec, sensorSpecs, "jipda");
[sensorDataLog, truthDataLog] = helperRecordWideAreaSurveillanceData(scene);
viewer = localCreateTrackingGlobeViewer(sensorSpecs, sensorDataLog, truthDataLog, viewerFigure);
numUpdates = numel(sensorDataLog);
simulationTime = zeros(numUpdates,1);
ospa = zeros(numUpdates,1);
ospaMetric = trackOSPAMetric(Metric="OSPA", Distance="posnees");
yMax = max(baselineResults.OSPA,[],'omitnan');
if isempty(yMax) || ~isfinite(yMax) || yMax <= 0
    yMax = 1;
end
for updateIndex = 1:numUpdates
    sensorData = sensorDataLog{updateIndex};
    truthData = truthDataLog{updateIndex};
    tracks = tracker(sensorData{:});
    simulationTime(updateIndex) = sensorData{1}.LookTime(end);
    ospa(updateIndex) = ospaMetric(tracks, truthData(4:end));
    addpoints(characterizedLine, simulationTime(updateIndex), ospa(updateIndex));
    yMax = max([yMax; ospa(updateIndex)]);
    xlim(metricAxes,[min(baselineResults.Time) max(baselineResults.Time)])
    ylim(metricAxes,[0 1.2*yMax])
    drawnow limitrate
    localUpdateTrackingGlobe(viewer, sensorSpecs, sensorData, tracks, truthData);
    drawnow limitrate
end
results = struct( ...
    Time=simulationTime, ...
    OSPA=ospa, ...
    SensorDataLog={sensorDataLog}, ...
    TruthDataLog={truthDataLog}, ...
    ViewerFigure=viewerFigure);
end

function [targetSpec, sensorSpecs] = localCreateTrackerSpecifications(groundRadar)
targetSpec = trackerTargetSpec("aerospace", "aircraft", "passenger");
targetSpec.IsGeographic = true;
targetSpec.GeographicReferenceFrame = "NED";
groundRadarSites = [41.4228 -88.0583 100; 40.6989 -89.8258 100; 39.2219 -95.2461 100];
referenceFrames = ["NED", "ENU", "NED"];
yaw = [30; -15; 10];
platformOrientation = rotmat(quaternion([yaw zeros(3,2)],"eulerd","ZYX","frame"),"frame");
groundSensorSpecs = cell(1,3);
for radarIndex = 1:3
    sensorSpec = trackerSensorSpec("aerospace", "radar", "monostatic");
    sensorSpec.IsGeographic = true;
    sensorSpec.IsPlatformStationary = true;
    sensorSpec.GeographicReferenceFrame = referenceFrames(radarIndex);
    sensorSpec.PlatformPosition = groundRadarSites(radarIndex,:);
    sensorSpec.PlatformOrientation = platformOrientation(:,:,radarIndex);
    sensorSpec.MountingLocation = [0 0 0];
    sensorSpec.MountingAngles = [0 0 0];
    sensorSpec.MaxNumLooksPerUpdate = 1;
    sensorSpec.MaxNumMeasurementsPerUpdate = 10;
    sensorSpec.FieldOfView = groundRadar.FieldOfView(:)';
    sensorSpec.RangeLimits = groundRadar.RangeLimits;
    sensorSpec.RangeRateLimits = groundRadar.RangeRateLimits;
    sensorSpec.ElevationResolution = groundRadar.ElevationResolution;
    sensorSpec.AzimuthResolution = groundRadar.AzimuthResolution;
    sensorSpec.RangeResolution = groundRadar.RangeResolution;
    sensorSpec.RangeRateResolution = groundRadar.RangeRateResolution;
    sensorSpec.DetectionProbability = groundRadar.DetectionProbability;
    sensorSpec.FalseAlarmRate = groundRadar.FalseAlarmRate;
    groundSensorSpecs{radarIndex} = sensorSpec;
end
airborneSensorSpecs = cell(1,2);
for radarIndex = 1:2
    sensorSpec = trackerSensorSpec("aerospace", "radar", "monostatic");
    sensorSpec.IsGeographic = true;
    sensorSpec.GeographicReferenceFrame = "ENU";
    sensorSpec.IsPlatformStationary = false;
    sensorSpec.MaxNumLooksPerUpdate = 1;
    sensorSpec.MaxNumMeasurementsPerUpdate = 10;
    sensorSpec.MountingLocation = [0 0 0];
    sensorSpec.MountingAngles = [0 0 0];
    sensorSpec.FieldOfView = [30 20];
    sensorSpec.RangeLimits = [0 463e3];
    sensorSpec.RangeRateLimits = [-5000 5000];
    sensorSpec.ElevationResolution = 2.2275;
    sensorSpec.AzimuthResolution = 1.4;
    sensorSpec.RangeResolution = 323;
    sensorSpec.RangeRateResolution = 10;
    sensorSpec.DetectionProbability = 0.95;
    airborneSensorSpecs{radarIndex} = sensorSpec;
end
sensorSpecs = [groundSensorSpecs airborneSensorSpecs];
end

function viewer = localCreateTrackingGlobeViewer(sensorSpecs, sensorDataLog, truthDataLog, viewerFigure)
clear("helperPlotSensorData")
viewer = trackingGlobeViewer(viewerFigure, NumCovarianceSigma=0);
campos(viewer, [40.9254 -90.2835 1e6]);
for updateIndex = 1:numel(truthDataLog)
    plotPlatform(viewer, truthDataLog{updateIndex}, "ECEF", Color=[1 1 1], LineWidth=2, TrajectoryMode="History");
end
helperPlotSensorData(viewer, sensorSpecs, sensorDataLog{1}, PersistentDetections=true, PlotCoverage=true, DetectionHistoryTime=inf);
end

function localUpdateTrackingGlobe(viewer, sensorSpecs, sensorData, tracks, truthData)
plotTrack(viewer, tracks, "ECEF", Color=[0 1 0], LineWidth=2, MarkerSize=2);
plotPlatform(viewer, truthData, "ECEF", Color=[1 1 1], LineWidth=2, TrajectoryMode="None", LabelStyle="None");
helperPlotSensorData(viewer, sensorSpecs, sensorData, PersistentDetections=true, PlotCoverage=true, DetectionHistoryTime=inf);
end
