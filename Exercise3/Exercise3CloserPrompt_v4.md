# Exercise 3 Closer Prompt

Inspect the MATLAB wide-area surveillance exercise in this folder and the
radar artifact produced by Exercise 2.



Create a new runnable version that uses the characterized radar for the
three stationary ground-radar sites while retaining the airborne radars
and the original scenario intent.



Make sure the new script adds the path to the "exercise2Output" folder so that running the new script can find the radar file from Exercise 2.



The output file MUST be a LiveScript formatted file. Keep it as a plain-text .m file that begins with the required  %\[text] # Exercise 3 title form and use the MATLAB Live Script guidance to validate the exact syntax before editing.



In the final version of the file, do not rerun the simulation. Load the data from the original simulation.



In the final version of the file, when the updated version of the simulation runs, make sure the trackingGlobeViewer is shown and the metric plot updates dynamically in its own window.



The metrics visualization MUST show the baseline in default blue and the new configuration's metrics should be plotted with orange/red.



Do not overwrite the original files or the Exercise 2 output.

Implementation guidance:

* Reuse the existing example structure as much as possible.
* The primary modifications should occur where the radarDataGenerator
objects are created.
* Preserve the existing tracker configuration.
* Regenerate detections using the characterized radar.
* During development, use shortened runs, reduced frame counts, or
partial execution whenever possible.
* Validate code incrementally through MATLAB MCP.
* Do not repeatedly execute the full scenario while debugging.
* Execute the complete simulation only after implementation is stable.



Generate a concise comparison consisting of:

1. One metric comparison plot that plots the original OSPA statically and dynamically updates the OSPA for the simulation with new radar configuration as the simulation runs
2. One summary table
3. One visualization image





Do not recreate every figure or screenshot from the original example.

Use MATLAB MCP to:

* verify radar construction
* verify detection generation
* verify tracker execution on a small subset of frames
* execute the full scenario once for final results

At the end summarize:

* files changed
* radar-model changes
* observed tracking effects
* recommended next experiments

