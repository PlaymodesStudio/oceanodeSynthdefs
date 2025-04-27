(
~synthCreator.value("Cuntpressor", {|n|
	// Define all variables at the beginning
	var input, inputAbs, peakSignal, maxSignal, divided, smoothedGain, processed;
	var clipThreshold, preClipGain, clipped, wetSignal, finalOutput;
	var outputVol, preclip, targetAmp, targetFreq, peakFreq, mix;
	var peakCoef, smoothCoef, silenceDetect;

	// Get parameters with proper Oceanode control format
	outputVol = OceanodeParameterLag.ar(\outputvol, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	preclip = OceanodeParameter.ar(\preclip, 0.5, n, 0, 1, "vf");
	targetAmp = OceanodeParameter.ar(\targetamp, 1, n, 0.1, 2, "vf");
	targetFreq = OceanodeParameter.ar(\targetfreq, 160, n, 20, 2000, "vf");
	peakFreq = OceanodeParameter.ar(\peakfreq, 80, n, 20, 1000, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Get input from Oceanode input bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Convert frequencies to coefficients for OnePole filters
	// Coef = 0.01 at 20kHz, 0.999 at 20Hz
	peakCoef = 1 - (peakFreq / SampleRate.ir).clip(0, 1);
	smoothCoef = 1 - (targetFreq / SampleRate.ir).clip(0, 1);

	// Processing chain using OnePole instead of LPF
	inputAbs = input.abs;
	peakSignal = OnePole.ar(inputAbs, peakCoef);
	maxSignal = max(inputAbs, peakSignal);

	// Create a silence detection signal (1 when silent, 0 otherwise)
	silenceDetect = (maxSignal <= 0.00001);

	// Calculate gain with protection against division by zero
	divided = targetAmp / maxSignal.max(0.00001);

	// Use the silence detection to determine if we should use unity gain
	// When silent, we replace the divided value with DC.ar(1.0) (unity gain)
	smoothedGain = OnePole.ar(
		(silenceDetect * DC.ar(1.0)) + ((1-silenceDetect) * divided),
		smoothCoef
	);

	// Multiplication of input with smoothed gain
	processed = input * smoothedGain;

	// Clip processing with inverted targetAmp as threshold
	clipThreshold = targetAmp * -1;
	preClipGain = processed * preclip;
	clipped = preClipGain.clip(clipThreshold, targetAmp);

	// Final wet signal with volume control
	wetSignal = clipped * outputVol;

	// Mix dry and wet signals using XFade2
	finalOutput = XFade2.ar(input, wetSignal, mix.linlin(0, 1, -1, 1));

	// Send to Oceanode output bus
	Out.ar(OceanodeOutput.kr(\out), finalOutput);

}, description: "Frequency aware compressor with peak tracking", category: "Effect/Dynamics");
)