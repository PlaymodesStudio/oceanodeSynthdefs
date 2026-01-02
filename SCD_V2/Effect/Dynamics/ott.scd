(
~synthCreator.value("OTT", {|n|
	// Define all variables at the beginning
	var input, low, mid, high, processed;
	var lowProcessed, midProcessed, highProcessed;
	var outputVol, preclip, targetAmp, mix;
	var lowFreq, highFreq;
	var upRatio, downRatio, upThresh, downThresh;
	var attackTime, releaseTime;
	var ottBandProcess;

	// Get parameters with proper Oceanode control format
	outputVol = OceanodeParameterLag.ar(\outputvol, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	preclip = OceanodeParameter.ar(\preclip, 0.5, n, 0, 1, "vf");
	targetAmp = OceanodeParameter.ar(\targetamp, 1, n, 0.1, 2, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Band split frequencies
	lowFreq = OceanodeParameter.ar(\lowfreq, 250, n, 50, 500, "vf");
	highFreq = OceanodeParameter.ar(\highfreq, 2000, n, 1000, 8000, "vf");

	// Compression parameters
	upRatio = OceanodeParameter.ar(\upratio, 5, n, 1, 10, "vf");
	downRatio = OceanodeParameter.ar(\downratio, 10, n, 1, 20, "vf");
	upThresh = OceanodeParameter.ar(\upthresh, 0.1, n, 0.01, 0.5, "vf");
	downThresh = OceanodeParameter.ar(\downthresh, 0.5, n, 0.3, 0.9, "vf");

	// Time constants
	attackTime = OceanodeParameter.ar(\attack, 0.002, n, 0.0001, 0.05, "vf");
	releaseTime = OceanodeParameter.ar(\release, 0.05, n, 0.01, 0.5, "vf");

	// Define the band processing function
	ottBandProcess = {|signal|
		var env, upwardGain, downwardGain, compressed, clipped;
		var silenceDetect, upGainCalc, downGainCalc;

		// Detect envelope
		env = Amplitude.ar(signal, attackTime, releaseTime);

		// Silence detection
		silenceDetect = (env <= 0.00001);

		// Upward compression (boost quiet parts)
		// When below upThresh, boost by upRatio
		upGainCalc = (upThresh / env.max(0.00001)).pow(1 - (1/upRatio));
		upwardGain = Select.ar(env < upThresh, [
			DC.ar(1.0),
			upGainCalc
		]);

		// Downward compression (reduce loud parts)
		// When above downThresh, reduce by downRatio
		downGainCalc = (downThresh / env.max(0.00001)).pow(1 - (1/downRatio));
		downwardGain = Select.ar(env > downThresh, [
			DC.ar(1.0),
			downGainCalc
		]);

		// Apply silence handling and both compression types
		compressed = signal *
			Select.ar(silenceDetect, [upwardGain * downwardGain, DC.ar(1.0)]) *
			targetAmp;

		// Soft clipping stage
		clipped = (compressed * preclip).clip2(targetAmp);

		clipped;
	};

	// Get input from Oceanode input bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Split into three bands using Butterworth filters for phase coherence
	low = BLowPass4.ar(input, lowFreq);
	high = BHiPass4.ar(input, highFreq);
	mid = input - low - high; // Residual method

	// Process each band with OTT-style compression
	lowProcessed = ottBandProcess.value(low);
	midProcessed = ottBandProcess.value(mid);
	highProcessed = ottBandProcess.value(high);

	// Recombine bands
	processed = (lowProcessed + midProcessed + highProcessed) * outputVol;

	// Mix dry and wet signals
	processed = XFade2.ar(input, processed, mix.linlin(0, 1, -1, 1));

	// Send to Oceanode output bus
	Out.ar(OceanodeOutput.kr(\out), processed);
}, description: "OTT-style multiband upward/downward compressor", category: "Effect/Dynamics");
)