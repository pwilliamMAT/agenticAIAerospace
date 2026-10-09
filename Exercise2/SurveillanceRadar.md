# Surveillance Radar

## S-Band Rotating AESA Primary Surveillance Radar

Surveillance Radar is a fixed-site, long-range primary radar for wide-area air
surveillance. It combines a mechanically rotating antenna with an S-band active
electronically scanned array (AESA). Mechanical rotation provides continuous
all-azimuth coverage.

This document defines a baseline hardware configuration. Search volume, scan rate,
elevation limits, detection threshold, reporting range, and target model are
mission- and site-configurable.

## Baseline radar parameters

| Parameter | Baseline specification |
|---|---|
| Radar type | Fixed-site, monostatic, hybrid mechanically rotating AESA |
| Frequency band | S-band |
| Nominal frequency, `fc` | 2.9 GHz |
| Azimuth coverage | 360° continuous |
| Azimuth scan method | Mechanical rotation; rate configurable by operating mode |
| Elevation coverage | Electronically controlled; limits configured for the installation and mission |
| Azimuth beamwidth / search-cell resolution | 2.8° nominal |
| Elevation beam spacing | 2.23° nominal |
| Pulse waveform | Coherent pulsed |
| Pulse width, `τ` | 2.15 μs |
| Nominal PRF | 300 Hz |
| Nominal range resolution | 323 m |

## Antenna and RF subsystem

| Parameter | Baseline specification |
|---|---|
| Array type | Planar GaN transmit/receive AESA mounted on a rotating pedestal |
| Peak antenna gain, `G` | 37 dBi nominal at boresight |
| Peak transmit power, `Pt` | 750 kW |
| Receiver noise figure, `NF` | 4.0 dB nominal |
| System loss allowance, `Ls` | 6.0 dB representative end-to-end |

## Signal processing and reporting

| Parameter | Baseline specification |
|---|---|
| Range reporting resolution | 323 m |
| Azimuth reporting resolution | 2.8° |
| Elevation reporting resolution | 2.23° |
| Range-rate reporting increment | 100 m/s |
| Baseline false-alarm design point | 1 × 10⁻⁷ per resolution cell |

## Parameters for radar-equation characterization

The table below is the intended baseline input set for a first-order monostatic
radar-range calculation. Scenario-specific items should be selected separately.

| Quantity | Baseline value | Scenario-dependent input |
|---|---:|---|
| Transmit power, `Pt` | 750 kW peak | Waveform/mode selection |
| Antenna gain, `G` | 37 dBi | Scan angle and radome losses |
| Carrier frequency, `fc` | 2.9 GHz | Fixed baseline |
| Pulse width, `τ` | 2.15 μs | Waveform/mode selection |
| PRF | 300 Hz nominal | Ambiguity and revisit requirements |
| Receiver noise figure | 4.0 dB | Temperature and receiver implementation |
| System loss | 6.0 dB | Site, radome, processing, and installation losses |

*Specifications are representative baseline values and subject to change without
notice.*
