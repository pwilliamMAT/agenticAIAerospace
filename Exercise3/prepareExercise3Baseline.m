function baselineFile = prepareExercise3Baseline(options)
%PREPAREEXERCISE3BASELINE Generate the workshop's original baseline once.
%   FILE = prepareExercise3Baseline() runs the original Live Script and saves
%   metrics, sensor/truth logs, and provenance beside it. Existing baselines
%   are protected. Use prepareExercise3Baseline(Overwrite=true) to regenerate.
%   The original viewer is displayed during preparation. Saved data contains
%   no graphics handles. The caller's path and random stream are restored.
arguments
    options.Overwrite (1, 1) logical = false
end

previousPath = path;
pathCleanup = onCleanup(@() path(previousPath));
paths = setupExercise3();
baselineFile = paths.BaselineFile;
if isfile(baselineFile) && ~options.Overwrite
    error("Exercise3:BaselineExists", ...
        "Baseline already exists: %s. To regenerate it, use prepareExercise3Baseline(Overwrite=true).", ...
        baselineFile);
end

previousRandomStream = rng;
randomCleanup = onCleanup(@() rng(previousRandomStream));
rng(2020, "twister");
initialRandomStream = rng;

% Run the original source, so radar and tracker definitions are not duplicated.
run(fullfile(paths.Exercise3Folder, "Exercise3_WideAreaSurveillance.m"));
originalResults = baselineResults; %#ok<NODEF> Populated by the original script above.
baselineResults = struct( ...
    Time=originalResults.Time, ...
    OSPA=originalResults.OSPA, ...
    SensorDataLog={originalResults.SensorDataLog(:)}, ...
    TruthDataLog={originalResults.TruthDataLog(:)});

% Keep inspectable source snapshots, omitting Live Editor's embedded outputs.
sourceNames = ["Exercise3_WideAreaSurveillance.m", ...
    "helperCreateWideAreaSurveillanceScenario.m", ...
    "helperRunWideAreaSurveillanceTracking.m", ...
    "helperRecordWideAreaSurveillanceData.m", "helperPlotSensorData.m", ...
    "prepareExercise3Baseline.m"];
sources = repmat(struct(File="", Text=""), numel(sourceNames), 1);
for sourceIndex = 1:numel(sourceNames)
    sourceText = string(fileread(fullfile(paths.Exercise3Folder, sourceNames(sourceIndex))));
    sourceLines = splitlines(sourceText);
    appendixStart = find(startsWith(sourceLines, "%[appendix]"), 1);
    if ~isempty(appendixStart)
        sourceText = join(sourceLines(1:appendixStart-1), newline);
    end
    sources(sourceIndex) = struct(File=sourceNames(sourceIndex), Text=sourceText);
end
waypointData = load(paths.WaypointFile, "tgts");
baselineMetadata = struct( ...
    SchemaVersion=1, ...
    GeneratedAt=datetime("now", TimeZone="UTC"), ...
    MATLABVersion=string(version), ...
    MATLABRelease=string(version("-release")), ...
    Products=ver, ...
    RandomStream=initialRandomStream, ...
    Scenario=struct(StopTime=scenario.StopTime, UpdateRate=scenario.UpdateRate, ...
        IsEarthCentered=scenario.IsEarthCentered, NumSensors=5), ...
    GroundRadar=get(groundRadar), ...
    Tracker=struct(Algorithm="jipda", Target=["aerospace", "aircraft", "passenger"], ...
        Metric="OSPA", Distance="posnees"), ...
    Sources=sources, ...
    WaypointData=waypointData.tgts);

% Stage beside the final file. Publish only after a successful save/load check.
stagedFile = string(tempname(paths.Exercise3Folder)) + ".mat";
stagingCleanup = onCleanup(@() deleteStagedFile(stagedFile));
save(stagedFile, "baselineResults", "baselineMetadata", "-v7");
[reloadedResults, reloadedMetadata] = helperLoadExercise3Baseline(stagedFile);
assert(isequaln(reloadedResults, baselineResults), ...
    "Exercise3:SaveVerification", "Reloaded baseline results differ from the generated data.");
assert(isequaln(reloadedMetadata, baselineMetadata), ...
    "Exercise3:SaveVerification", "Reloaded baseline provenance differs from the generated metadata.");
if isfile(baselineFile) && ~options.Overwrite
    error("Exercise3:BaselineExists", "A baseline appeared during preparation: %s. It was not replaced.", baselineFile);
end
[saved, message] = movefile(stagedFile, baselineFile, "f");
if ~saved
    error("Exercise3:SaveFailed", "Could not publish baseline %s: %s", baselineFile, message);
end
fprintf("Saved baseline: %s\n%d updates, %.0f-%.0f s, with detection and truth logs.\n", ...
    baselineFile, numel(baselineResults.Time), baselineResults.Time(1), baselineResults.Time(end));
end

function deleteStagedFile(stagedFile)
% Delete only this invocation's unpublished staging file, including on error.
if isfile(stagedFile)
    delete(stagedFile);
end
end
