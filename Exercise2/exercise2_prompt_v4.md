Use the training datasheet in `ASR-12-WorkshopRadar.pdf` to build two MATLAB scripts in this folder.

1. First create `characterizeRadar.m`.
   - Extract the radar parameters from the PDF text.
   - Plot **SNR vs. range** using MATLAB Radar Toolbox such as "radarmetricplot".
   - Use the valid Radar Toolbox plotting function name if the prompt wording is slightly off.
   - The plot must show **pass/fail colored regions** and must display **both**:
     - the **range requirement** at **463 km**
     - the **instrumented range** at **250 nmi**
   - Do **not** let the range requirement truncate the x-axis. The x-axis should extend far enough to see beyond the requirement and out to at least the instrumented range.
   - Incorporate the radar beamwidth information from the datasheet into the characterization logic where relevant.
   - For detection performance, assume **20 pulses on target integrated**. Treat this as an explicit modeling assumption in the script rather than deriving it from scan rate.
   - Be careful with units. Use consistent units throughout and avoid hidden unit conversions that could silently change the answer.
   - Include brief printed diagnostics in the script output for:
     - required detectability SNR
     - single-pulse SNR at 463 km
     - assumed pulses on target
     - integrated SNR at 463 km
   - The final script should make it easy to see whether the radar meets the 463 km requirement under the stated assumptions.

2. Then create `dataGenerator.m`.
   - Create a simple `radarDataGenerator` object configuration using the same PDF-derived radar parameters.
   - Keep the script minimal and inline; avoid unnecessary helper functions or extra files. Use inline property values.
   - Do not build a radar scenario yet.
   - This script is only meant to define the `radarDataGenerator` call so it can be reused later.

Implementation guidance:
- Work sequentially.
- Avoid creating excess files.
- Double-check the MATLAB APIs you use with MCP before finalizing.
- Validate the scripts in MATLAB with MCP after writing them.
- If there is any ambiguity between a literal prompt term and the actual MATLAB function name, prefer the real MATLAB API and note that choice in the final summary.

Once complete, give a concise summary of what you created, what assumptions you used, and how you validated the result.
