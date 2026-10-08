%% Characterize ASR-12 training radar from the supplied datasheet
% This script extracts the radar parameters from ASR-12-WorkshopRadar.pdf,
% computes SNR versus range, and plots the result with the 463 km range
% requirement and 250 nmi instrumented range shown on the same axis.

clear; clc;

scriptFolder = fileparts(mfilename("fullpath"));
exercise2Folder = fileparts(scriptFolder);
pdfFile = fullfile(exercise2Folder, "ASR-12-WorkshopRadar.pdf");
pdfText = char(extractFileText(pdfFile));
pdfText = regexprep(pdfText, char(160), " ");

c_mps = physconst("LightSpeed");
nmiToM = 1852;
kmToM = 1000;
referenceNoiseTemperature_K = 290;
numPulsesIntegrated = 20;

rangeTokens = regexp(pdfText, ...
    "Instrumented range\s+0-\s*([0-9.]+)\s*nmi\s*\(0-\s*([0-9.]+)\s*km\)", ...
    "tokens", "once");
if isempty(rangeTokens)
    error("Could not extract the instrumented range from %s.", pdfFile);
end

instrumentedRange_nmi = str2double(rangeTokens{1});
rangeRequirement_km = str2double(rangeTokens{2});

fc_Hz = extractScalar(pdfText, "Carrier frequency,\s*fc\s+([0-9.]+)\s*GHz", 1e9, "carrier frequency");
peakPower_W = extractScalar(pdfText, "Peak transmit power,\s*Pt\s+([0-9.]+)\s*MW", 1e6, "peak transmit power");
prf_Hz = extractScalar(pdfText, "Pulse repetition frequency,\s*PRF\s+([0-9.]+)\s*Hz", 1, "PRF");
pulseWidth_s = extractScalar(pdfText, "Transmit pulse width,\s*tau\s+([0-9.]+)\s*us", 1e-6, "pulse width");
antennaGain_dBi = extractScalar(pdfText, "Antenna peak gain,\s*G\s+([0-9.]+)\s*dBi", 1, "antenna gain");
azBeamwidth_deg = extractScalar(pdfText, "Azimuth 3 dB beamwidth\s+([0-9.]+)\s*deg", 1, "azimuth beamwidth");
elBeamwidth_deg = extractScalar(pdfText, "Elevation 3 dB beamwidth\s+([0-9.]+)\s*deg", 1, "elevation beamwidth");
noiseFigure_dB = extractScalar(pdfText, "Receiver noise figure\s+([0-9.]+)\s*dB", 1, "noise figure");
systemLoss_dB = extractScalar(pdfText, "System losses\s+([0-9.]+)\s*dB", 1, "system losses");
referenceRCS_m2 = extractScalar(pdfText, "Reference target RCS\s+([0-9.]+)\s*m2", 1, "reference target RCS");
pd = extractScalar(pdfText, "Probability of detection,\s*Pd\s+([0-9.]+)", 1, "probability of detection");
pfa = extractScalar(pdfText, "Probability of false alarm,\s*Pfa\s+([0-9.]+e[+-]?[0-9]+)", 1, "probability of false alarm");

rangeRequirement_m = rangeRequirement_km * kmToM;
instrumentedRange_m = instrumentedRange_nmi * nmiToM;
instrumentedRange_km = instrumentedRange_m / kmToM;
lambda_m = c_mps / fc_Hz;
systemTemperature_K = referenceNoiseTemperature_K * db2pow(noiseFigure_dB);
integrationGain_dB = pow2db(numPulsesIntegrated);

% The datasheet reference condition is a boresight 10 m^2 target in clear air.
% For the beam-edge trace, the one-way antenna gain is reduced by 3 dB at
% the half-power beamwidth edge, which produces a 6 dB monostatic SNR drop.
beamEdgeGain_dBi = antennaGain_dBi - 3;

requiredDetectability_dB = detectability(pd, pfa, 1, "Swerling0");
requiredNoncoherentPulseSnr_dB = detectability(pd, pfa, numPulsesIntegrated, "Swerling0");

plotLimit_m = max([rangeRequirement_m, instrumentedRange_m]) * 1.14;
ranges_m = linspace(1e3, plotLimit_m, 700).';
ranges_km = ranges_m / kmToM;

singlePulseSNRBoresight_dB = radareqsnr(lambda_m, ranges_m, peakPower_W, pulseWidth_s, ...
    "RCS", referenceRCS_m2, ...
    "Ts", systemTemperature_K, ...
    "Gain", antennaGain_dBi, ...
    "Loss", systemLoss_dB);
