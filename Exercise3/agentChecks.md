# Agent Checks for Exercise 3

Use these defaults for this Exercise 3 workshop session unless the user explicitly overrides them. The goal is to reduce agent wall-clock time by avoiding repeated clarification and permission-style questions during the characterized radar workflow.

## Default Answers

| Agent question | Default answer |
| --- | --- |
| May I read the Exercise 2 output folder? | Yes. Call `paths = setupExercise3()` and use `paths.RadarFile`. |
| Which Exercise 2 file contains the characterized radar? | Use `dataGenerator.m` in `../Exercise2/exercise2_output/`. It creates `radar`. |
| Should Exercise 2 output files be edited? | No. Read them only. Do not overwrite Exercise 2 output. |
| Should original Exercise 3 files be overwritten? | No. Create the new Live Script and image in `paths.Exercise3Folder`; put new helper functions in `paths.HelperFunctionsFolder`. Preserve all supplied files. |
| Where is the supporting code? | In `helperFunctions/`, selected by `setupExercise3`. It also contains the scenario waypoint data and the author-only baseline preparation utility. |
| Does setup require a characterized solution or comparison helper? | No. Setup checks only supplied files and helpers. The agent creates any additional solution helpers needed by its implementation. |
| Should the agent read embedded Live Script outputs/images? | No. When inspecting plain-text live scripts, stop at the line beginning `%[appendix]`. |
| Should the original baseline simulation be rerun in the final script? | No. The final script should load original baseline data. |
| How should the baseline be loaded? | Use `[baselineResults, baselineMetadata] = helperLoadExercise3Baseline(paths.BaselineFile)`. It validates the supplied metrics and detection/truth logs. |
| What if the baseline MAT file is missing or invalid? | Report that author preparation is required: `prepareExercise3Baseline`, or `prepareExercise3Baseline(Overwrite=true)` for explicit regeneration. Do not generate it implicitly in a participant workflow. |
| Where should reusable results be saved? | In the active exercise copy using setup's resolved paths. Use `paths.ComparisonImageFile` for the PNG. Never use `tempdir`, `pwd`, or a machine-specific mount for persistent artifacts. |
| Should the full scenario be run repeatedly while debugging? | No. Use short validation runs first, then run the full characterized scenario once after the implementation is stable. |
| How should a simulation section rerun handle the live metric plot? | Clear the characterized animated line before appending the new run, so its previous endpoint is not connected back to time zero. |
| Should original helper files be modified? | No. Reuse the supplied helpers and place any needed adaptations in new helper files under `paths.HelperFunctionsFolder`. |
| Should noisy Exercise 2 generator output be shown? | The current generator assigns `radar` with a semicolon; run it normally. |
| How should MATLAB Online windows be sized? | Use compact normalized `uifigure` positions with the tracking viewer on the left and the metric plot on the right, staying within the prompt's hard maximum sizes. |

## Fast Workflow

1. Start in this exercise folder and read `Exercise3Prompt.md`. Inspect only the useful portion of Live Scripts before the line beginning `%[appendix]`.
2. Call `paths = setupExercise3()` and load/validate the supplied baseline. Use `paths.BaselineScript` for the original script and `paths.HelperFunctionsFolder` for its supporting code. Setup requires no generated solution files.
3. Run `paths.RadarFile` and capture `radar`.
4. Adapt `radar` for Exercise 3 spherical detections with elevation and range-rate support.
5. Validate radar construction in MATLAB.
6. Validate detection generation on a small number of frames.
7. Validate tracker execution on a shortened scenario.
8. Keep diagnostic results separate from the supplied baseline; never overwrite it.
9. Run the full characterized scenario once from a clean workspace, save the comparison PNG beside the exercise, and verify the baseline remains unchanged.
10. Summarize files changed, radar-model changes, observed tracking effects, and recommended next experiments.

## Session Constraints

- Retain the original scenario intent.
- Retain the airborne radars as they are.
- Preserve the existing tracker configuration unless the user explicitly asks for tracking changes.
- Regenerate detections using the characterized radar.
- Do not overwrite original Exercise 3 files.
- Do not overwrite Exercise 2 output.
- Final deliverables should be plain-text `.m` Live Script compatible when the prompt asks for a Live Script.
- Keep `mfilename` in regular helper functions; use `setupExercise3` in Live Scripts.
- After building the solution, run it using the full path within `paths.Exercise3Folder`. MATLAB MCP `run_matlab_file` accepts that full script path and sets its working folder automatically. Do not hard-code a different exercise copy.
- Future agents should still follow explicit user instructions over this file.
