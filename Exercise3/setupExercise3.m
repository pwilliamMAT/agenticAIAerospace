function paths = setupExercise3()
%SETUPEXERCISE3 Prepare the supplied files for an Exercise 3 agent session.
%   PATHS = setupExercise3() selects this copy's supplied helpers and resolves
%   its input and future output paths. Generated solution files are optional.
%   It does not change the current folder, run a simulation, or write files.
%   Call setupExercise3 without an output to display agent-session guidance.

exercise3Folder = string(fileparts(mfilename("fullpath")));
helperFunctionsFolder = fullfile(exercise3Folder, "helperFunctions");
exercise2Folder = fullfile(fileparts(exercise3Folder), "Exercise2", "exercise2_output");
paths = struct( ...
    Exercise3Folder=exercise3Folder, ...
    HelperFunctionsFolder=helperFunctionsFolder, ...
    Exercise2Folder=exercise2Folder, ...
    BaselineScript=fullfile(exercise3Folder, "Exercise3_WideAreaSurveillance.m"), ...
    PromptFile=fullfile(exercise3Folder, "Exercise3Prompt_v7.md"), ...
    AgentChecksFile=fullfile(exercise3Folder, "agentChecks.md"), ...
    RadarFile=fullfile(exercise2Folder, "dataGenerator.m"), ...
    BaselineFile=fullfile(exercise3Folder, "Exercise3_OriginalBaselineResults.mat"), ...
    WaypointFile=fullfile(helperFunctionsFolder, "dWideAreaSurveillanceTargetWaypoints.mat"), ...
    ComparisonImageFile=fullfile(exercise3Folder, "exercise3_characterized_ospa_comparison.png"));

previousPath = path;
try
    if ~isfolder(helperFunctionsFolder)
        error("Exercise3:MissingInput", ...
            "Support folder not found: %s. Restore helperFunctions from the workshop starter files.", ...
            helperFunctionsFolder);
    end
    helperNames = ["helperCreateWideAreaSurveillanceScenario", ...
        "helperRecordWideAreaSurveillanceData", "helperPlotSensorData", ...
        "helperRunWideAreaSurveillanceTracking", ...
        "helperLoadExercise3Baseline", "prepareExercise3Baseline"];
    suppliedFiles = [paths.BaselineScript, paths.PromptFile, paths.AgentChecksFile, ...
        paths.WaypointFile, fullfile(helperFunctionsFolder, helperNames + ".m")];
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
    addpath(helperFunctionsFolder);
    for helperName = helperNames
        expectedFile = fullfile(helperFunctionsFolder, helperName + ".m");
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
    fprintf("Supplied files checked; support functions selected from: %s\n", paths.HelperFunctionsFolder);
    fprintf("Start your coding agent in this folder and use the prompt in:\n%s\n", paths.PromptFile);
    fprintf("Ask the agent to read %s before building the comparison.\n", paths.AgentChecksFile);
    fprintf("Create the new Live Script and image here; put new helper functions in helperFunctions.\n");
    if ~isfile(paths.BaselineFile)
        fprintf("Baseline is missing. Restore the supplied MAT-file or run prepareExercise3Baseline.\n");
    else
        fprintf("Supplied baseline found: %s\n", paths.BaselineFile);
    end
    if ~isfile(paths.RadarFile)
        fprintf("Exercise 2 radar output is missing. Complete Exercise 2 before building the comparison.\n");
    else
        fprintf("Exercise 2 radar input found: %s\n", paths.RadarFile);
    end
end
end