singlePulseSNRBeamEdge_dB = radareqsnr(lambda_m, ranges_m, peakPower_W, pulseWidth_s, ...
    "RCS", referenceRCS_m2, ...
    "Ts", systemTemperature_K, ...
    "Gain", beamEdgeGain_dBi, ...
    "Loss", systemLoss_dB);

integratedSNRBoresight_dB = singlePulseSNRBoresight_dB + integrationGain_dB;
integratedSNRBeamEdge_dB = singlePulseSNRBeamEdge_dB + integrationGain_dB;

singlePulseAtRequirement_dB = radareqsnr(lambda_m, rangeRequirement_m, peakPower_W, pulseWidth_s, ...
    "RCS", referenceRCS_m2, ...
    "Ts", systemTemperature_K, ...
    "Gain", antennaGain_dBi, ...
    "Loss", systemLoss_dB);
integratedAtRequirement_dB = singlePulseAtRequirement_dB + integrationGain_dB;
snrMarginAtRequirement_dB = integratedAtRequirement_dB - requiredDetectability_dB;
meetsRequirement = integratedAtRequirement_dB >= requiredDetectability_dB;
if meetsRequirement
    verdictText = "PASS";
else
    verdictText = "FAIL";
end

fprintf("ASR-12 training radar characterization\n");
fprintf("Required detectability SNR for Pd = %.2f and Pfa = %.1e: %.2f dB\n", ...
    pd, pfa, requiredDetectability_dB);
fprintf("Single-pulse SNR at %.0f km: %.2f dB\n", ...
    rangeRequirement_km, singlePulseAtRequirement_dB);
fprintf("Assumed pulses on target integrated: %d\n", numPulsesIntegrated);
fprintf("Integrated SNR at %.0f km: %.2f dB\n", ...
    rangeRequirement_km, integratedAtRequirement_dB);
fprintf("Integrated SNR margin at %.0f km: %.2f dB\n", ...
    rangeRequirement_km, snrMarginAtRequirement_dB);
fprintf("20-pulse noncoherent single-pulse detectability reference: %.2f dB\n", ...
    requiredNoncoherentPulseSnr_dB);
fprintf("Antenna 3 dB beamwidth used for beam-edge trace: %.1f deg azimuth x %.1f deg elevation\n", ...
    azBeamwidth_deg, elBeamwidth_deg);
fprintf("Unambiguous range from PRF %.0f Hz: %.1f km\n", ...
    prf_Hz, c_mps/(2*prf_Hz)/kmToM);
fprintf("Requirement verdict at %.0f km: %s\n", rangeRequirement_km, verdictText);

ax = radarmetricplot(ranges_km, ...
    [integratedSNRBoresight_dB, integratedSNRBeamEdge_dB], ...
    requiredDetectability_dB, requiredDetectability_dB, ...
    "MaxRangeRequirement", rangeRequirement_km, ...
    "ShowStoplight", true, ...
    "RadarName", ["Boresight", "3 dB beam edge"], ...
    "MetricName", "20-pulse integrated SNR", ...
    "RequirementName", "Detectability", ...
    "RangeUnit", "km", ...
    "MetricUnit", "dB");

grid(ax, "on");
hold(ax, "on");
xline(ax, rangeRequirement_km, "k--", "463 km requirement", ...
    "LabelOrientation", "horizontal", "LabelVerticalAlignment", "top");
xline(ax, instrumentedRange_km, "b:", "250 nmi instrumented range", ...
    "LabelOrientation", "horizontal", "LabelVerticalAlignment", "bottom");
yline(ax, requiredDetectability_dB, "r--", "Required detectability SNR");
title(ax, "ASR-12 Training Radar SNR vs. Range");
subtitle(ax, sprintf("%d-pulse coherent integration, %.0f m^2 target, clear-air free-space baseline", ...
    numPulsesIntegrated, referenceRCS_m2));
xlim(ax, [0 plotLimit_m/kmToM]);
hold(ax, "off");

if meetsRequirement
    disp("PASS: Integrated boresight SNR meets the 463 km requirement under the stated assumptions.");
else
    disp("FAIL: Integrated boresight SNR does not meet the 463 km requirement under the stated assumptions.");
end

function value = extractScalar(pdfText, expression, scale, label)
token = regexp(pdfText, expression, "tokens", "once");
if isempty(token)
    error("Could not extract %s from the PDF text.", label);
end
value = str2double(token{1}) * scale;
end
