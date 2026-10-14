# Exercise 3 — Wide-Area Surveillance

This folder is the customer starting point for an agentic MATLAB workshop. Your coding agent will inspect the supplied simulation, integrate the characterized radar from Exercise 2, run the changed code through MATLAB MCP, and compare tracking results. The baseline data is supplied. The characterized solution is the code-building task.

## Supplied starting materials

```text
Exercise3/
  README.md
  Exercise3Prompt.md
  agentChecks.md
  setupExercise3.m
  Exercise3_WideAreaSurveillance.m
  Exercise3_OriginalBaselineResults.mat
  helperFunctions/
    helperCreateWideAreaSurveillanceScenario.m
    helperRunWideAreaSurveillanceTracking.m
    helperRecordWideAreaSurveillanceData.m
    helperPlotSensorData.m
    helperLoadExercise3Baseline.m
    prepareExercise3Baseline.m
    dWideAreaSurveillanceTargetWaypoints.mat
```

The original Live Script is the simulation to inspect. `helperFunctions/` contains its supporting code, scenario data, baseline loader, and an author preparation utility. Keep the baseline MAT-file at the exercise root so it can be opened and inspected directly.

The characterized Live Script, additional comparison helpers, and comparison image are expected outputs from your agent session; they are not supplied prerequisites.

## Start the customer agent session

Use MATLAB R2026a with Radar Toolbox and Sensor Fusion and Tracking Toolbox. Configure the MATLAB MCP connection for the workshop before starting.

From the repository root:

```matlab
cd("Exercise3")
setupExercise3;
```

Keep this exercise folder as MATLAB's Current Folder when using Live Editor Run All. Open your coding agent in the same folder and ask it to read `agentChecks.md` and follow `Exercise3Prompt.md`.

Setup checks the original script, current prompt, agent instructions, supplied helper functions, and waypoint file. It adds this copy's `helperFunctions/` and the Exercise 2 output folder to the MATLAB path and verifies helper resolution. It reports whether the supplied baseline and Exercise 2 radar input are present. Loading and validating the baseline is the next agent step.

Setup does not run a simulation, generate files, launch an agent, or configure MCP. It also works before author baseline preparation: a missing baseline or Exercise 2 output is reported rather than generated automatically. Restore a missing baseline from the workshop files; complete Exercise 2 if its radar output is missing.

To inspect resolved paths:

```matlab
paths = setupExercise3();
paths.HelperFunctionsFolder
paths.RadarFile
paths.BaselineFile
```

Setup derives paths from its own function file. Keep the exercise folder beside `Exercise2`, whose input is `Exercise2/exercise2_output/dataGenerator.m`. Do not use recursive `addpath(genpath(...))`; that can mix helpers from different exercise copies.

## What the agent builds

The active prompt directs the agent to create:

- `Exercise3_CharacterizedWideAreaSurveillance.m` at the exercise root.
- Any new helper functions in `paths.HelperFunctionsFolder`, preserving supplied helpers.
- `exercise3_characterized_ospa_comparison.png` at `paths.ComparisonImageFile`.

The new script calls `setupExercise3`, loads the supplied baseline, and runs only the characterized configuration. It preserves the original scenario, airborne radars, tracker, and Exercise 2 files. The original Live Script also calls setup, so its optional exploratory run can find the relocated helpers.

After the agent has built the solution, run it from this exercise folder using Run All or:

```matlab
paths = setupExercise3();
run(fullfile(paths.Exercise3Folder, "Exercise3_CharacterizedWideAreaSurveillance.m"))
```

Opening a Live Script alone does not select its helper paths. When launching from a different folder, use the full script path with MATLAB's `run` or the MCP `run_matlab_file` tool.

## Inspect the supplied baseline

From the exercise folder, no simulation is needed:

```matlab
paths = setupExercise3();
[baselineResults, baselineMetadata] = helperLoadExercise3Baseline(paths.BaselineFile);
baselineResults.Time
baselineResults.OSPA
baselineResults.SensorDataLog{1}{1}
baselineResults.TruthDataLog{1}
baselineMetadata
```

The file covers 101 updates from 0 to 100 seconds. `SensorDataLog{updateIndex}{sensorIndex}` contains tracker-input detection structs; `TruthDataLog{updateIndex}` contains ECEF platform poses. It includes no graphics handles or running tracker objects.

Metadata records the generation environment, initial random stream, scenario/radar configuration, tracker/metric choices, waypoint data, and source snapshots. Those snapshots describe the code at generation time; reorganizing the folder does not rewrite the saved provenance or regenerate the baseline.

## Repository author preparation and rehearsal

The published `Exercise3` folder must contain only supplied starting materials. Repository authors use the Git-ignored `Exercise3_Test3` copy for local agent trials and completed-solution outputs. Its helper functions use the same subfolder layout; its README describes running the local solution. Customers build outputs in their own exercise copy and do not need that author rehearsal folder.

The baseline MAT-file is a distributed input and belongs in Git/package contents. Only an author preparing or deliberately updating that input should generate it. From the repository root:

```matlab
cd("Exercise3")
setupExercise3;
baselineFile = prepareExercise3Baseline();
```

Setup must run before calling the preparation utility in `helperFunctions/`. Preparation uses seed 2020/Twister, runs the original Live Script, saves logs and provenance at the exercise root, reloads them for verification, and restores the caller's path and random stream. Its staging file is beside the destination and is removed afterward.

An existing baseline is protected. Explicit regeneration uses `prepareExercise3Baseline(Overwrite=true)`. Review and distribute changed simulation code and baseline together; shortened diagnostic runs must never replace the supplied baseline.

## Author verification

From the repository root:

```matlab
results = runtests(fullfile("Exercise3_Test3", "tests", "exercise3BaselineTest.m"));
assertSuccess(results)
```

These author-only distribution checks live in the Git-ignored local rehearsal folder and target the sibling `Exercise3` starter. They verify startup without a solution, required-file diagnostics, helper resolution, baseline protection, preparation in a disposable short-scenario copy, and relocation. They intentionally require the published starter to remain free of generated solution files and a `tests` folder. Customers do not need these tests or the rehearsal folder to complete the exercise.

The same local `Exercise3_Test3/tests/` folder also holds the completed-solution tests, which target the local rehearsal copy. See its README for running both suites. MATLAB Online execution and browser-window layout still need verification in a signed-in session.
