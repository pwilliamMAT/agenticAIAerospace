% CHARACTERIZERADARASR11 Validate the ASR-11 training datasheet and plot SNR.

% Datasheet model: 2.80 GHz, 1.10 MW, 0.80 us, 34 dBi, 10 m^2.
fc = 2.80e9;                 % Hz
peakPower = 1.10e6;          % W
pulseWidth = 0.80e-6;        % s
antennaGain = 34;            % dBi, boresight transmit and receive gain
targetRCS = 10;              % m^2
noiseFigure = 4.0;           % dB
systemLoss = 7.0;            % dB, included once by radareqsnr
prf = 1000;                  % Hz
azimuthBeamwidth = 1.4;      % deg, 3 dB beamwidth
scanRate = 12.5*360/60;      % deg/s; 12.5 rpm
pd = 0.90;
pfa = 1e-6;

beamDwellTime = azimuthBeamwidth/scanRate;
nominalPulsesInDwell = prf*beamDwellTime;
coherentPulses = round(nominalPulsesInDwell); % 19 pulses from 18.67 nominal

speedOfLight = physconst("LightSpeed");
wavelength = speedOfLight/fc;
systemTemperature = 290*db2pow(noiseFigure); % K; T0 multiplied by NF
range = (1:500)'*1e3;        % m; extends beyond 150 km unambiguous range

% radareqsnr returns single-pulse receiver SNR in dB for SI inputs.
singlePulseSNR = radareqsnr(wavelength,range,peakPower,pulseWidth, ...
    RCS=targetRCS,Ts=systemTemperature,Gain=antennaGain,Loss=systemLoss);
integratedSNR = singlePulseSNR + pow2db(coherentPulses);

% Coherent gain is already in available SNR; no added detector or CFAR loss.
detectorProcessingLoss = 0;  % dB
requiredSNR = pow2db(detectability(pd,pfa)) + detectorProcessingLoss;

nmi = 1852;                  % m
referenceRange = 50*nmi;     % m; datasheet Pd reference condition
instrumentedRange = 60*nmi;  % m; reporting gate
referenceSNR = interp1(range,integratedSNR,referenceRange,"linear");
instrumentedSNR = interp1(range,integratedSNR,instrumentedRange,"linear");
assert(abs(referenceSNR - ...
    (interp1(range,singlePulseSNR,referenceRange,"linear") + ...
    pow2db(coherentPulses))) < 1e-12, ...
    "Integrated SNR convention is inconsistent.")

fprintf("ASR-11 validated: fc %.2f GHz, Pt %.2f MW, tau %.2f us, G %.1f dBi.\n", ...
    fc/1e9,peakPower/1e6,pulseWidth/1e-6,antennaGain)
fprintf("Beam dwell %.2f ms at %.1f rpm; %.2f pulses nominal, %d integrated.\n", ...
    beamDwellTime*1e3,12.5,nominalPulsesInDwell,coherentPulses)
fprintf("Tsys %.1f K; system loss %.1f dB is included once in radareqsnr.\n", ...
    systemTemperature,systemLoss)
fprintf("SNR at 50 nmi: %.2f dB; at 60 nmi: %.2f dB; requirement: %.2f dB.\n", ...
    referenceSNR,instrumentedSNR,requiredSNR)
fprintf("Coherent gain: %.2f dB; detector loss: %.1f dB; CFAR loss: omitted.\n", ...
    pow2db(coherentPulses),detectorProcessingLoss)
fprintf("50 nmi result: %s (margin %.2f dB).\n", ...
    string(referenceSNR >= requiredSNR),referenceSNR - requiredSNR)

figure(Name="ASR-11 Integrated Available SNR");
snrAxes = radarmetricplot(range/1e3,integratedSNR,requiredSNR, ...
    MaxRangeRequirement=referenceRange/1e3,ShowStoplight=true, ...
    RangeUnit="km",MetricUnit="dB",MetricName="Integrated available SNR", ...
    RequirementName="Pd = 0.90, Pfa = 1e-6");
xline(instrumentedRange/1e3,":","60 nmi instrumented range", ...
    Color=[0.35 0.35 0.35],LabelVerticalAlignment="bottom");
xline(referenceRange/1e3,"--","50 nmi Pd reference", ...
    Color="k",LabelVerticalAlignment="bottom");
xlim(snrAxes,[0 500])
grid(snrAxes,"on")

% The plotted metric input is the same dB convention as the diagnostics.
fprintf("Plot/diagnostic convention check at 50 nmi: %.2f dB vs %.2f dB.\n", ...
    referenceSNR,interp1(range,integratedSNR,referenceRange,"linear"))
