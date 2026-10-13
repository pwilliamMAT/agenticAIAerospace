function paths = setupExercise3()
%SETUPEXERCISE3 Prepare the supplied files for an Exercise 3 agent session.
%   PATHS = setupExercise3() selects this copy's supplied helpers and resolves
%   its input and future output paths. Generated solution files are optional.
%   It does not change the current folder, run a simulation, or write files.
%   Call setupExercise3 without an output to display agent-session guidance.

exercise3Folder = string(fileparts(mfilename("fullpath")));
exercise2Folder = fullfile(fileparts(exercise3Folder), "Exercise2", "exercise2_output");
paths = struct( ...
    Exercise3Folder=exercise3Folder, ...
    Exercise2Folder=exercise2Folder, ...
    BaselineScript=fullfile(exercise3Folder, "Exercise3_WideAreaSurveillance.m"), ...
    PromptFile=fullfile(exercise3Folder, "Exercise3Prompt_v7.md"), ...
    RadarFile=fullfile(exercise2Folder, "dataGenerator.m"), ...
    BaselineFile=fullfile(exercise3Folder, "Exercise3_OriginalBaselineResults.mat"), ...
    WaypointFile=fullfile(exercise3Folder, "dWideAreaSurveillanceTargetWaypoints.mat"), ...
    ComparisonImageFile=fullfile(exercise3Folder, "exercise3_characterized_ospa_comparison.png"));

previousPath = path;
try
    suppliedFiles = [paths.BaselineScript, paths.PromptFile, paths.WaypointFile];
    for suppliedFile = suppliedFiles
        if ~isfile(suppliedFile)
            error("Exercise3:MissingInput", ...
                "Supplied exercise file not found: %s. Restore it from the workshop starter files.", suppliedFile);
        end
    end
    if isfolder(exercise2Folder)
        addpath(exercise2Folder);
    end
    addpath(exercise3Folder);
    helperNames = ["helperCreateWideAreaSurveillanceScenario", ...
        "helperRecordWideAreaSurveillanceData", "helperPlotSensorData", ...
        "helperRunWideAreaSurveillanceTracking", ...
        "helperLoadExercise3Baseline", "prepareExercise3Baseline"];
    for helperName = helperNames
        expectedFile = fullfile(exercise3Folder, helperName + ".m");
        resolvedFile = string(which(helperName));
        if ~strcmpi(resolvedFile, expectedFile)
            error("Exercise3:HelperConflict", ...
                "Expected %s, but MATLAB resolves %s. Change the Current Folder to %s and rerun.", ...
                expectedFile, resolvedFile, exercise3Folder);
        end
    end
catch exception
    path(previousPath);
    rethrow(exception);
end

if nargout == 0
    fprintf("Exercise 3 session folder: %s\n", paths.Exercise3Folder);
    fprintf("Start your coding agent in this folder and use the prompt in:\n%s\n", paths.PromptFile);
    fprintf("Ask the agent to read agentChecks.md before building the comparison.\n");
    if ~isfile(paths.BaselineFile)
        fprintf("Baseline is missing. Restore the supplied MAT-file or run prepareExercise3Baseline.\n");
    end
    if ~isfile(paths.RadarFile)
        fprintf("Exercise 2 radar output is missing. Complete Exercise 2 before building the comparison.\n");
    end
end
end
