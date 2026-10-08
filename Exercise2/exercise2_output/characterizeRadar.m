%characterizeRadar Characterize the ASR-12 training radar from its datasheet.

pdfText = extractFileText(fullfile(pwd,"ASR-12-WorkshopRadar.pdf"));
requiredText = ["2.80 GHz" "1.10 MW" "325 Hz" "2.15 us" ...
    "37.21 dBi" "4.0 dB" "6.0 dB" "10 m2" "0-444 km"];
if ~all(contains(pdfText,requiredText))
    error("ASR-12-WorkshopRadar.pdf does not contain the expected training parameters.")
end

speedOfLight = physconst("LightSpeed");
carrierFrequency = 2.80e9;          % Datasheet: 2.80 GHz
peakTransmitPower = 1.10e6;         % Datasheet: 1.10 MW
pulseWidth = 2.15e-6;               % Datasheet: 2.15 us
antennaGain = 37.21;                % Datasheet: 37.21 dBi
noiseFigure = 4.0;                  % Datasheet: 4.0 dB
systemLoss = 6.0;                   % Datasheet: 6.0 dB
targetRCS = 10;                     % Datasheet: 10 m^2
instrumentedRange = 444e3;          % Datasheet: 444 km (reporting range)
evaluationRange = 463e3;            % Exercise evaluation point: 463 km
pd = 0.90;                          % Datasheet detection assumption
pfa = 1e-6;                         % Datasheet false-alarm assumption

wavelength = speedOfLight/carrierFrequency;
systemTemperature = 290*db2pow(noiseFigure); % 290 K antenna, NF converted to K
detectorProcessingLoss = 0;         % Explicit selection: no added detector loss
cfarLoss = 0;                       % Omitted: no CFAR-loss model selected
numberOfCoherentPulses = 20;        % Explicit electronic-dwell assumption

rangeM = (1e3:1e3:500e3).';
rangeKm = rangeM/1e3;
singlePulseSnr = radareqsnr(wavelength,rangeM,peakTransmitPower,pulseWidth, ...
    RCS=targetRCS,Ts=systemTemperature,Gain=antennaGain,Loss=systemLoss);
integratedSnr = singlePulseSnr + pow2db(numberOfCoherentPulses);
requiredSnr = detectability(pd,pfa) + detectorProcessingLoss;

singlePulseAtEvaluation = radareqsnr(wavelength,evaluationRange, ...
    peakTransmitPower,pulseWidth,RCS=targetRCS,Ts=systemTemperature, ...
    Gain=antennaGain,Loss=systemLoss);
curveAtEvaluation = singlePulseSnr(rangeM == evaluationRange);
integratedAtEvaluation = singlePulseAtEvaluation + pow2db(numberOfCoherentPulses);

fprintf("ASR-12 training radar: instrumented reporting range = %.0f km; evaluation point = %.0f km.\n", ...
    instrumentedRange/1e3,evaluationRange/1e3);
fprintf("System temperature = %.1f K from 4.0 dB NF; system loss = %.1f dB and is included once in radareqsnr.\n", ...
    systemTemperature,systemLoss);
fprintf("Pd = %.2f, Pfa = %.1e: detectability requirement = %.2f dB; detector-processing loss = %.1f dB.\n", ...
    pd,pfa,requiredSnr,detectorProcessingLoss);
fprintf("CFAR loss is omitted (no CFAR model or value selected).\n");
fprintf("At %.0f km: 1-pulse SNR = %.2f dB, 20-pulse electronic-dwell SNR = %.2f dB.\n", ...
    evaluationRange/1e3,singlePulseAtEvaluation,integratedAtEvaluation);
fprintf("Curve/direct 1-pulse check at %.0f km = %.3g dB; all plotted SNR values are dB.\n", ...
    evaluationRange/1e3,curveAtEvaluation-singlePulseAtEvaluation);

ax = radarmetricplot(rangeKm,singlePulseSnr,requiredSnr,requiredSnr, ...
    'MaxRangeRequirement',evaluationRange/1e3,'ShowStoplight',true, ...
    'RadarName',{'ASR-12'},'MetricName',"Available SNR (1 pulse)", ...
    'RequirementName',"Pd = 0.90, Pfa = 10^{-6}",'RangeUnit',"km",'MetricUnit',"dB");
title(ax,"Single-pulse detection opportunity")

ax = radarmetricplot(rangeKm,integratedSnr,requiredSnr,requiredSnr, ...
    'MaxRangeRequirement',evaluationRange/1e3,'ShowStoplight',true, ...
    'RadarName',{'ASR-12'},'MetricName',"Integrated available SNR (dB)", ...
    'RequirementName',"Pd = 0.90, Pfa = 10^{-6}",'RangeUnit',"km",'MetricUnit',"dB");
title(ax,"Electronic dwell: 20 coherent pulses on target")
