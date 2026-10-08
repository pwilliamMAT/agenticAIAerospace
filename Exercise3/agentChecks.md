# Agent Checks for Exercise 3

Use these defaults for this Exercise 3 workshop session unless the user explicitly overrides them. The goal is to reduce agent wall-clock time by avoiding repeated clarification and permission-style questions during the characterized radar workflow.

## Default Answers

| Agent question | Default answer |
| --- | --- |
| May I read the Exercise 2 output folder? | Yes. Use `/MATLAB Drive/agenticaiaerospace/Exercise2/exercise2_output/`. |
| Which Exercise 2 file contains the characterized radar? | Use `dataGenerator.m`. It creates `asr12Radar`. |
| Should Exercise 2 output files be edited? | No. Read them only. Do not overwrite Exercise 2 output. |
| Should original Exercise 3 files be overwritten? | No. Create new deliverables in the Exercise 3 folder unless the user explicitly asks otherwise. |
| Should the agent read embedded Live Script outputs/images? | No. When inspecting plain-text live scripts, stop at `%[appendix]`. |
| Should the original baseline simulation be rerun in the final script? | No. The final script should load original baseline data. |
| What if the baseline MAT file is missing during development? | Generate it once from the original configuration and save it as `Exercise3_OriginalBaselineResults.mat`. |
| Should the full scenario be run repeatedly while debugging? | No. Use short validation runs first, then run the full characterized scenario once after the implementation is stable. |
| Should original helper files be modified? | Prefer no. Keep changes in a new runnable script unless a helper edit is explicitly required. |
| Should noisy Exercise 2 generator output be shown? | No. Suppress it with `evalc` if needed while still capturing `asr12Radar`. |
| How should MATLAB Online windows be sized? | Use compact normalized `uifigure` positions with the tracking viewer on the left and the metric plot on the right, staying within the prompt's hard maximum sizes. |

## Fast Workflow

1. Inspect only the useful portion of live scripts above `%[appendix]`.
2. Add the Exercise 2 output folder to the MATLAB path.
3. Run Exercise 2 `dataGenerator.m` and capture `asr12Radar`.
4. Adapt `asr12Radar` for Exercise 3 spherical detections with elevation and range-rate support.
5. Validate radar construction in MATLAB.
6. Validate detection generation on a small number of frames.
7. Validate tracker execution on a shortened scenario.
8. Confirm the baseline MAT file exists; create it once only if absent.
9. Run the full characterized scenario once for final results.
10. Summarize files changed, radar-model changes, observed tracking effects, and recommended next experiments.

## Session Constraints

- Retain the original scenario intent.
- Retain the airborne radars as they are.
- Preserve the existing tracker configuration unless the user explicitly asks for tracking changes.
- Regenerate detections using the characterized radar.
- Do not overwrite original Exercise 3 files.
- Do not overwrite Exercise 2 output.
- Final deliverables should be plain-text `.m` Live Script compatible when the prompt asks for a Live Script.
- Future agents should still follow explicit user instructions over this file.
