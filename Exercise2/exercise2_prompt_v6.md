Use the training datasheet in `ASR-12-WorkshopRadar.pdf` to build two
MATLAB scripts in this folder.

1. First create `characterizeRadar.m`.
   - Extract and validate the radar parameters from the PDF text using
     `extractFileText`. Keep the selected model values inline and
     concisely commented.
   - Plot SNR versus range with the Radar Toolbox function
     `radarmetricplot`.
   - Use SI units (m, s, Hz, W, K, dB) for the radar-equation calculation.
     When calling `radarmetricplot`, check the documentation to ensure you are passing units correctly. 
   - Make 2 plots. First 1, uses 1 pulse. For the second which we can mark as "Electronic dwell", model 20 coherent pulses on target as an explicit assumption. Use one
     internally consistent SNR accounting convention:
       * Plot integrated available SNR as single-pulse `radareqsnr` output
         plus `pow2db(20)`.
       * Include the 6 dB system loss once, in `radareqsnr`.
       * Compare it against `detectability(Pd,Pfa)` plus only any explicitly
         selected detector-processing loss. Do not add the coherent gain or
         system loss a second time to the requirement.
     State whether a CFAR loss is omitted or included. If included, state
     its method and value in the script output.
   - Use Pd = 0.90 and Pfa = 1e-6. Plot pass/fail colored regions and show
     the 463 km requirement. Supply data through at least 500 km so the
     requirement does not truncate the x-axis; also identify the 444 km
     instrumented range separately from the 463 km evaluation point.
   - Include brief printed diagnostics
   - Verify numerically that the printed values and plotted curve share the
     same dB convention.
   - Reminder the SNR plot functions create a figure for you, you do not need to call "figure" first.
2. Then create `dataGenerator.m`.
   - Create one minimal inline `radarDataGenerator` configuration using the
     same PDF-derived values. Do not create a radar scenario.
   - Preserve literal datasheet units. Use 444 km for the instrumented reporting range and 461 km
     only where an unambiguous-range setting is applicable to the chosen
     object configuration.
   - Avoid unsupported or irrelevant properties that produce construction
     warnings. The script should define only the reusable object.

Implementation guidance:
- Work sequentially and avoid extra files.
- Double-check Radar Toolbox APIs and their output units with MATLAB MCP
  before finalizing.
- Do not feel the need to include assert statements within the code.
- Run static analysis and both scripts in MATLAB after writing them.
- Inspect the resulting SNR figure through MATLAB: confirm that stoplight
  regions are present, the x-axis reaches at least 500 km, and the vertical
  requirement marker is at 463 km.

Once complete, provide a concise summary of the files created, the
detection and beam-pattern assumptions, the SNR accounting convention, and
the MATLAB validation results.
