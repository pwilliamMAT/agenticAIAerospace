%% characterizeRadar
% Monostatic surveillance-radar range/SNR characterization from the
% companion SurveillanceRadar.pdf training datasheet.

scriptFolder = fileparts(mfilename("fullpath"));
pdfPath = fullfile(fileparts(scriptFolder),"SurveillanceRadar.pdf");
extractLogPath = fullfile(pwd,"SurveillanceRadar.log");
removeExtractLog = ~isfile(extractLogPath);
datasheetText = extractFileText(pdfPath);
if removeExtractLog && isfile(extractLogPath)
    delete(extractLogPath); % Remove the extraction by-product, if MATLAB creates it.
end
assert(contains(datasheetText,"Surveillance Radar"), ...
    "The expected SurveillanceRadar.pdf datasheet was not found.");

% Selected datasheet values, converted to SI units where applicable.
c = physconst("LightSpeed");          % m/s
carrierFrequency = 2.9e9;             % 2.9 GHz nominal carrier, Hz
wavelength = c/carrierFrequency;      % m
peakPower = 750e3;                    % 750 kW peak transmit power, W
pulseWidth = 2.15e-6;                 % 2.15 us pulse width, s
antennaGain = 37;                     % 37 dBi peak gain, dB
noiseFigure = 4;                      % 4 dB receiver noise figure, dB
systemTemperature = 290*db2pow(noiseFigure); % Reference-temperature equivalent, K
systemLoss = 6;                       % 6 dB end-to-end system loss, dB
targetRCS = 10;                       % Representative exercise target, m^2

probabilityDetection = 0.90;          % Exercise detection requirement
probabilityFalseAlarm = 1e-6;         % Exercise false-alarm requirement
numberCoherentPulses = 20;            % Pulses integrated while on target
evaluationRange = 463e3;              % Required SNR evaluation range, m

range = linspace(1e3,600e3,1000).';   % Plot past 500 km, m
singlePulseSnr = radareqsnr(wavelength,range,peakPower,pulseWidth, ...
    RCS=targetRCS,Ts=systemTemperature,Gain=antennaGain,Loss=systemLoss);
singlePulseSnrDb = singlePulseSnr;    % radareqsnr returns SNR directly in dB.
electronicDwellSnrDb = singlePulseSnrDb + pow2db(numberCoherentPulses);

% Detection threshold is independent of the plotted system-loss/gain accounting.
detectionRequirementDb = pow2db(detectability(probabilityDetection, ...
    probabilityFalseAlarm));

evaluationSnr = radareqsnr(wavelength,evaluationRange,peakPower,pulseWidth, ...
    RCS=targetRCS,Ts=systemTemperature,Gain=antennaGain,Loss=systemLoss);
evaluationSnrDb = evaluationSnr;
plottedEvaluationSnrDb = interp1(range,singlePulseSnrDb,evaluationRange,"linear");
assert(abs(evaluationSnrDb-plottedEvaluationSnrDb) < 0.01, ...
    "The evaluation SNR and plotted curve do not use the same dB convention.");

% radarmetricplot creates and owns its figure; range values are kilometres.
rangeKm = range/1e3;
evaluationRangeKm = evaluationRange/1e3;
metricAxes = radarmetricplot(rangeKm, ...
    [singlePulseSnrDb,electronicDwellSnrDb],detectionRequirementDb, ...
    ShowStoplight=true,MaxRangeRequirement=evaluationRangeKm, ...
    RadarName=["Single-pulse available SNR","20-pulse electronic dwell SNR"], ...
    MetricName="Available SNR",MetricUnit="dB", ...
    RequirementName="Pd = 0.90, Pfa = 10^{-6} detection requirement", ...
    RangeUnit="km");
xline(metricAxes,evaluationRangeKm,"k--","463 km evaluation requirement", ...
    LabelVerticalAlignment="bottom",LabelHorizontalAlignment="center");

fprintf("Single-pulse SNR at 463 km: %.2f dB\n",evaluationSnrDb);
fprintf("20-pulse electronic-dwell SNR at 463 km: %.2f dB\n", ...
    evaluationSnrDb + pow2db(numberCoherentPulses));
fprintf("Detection requirement: %.2f dB\n",detectionRequirementDb);
