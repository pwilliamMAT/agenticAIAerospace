# Exercise 2 - Surveillance Radar Characterization

Use `exercise2_prompt.md` with `SurveillanceRadar.pdf` to characterize the
representative fixed-site surveillance radar and create MATLAB artifacts for
the wide-area surveillance scenario in Exercise 3.

## Contents

| File | Purpose |
| --- | --- |
| `exercise2_prompt.md` | Requirements for the radar characterization and data-generator artifacts |
| `SurveillanceRadar.pdf` | Representative surveillance-radar baseline datasheet |
| `exercise2_output/characterizeRadar.m` | Monostatic radar-equation SNR characterization and metric plot |
| `exercise2_output/dataGenerator.m` | Configured `radarDataGenerator` for Exercise 3 integration |

## Setup

Required MATLAB output files will be generated in `exercise2_output/`. `characterizeRadar.m` uses the datasheet
hardware values to plot single-pulse and coherent-dwell available SNR.
`dataGenerator.m` creates the `radar` variable used by the Exercise 3
ground-radar replacement.
