function [baselineResults, baselineMetadata] = helperLoadExercise3Baseline(baselineFile)
%HELPERLOADEXERCISE3BASELINE Load and validate the supplied full baseline.
%   The MAT-file contains metrics, tracker-input detection logs, truth logs,
%   and provenance. Loading never runs the scenario or creates figures.
arguments
    baselineFile {mustBeTextScalar}
end

if ~isfile(baselineFile)
    error("Exercise3:MissingBaseline", ...
        "Baseline not found: %s. Restore the supplied file, or run prepareExercise3Baseline from Exercise3.", ...
        baselineFile);
end

try
    variables = whos("-file", baselineFile);
    assert(all(ismember(["baselineResults", "baselineMetadata"], string({variables.name}))), ...
        "The MAT-file must contain baselineResults and baselineMetadata.");
    saved = load(baselineFile, "baselineResults", "baselineMetadata");
    assert(isfield(saved, "baselineResults"), "Missing baselineResults.");
    assert(isfield(saved, "baselineMetadata"), "Missing baselineMetadata.");
    baselineResults = saved.baselineResults;
    baselineMetadata = saved.baselineMetadata;
    validateattributes(baselineResults, {'struct'}, {'scalar'});
    fields = ["Time"; "OSPA"; "SensorDataLog"; "TruthDataLog"];
    assert(isequal(sort(string(fieldnames(baselineResults))), sort(fields)), ...
        "Expected only Time, OSPA, SensorDataLog, and TruthDataLog; do not save graphics handles.");
    validateattributes(baselineResults.Time, {'double'}, ...
        {'column', 'nonempty', 'real', 'finite', 'nonnegative', 'increasing'});
    numUpdates = numel(baselineResults.Time);
    validateattributes(baselineResults.OSPA, {'double'}, ...
        {'size', [numUpdates 1], 'real', 'finite', 'nonnegative'});
    validateattributes(baselineResults.SensorDataLog, {'cell'}, {'size', [numUpdates 1]});
    validateattributes(baselineResults.TruthDataLog, {'cell'}, {'size', [numUpdates 1]});

    validateattributes(baselineMetadata, {'struct'}, {'scalar'});
    metadataFields = ["SchemaVersion", "GeneratedAt", "MATLABVersion", "MATLABRelease", ...
        "Products", "RandomStream", "Scenario", "GroundRadar", "Tracker", "Sources", "WaypointData"];
    assert(all(isfield(baselineMetadata, metadataFields)), "Missing baseline provenance fields.");
    assert(isequal(baselineMetadata.SchemaVersion, 1), "Unsupported baseline schema version.");
    expectedTime = (0:1/baselineMetadata.Scenario.UpdateRate:baselineMetadata.Scenario.StopTime)';
    assert(isequal(baselineResults.Time, expectedTime), ...
        "Baseline does not cover the complete scenario time grid recorded in its metadata.");
    for updateIndex = 1:numUpdates
        sensorFrame = baselineResults.SensorDataLog{updateIndex};
        truthFrame = baselineResults.TruthDataLog{updateIndex};
        assert(iscell(sensorFrame), "Each detection frame must be a cell array of sensor structs.");
        assert(numel(sensorFrame) == baselineMetadata.Scenario.NumSensors, ...
            "Detection frame has an unexpected sensor count.");
        assert(isstruct(truthFrame), "Each truth frame must contain platform-pose structs.");
        assert(~isempty(truthFrame), "Truth frames must not be empty.");
        for sensorIndex = 1:numel(sensorFrame)
            sensorData = sensorFrame{sensorIndex};
            assert(isstruct(sensorData), "Each sensor input must be a struct.");
            assert(isfield(sensorData, "LookTime"), "Sensor input is missing LookTime.");
            assert(~isempty(sensorData.LookTime), "Sensor look times must not be empty.");
            assert(sensorData.LookTime(end) == baselineResults.Time(updateIndex), ...
                "Sensor look time does not match its metric timestamp.");
        end
    end
catch exception
    error("Exercise3:InvalidBaseline", ...
        "Invalid baseline %s: %s Restore the supplied file, or run prepareExercise3Baseline(Overwrite=true).", ...
        baselineFile, exception.message);
end
end
