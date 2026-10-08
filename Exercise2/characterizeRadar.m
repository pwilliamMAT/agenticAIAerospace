% CHARACTERIZERADAR Validate the training datasheet and plot available SNR.

% Datasheet model: 2.80 GHz, 1.10 MW, 2.15 us, 37.21 dBi, 10 m^2.
fc = 2.80e9;                 % Hz
peakPower = 1.10e6;          % W
pulseWidth = 2.15e-6;        % s
antennaGain = 37.21;         % dBi, boresight transmit and receive gain
targetRCS = 10;              % m^2
noiseFigure = 4.0;           % dB
systemLoss = 6.0;            % dB, included once by radareqsnr
pd = 0.90;
pfa = 1e-6;
coherentPulses = 20;         % Explicit exercise assumption

speedOfLight = physconst("LightSpeed");
wavelength = speedOfLight/fc;
systemTemperature = 290*db2pow(noiseFigure); % K; T0 multiplied by NF
range = (1:550)'*1e3;        % m; goes beyond the 463 km evaluation point

% radareqsnr returns single-pulse receiver SNR in dB for SI inputs.
singlePulseSNR = radareqsnr(wavelength,range,peakPower,pulseWidth, ...
    RCS=targetRCS,Ts=systemTemperature,Gain=antennaGain,Loss=systemLoss);
integratedSNR = singlePulseSNR + pow2db(coherentPulses);

% Coherent integration is already in available SNR. No extra detector loss.
% CFAR loss is omitted: detectability(Pd,Pfa) is used without a CFAR model.
detectorProcessingLoss = 0;  % dB
requiredSNR = pow2db(detectability(pd,pfa)) + detectorProcessingLoss;

instrumentedRange = 444e3;   % m (240 nmi reporting gate)
evaluationRange = 463e3;     % m exercise evaluation point
instrumentedIndex = find(range == instrumentedRange,1);
evaluationIndex = find(range == evaluationRange,1);
assert(~isempty(instrumentedIndex) && ~isempty(evaluationIndex))
assert(abs(integratedSNR(evaluationIndex) - ...
    (singlePulseSNR(evaluationIndex) + pow2db(coherentPulses))) < 1e-12, ...
    "Integrated SNR convention is inconsistent.")

fprintf("ASR-12 validated: fc %.2f GHz, Pt %.2f MW, tau %.2f us, G %.2f dBi.\n", ...
    fc/1e9,peakPower/1e6,pulseWidth/1e-6,antennaGain)
fprintf("Tsys %.1f K; system loss %.1f dB is included once in radareqsnr.\n", ...
    systemTemperature,systemLoss)
fprintf("SNR at 444 km: %.2f dB; at 463 km: %.2f dB; requirement: %.2f dB.\n", ...
    integratedSNR(instrumentedIndex),integratedSNR(evaluationIndex),requiredSNR)
fprintf("20-pulse coherent gain: %.2f dB; detector loss: %.1f dB; CFAR loss: omitted.\n", ...
    pow2db(coherentPulses),detectorProcessingLoss)
fprintf("463 km result: %s (margin %.2f dB).\n", ...
    string(integratedSNR(evaluationIndex) >= requiredSNR), ...
    integratedSNR(evaluationIndex) - requiredSNR)

figure(Name="ASR-12 Integrated Available SNR");
snrAxes = radarmetricplot(range/1e3,integratedSNR,requiredSNR, ...
    MaxRangeRequirement=evaluationRange/1e3,ShowStoplight=true, ...
    RangeUnit="km",MetricUnit="dB",MetricName="Integrated available SNR", ...
    RequirementName="Pd = 0.90, Pfa = 1e-6");
xline(instrumentedRange/1e3,":",sprintf("444 km instrumented range"), ...
    Color=[0.35 0.35 0.35],LabelVerticalAlignment="bottom");
xline(evaluationRange/1e3,"--",sprintf("463 km evaluation"), ...
    Color="k",LabelVerticalAlignment="bottom");
xlim(snrAxes,[0 550])
grid(snrAxes,"on")

% The plotted metric input is the same dB vector reported above.
plottedMetric = integratedSNR(evaluationIndex);
fprintf("Plot/diagnostic convention check at 463 km: %.2f dB vs %.2f dB.\n", ...
    plottedMetric,integratedSNR(evaluationIndex))
