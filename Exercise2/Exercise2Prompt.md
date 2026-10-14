# Exercise 2 — Surveillance Radar Characterization

From `SurveillanceRadar.pdf`, create exactly these output files (and no
others):

- `exercise2_output/characterizeRadar.m`
- `exercise2_output/dataGenerator.m`

Create the output folder only if needed. Before coding, use MATLAB MCP to
verify Radar Toolbox and read installed help for `radarmetricplot` and
`radarDataGenerator`. Use MATLAB `extractFileText` to read the PDF.
Statically analyze and execute both scripts after writing them.

## `characterizeRadar.m`

Use a monostatic radar equation with SI calculations. Define selected PDF
values inline with brief comments describing their meaning and SI
conversions. Use a 10 m^2 target and `Pd = 0.90`.

Use gain for both transmit and receive inputs. Include the 6 dB loss once,
only in `radareqsnr`.

Plot range to at least 500 km, explicitly including 463 km. Plot:

- single-pulse available SNR;
- 20-pulse coherent-dwell available SNR.

Use `radarmetricplot` without pre-creating a figure. Include stoplight
regions Pd and requirements. Print the single-pulse SNR,
dwell SNR, and requirement at 463 km. Inspect the completed figure.

## `dataGenerator.m`

Create one inline `radarDataGenerator`; do not create a scenario. Use:

- `Pd = 0.90`, `Pfa = 1e-6`, 463 km reference range, and 10 dBsm reference
  RCS;
- 500 km range limit and unambiguous range;
- range ambiguities

Use the PDF reporting resolutions. Do not set center frequency,
bandwidth, a scenario, or unsupported properties. Construction must issue
no warnings. It should a single defined inline commented function call. 

### Exercise 3 integration

To make the generator work with the future Exercise 3 scenario,
inspect the Exercise 3 setup before configuring scenario-facing properties.
Keep PDF-derived hardware values and Exercise 3 scenario assumptions
clearly distinguished in code comments.
