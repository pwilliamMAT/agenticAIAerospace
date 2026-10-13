# Exercise 3 — Wide-Area Surveillance

This folder is the participant starting point for an agentic MATLAB workshop. The agent inspects the supplied simulation, integrates the characterized radar from Exercise 2, runs the changed code through MATLAB MCP, and compares tracking results. The original baseline data is supplied; the characterized solution and its outputs are what the agent will build.

## Contents

| File | Purpose |
| --- | --- |
| `Exercise3_WideAreaSurveillance.m` | Participant-facing baseline Live Script |
| `Exercise3_OriginalBaselineResults.mat` | Supplied baseline metrics, detection/truth logs, and provenance |
| `setupExercise3.m` | Session startup: supplied-helper checks, portable paths, and prompt location |
| `Exercise3Prompt_v7.md` | Participant task and presentation requirements |
| `agentChecks.md` | Defaults and boundaries for the agent session |
| `helperLoadExercise3Baseline.m` | Load and validate the full baseline without simulation |
| `prepareExercise3Baseline.m` | Explicit author preparation/regeneration command |
| `helperCreateWideAreaSurveillanceScenario.m` | Wide-area radar and aircraft scenario |
| `helperRunWideAreaSurveillanceTracking.m` | Tracker setup, live data generation, and OSPA calculation |
| `helperRecordWideAreaSurveillanceData.m` | Conversion of scenario detections to tracker data |
| `helperPlotSensorData.m` | Tracking globe sensor coverage and detection display |
| `../Exercise2/exercise2_output/dataGenerator.m` | Exercise 2 producer; creates the variable `radar` |
| `tests/exercise3BaselineTest.m` | Starter checks that run before a solution exists |

## Start the agent session

Use MATLAB R2026a with Radar Toolbox and Sensor Fusion and Tracking Toolbox. The exercise uses the Live Editor and `trackingGlobeViewer`.

From the repository root, run:

```matlab
addpath("Exercise3")
setupExercise3;
```

Alternatively, make `Exercise3` the MATLAB Current Folder and call `setupExercise3;` directly. Setup selects the supplied helpers, resolves file locations, and prints the active exercise folder and prompt to use. It does not run a simulation, create outputs, or require the characterized solution. It also works before author baseline preparation; missing baseline or Exercise 2 data is reported in the startup guidance.

Open your coding agent in that exercise folder. Ask it to read `agentChecks.md` and follow `Exercise3Prompt_v7.md`. This begins the agent task; setup itself does not launch an agent or configure the MCP connection. The MATLAB MCP connection should already be configured for the workshop.

The agent should create `Exercise3_CharacterizedWideAreaSurveillance.m`, any additional comparison helpers it needs, and the requested image. These are expected outputs, not supplied prerequisites. Its generated script calls `paths = setupExercise3()`, loads `paths.BaselineFile`, and saves the image to `paths.ComparisonImageFile` in the active exercise copy. A missing/invalid baseline produces an actionable error from `helperLoadExercise3Baseline`.

`setupExercise3` derives locations from its own regular function file. Keep the exercise copy beside `Exercise2` when relocating the workshop. It selects helpers from that copy and reports conflicts with another copy. No hard-coded MATLAB Drive mount or recursive `addpath(genpath(...))` is needed.

## Repository starter and local rehearsal

Keep the published `Exercise3` folder free of the generated solution, generated comparison helpers, and run outputs. The baseline MAT-file and original helpers are supplied inputs and remain here.

Use `Exercise3_Test3` as the local rehearsal copy and agent workspace. It contains its own supplied inputs plus the completed solution and outputs, and is ignored by Git. From the repository root:

```matlab
cd("Exercise3_Test3")
setupExercise3;
```

Work in that copy during local agent trials. Its setup resolves its own baseline and output locations. See its README for running the completed solution and solution tests. Participant-owned copies can likewise receive generated files during the exercise; keep those results out of the published starter.

## Inspect the supplied baseline

From the repository root:

```matlab
saved = load(fullfile("Exercise3", "Exercise3_OriginalBaselineResults.mat"));
saved.baselineResults.Time
saved.baselineResults.OSPA
saved.baselineResults.SensorDataLog{1}{1}
saved.baselineResults.TruthDataLog{1}
saved.baselineMetadata
```

`SensorDataLog{updateIndex}{sensorIndex}` contains the existing helper's tracker-input detection structs, including sensor look times, measurements, and accuracies. `TruthDataLog{updateIndex}` contains the corresponding ECEF platform poses. The baseline covers 101 updates from 0 to 100 seconds. It includes no graphics handles or running tracker objects, so loading it creates no windows. Track histories are not part of the existing helper's output.

Metadata records the MATLAB/toolbox versions, initial random stream, scenario and radar configuration, tracker/metric choices, waypoint data, and source-text snapshots without embedded Live Editor outputs. The data can be inspected without regenerating it; reproducibility is assessed in the recorded MATLAB/toolbox environment.

## Author preparation

The baseline MAT-file is a distributed workshop input and should be included in Git/package contents. Generate it from the original scenario before distributing the workshop:

```matlab
addpath("Exercise3") % From the repository root.
baselineFile = prepareExercise3Baseline();
```

Preparation uses seed 2020 and the Twister generator, runs the original Live Script, saves the logs and provenance, reloads them for verification, and prints the final file location. It restores the caller's random stream and search path. Its temporary staging file lives beside the destination and is removed after publication or failure; no rerun depends on it.

An existing baseline is protected. After deliberately changing the original scenario or tracking configuration, regenerate explicitly:

```matlab
baselineFile = prepareExercise3Baseline(Overwrite=true);
```

Review and distribute the updated code and baseline together. Shortened diagnostic runs must never replace the supplied baseline.

Run the focused persistence/path checks from the repository root:

```matlab
results = runtests(fullfile("Exercise3", "tests", "exercise3BaselineTest.m"));
assertSuccess(results)
```

These checks require only the starter files and the Exercise 2 radar input. They verify startup without generated files, saved data, baseline protection, and relocation. One test prepares a short baseline in a disposable copy; the distributed baseline remains unchanged. Completed-solution tests are maintained separately in `Exercise3_Test3/tests/exercise3SolutionTest.m`.

MATLAB Online execution and browser-window layout still need verification in a signed-in session.

## Part A — Explore

Inspect the original Live Script, supplied baseline, and Exercise 2 deliverable as the starting point for your conversation with a coding agent. Running the original simulation is optional exploration, not a prerequisite for the comparison.

## Part B — Streamlined Prompt

If useful after Part A, use `Exercise3Prompt_v7.md` for a directed attempt with Live Editor and MATLAB Online layout requirements. It follows the supplied-baseline contract in `agentChecks.md`.
