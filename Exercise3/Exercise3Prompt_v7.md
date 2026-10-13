# Exercise 3 Prompt

Inspect the Exercise3_WideAreaSurveillance.m exercise in this folder and the
radar dataGenerator.m file in 
"/MATLAB Drive/agenticaiaerospace/Exercise2/exercise2_output/"

Create a new runnable version of the surveillance simulation that uses the 
characterized radar from exercise 2 for the three stationary ground-radar 
sites. Retain the airborne radars as they are and maintain the original 
scenario intent.

Make sure the new script adds the path to the "exercise2_output" folder so 
that running the new script can find the radar file from Exercise 2.

The radarDataGenerator Object that is output by Exercise 2 does not specify 
the "DetectionCoordinates".  Make sure to update this radarDataGenerator to 
report detections in "Sensor spherical" to be compatible with this scenario.

The output file MUST be a LiveScript formatted file. Keep it as a 
plain-text .m file that begins with the required  %\[text] # Exercise 3 
title form and use the MATLAB Live Script guidance to validate the exact 
syntax before editing.

In the final version of the file, do not rerun the original simulation. 
Load the data from the original simulation.

In the final version of the file, when the updated version of the simulation 
runs, make sure the trackingGlobeViewer is shown and the metric plot updates 
dynamically in its own window.

The metrics visualization MUST show the baseline in default blue and the new 
configuration's metrics should be plotted with orange/red.

Do not overwrite the original files or the Exercise 2 output. You can change 
the radarDataGenerator parameters once the object is instantiated within the 
new script.

# Formatting requirements for MATLAB Online:
````
The live `trackingGlobeViewer` and the dynamically updating metrics plot must be easy to watch together in MATLAB Online on a laptop screen. Err on the side of smaller windows: it is acceptable for the windows to leave unused browser workspace, but it is not acceptable for either window to be near full-screen, clipped by the MATLAB Online browser chrome, hidden behind another window, or difficult to resize because an edge is inaccessible.

Do not rely on MATLAB's default figure or axes sizes. Explicitly size and position both `uifigure` windows using normalized units so the layout adapts to the available MATLAB Online browser workspace. Keep both windows comfortably inside the browser workspace with visible margins on all sides. Place the tracking viewer on the left and the metrics window on the right. The viewer should be larger than the metrics window, but both should be deliberately conservative in size.

Use this laptop-safe compact layout unless there is a strong reason to go smaller. This deliberately undershoots the available space because MATLAB Online browser zoom, browser toolbars, bookmarks bars, side panels, and the MATLAB desktop chrome can all reduce the visible workspace:

```matlab
viewerFigure = uifigure( ...
    Units="normalized", ...
    Position=[0.04 0.32 0.36 0.38], ...
    Name="Characterized Radar Tracking Viewer");

metricFigure = uifigure( ...
    Units="normalized", ...
    Position=[0.42 0.58 0.24 0.22], ...
    Name="Live OSPA Metric Comparison");
````

Hard maximums: the viewer window width must not exceed `0.40`, viewer height must not exceed `0.42`, metrics window width must not exceed `0.26`, and metrics window height must not exceed `0.24`. The right edge of the metrics window should be at or left of `0.70`, not near `1.0`, because MATLAB Online often has right-side panels open. The bottom edge of every window should be at or above `0.25`, so MATLAB Online status bars and docked panels do not cover the resize handles.

After creating the windows, verify during development that both are fully visible without manual resizing at normal browser zoom and at one zoom level larger than normal. If either window is clipped, overlaps badly, or hides resize handles, reduce the width and height by at least `0.05` and rerun the short validation case. Do not increase figure sizes during final polish unless the windows remain fully visible on a laptop-sized MATLAB Online workspace with typical side panels open.

The metrics axes must fill the metrics window cleanly. Do not use the default `uiaxes(metricFigure)` placement, because it can leave a large empty figure with only a small plot area. Use a tight layout manager or explicitly set normalized axes position.
Preferred version:
```
metricLayout = uigridlayout(metricFigure, [1 1]);
metricLayout.Padding = [10 8 10 8];
metricLayout.RowHeight = {'1x'};
metricLayout.ColumnWidth = {'1x'};
metricAxes = uiaxes(metricLayout);
```

Alternative acceptable version:
```
metricAxes = uiaxes(metricFigure, ...
    Units="normalized", ...
    Position=[0.12 0.18 0.83 0.72]);
```
Keep labels, title, grid, and legend readable but compact. Use a compact font size such as 10 or 11 points for metric axes labels and legend. The final viewing experience should support the main workshop workflow: watch the globe scenario animate while the OSPA metric streams in beside it, without requiring the user to manually resize or hunt for windows.

# Implementation guidance:

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

# Generate a concise comparison consisting of:

1. One metric comparison plot that plots the original OSPA statically and 
dynamically updates the OSPA for the simulation with new radar configuration 
as the simulation runs
2. One summary table
3. One visualization image

Do not recreate every figure or screenshot from the original example.

# Use MATLAB MCP to:

* verify radar construction
* verify detection generation
* verify tracker execution on a small subset of frames
* execute the full scenario once for final results

# At the end summarize:

* files changed
* radar-model changes
* observed tracking effects
* recommended next experiments
