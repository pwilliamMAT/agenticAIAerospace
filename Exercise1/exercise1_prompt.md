# Exercise 2 — Surveillance Radar Characterization and Detection Generator

Use the training datasheet in `SurveillanceRadar.pdf` to create two MATLAB scripts in this folder:

- `characterizeRadar.m`
- `dataGenerator.m`

Place both files in the "exercise2_output" folder. Create the folder only if needed. 

Work sequentially, create no extra files, and use MATLAB MCP to check the installed Radar Toolbox documentation before implementing `radarmetricplot` and `radarDataGenerator`. Run static analysis and execute both scripts after writing them.

## 1. `characterizeRadar.m`

Extract the PDF text with `extractFileText` in MATLAB. Keep the selected datasheet values inline, with concise comments and appropriate SI conversions.

Build a monostatic radar-equation analysis using SI units for all calculations.

Use a clearly stated representative target model of 10 m² RCS.

Use `Pd = 0.90` and `Pfa = 1e-6` for the exercise detection requirement. The PDF’s false-alarm design point is background information.

Create one SNR-versus-range figure with both of these curves:

- single-pulse available SNR;
- an electronic-dwell curve based on 20 coherently integrated pulses on target.

Use `radarmetricplot` to show pass/fail stoplight regions, a detection requirement, and both curves with clear legend entries. Check the installed documentation and pass its range values in units consistent with the selected `RangeUnit`.

Use this SNR accounting convention consistently:

- Include the 6 dB system loss once in the single-pulse `radareqsnr` calculation.
- Do not add coherent gain or system loss a second time to the detection requirement.

Plot data through at least 500 km. Mark and distinguish:

- the 463 km SNR evaluation requirement

Numerically verify that the reported SNR at the evaluation range and the plotted curve use the same dB convention.

`radarmetricplot` creates its own figure, so do not create a figure before calling it. Inspect the finished MATLAB figure and confirm that stoplight regions are present, both curves appear, the x-axis reaches at least 500 km, and the 463 km marker is correctly located.

## 2. `dataGenerator.m`

Create one minimal, reusable inline `radarDataGenerator` object using the compatible PDF-derived reporting and measurement values. Do not create a radar scenario.

Configure the end-scenario search geometry as follows:

- hybrid mechanical/electronic scanning;
- 1 Hz update rate;
- 30° azimuth by 20° elevation field of view;
- 360° mechanical azimuth steering coverage;
- a centered 20° electronic elevation steering sector (−10° to +10°);
- elevation and range-rate reporting enabled;
- range ambiguities enabled only if needed to use the unambiguous-range setting.

Use the datasheet reporting resolutions and the 10 m² target reference model. Use `Pd = 0.90` and `Pfa = 1e-6`.

Do not set center frequency or bandwidth for this reusable end-scenario generator. Avoid properties that are unsupported or irrelevant for the selected object configuration, and ensure construction produces no warnings.

## Completion report

Provide a concise summary of the results.
