(
~synthCreator.value("SpectralDelay", {|n|
	var inSig, sig;
	var fftSize = 512; // Size of FFT
	var maxDelay = 1.0; // Maximum delay time in seconds


	// Buffer parameters for delay and feedback - these will be connected to external buffers
	var delayBufNum = OceanodeBuffer.kr(\delaybuff128);
	var feedbackBufNum = OceanodeBuffer.kr(\feedbuff128);

	// Mix and level parameters
	var mix = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
	var level = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);


	// Input signal
	inSig = In.ar(OceanodeInput.kr(\in), n);

	// Process each channel individually
	sig = n.collect{|i|
		var fftBuf, chain, wetSignal, chan;

		// Get input channel
		chan = inSig[i];

		// Create local FFT buffer for this channel
		fftBuf = LocalBuf(fftSize);

		// Apply FFT to input using local FFT buffer
		chain = FFT(fftBuf, chan, 0.25);

		// Apply spectral delay with external buffers for control
		chain = PV_BinDelay(chain, maxDelay, delayBufNum, feedbackBufNum, 0.25);

		// Convert back to time domain
		wetSignal = IFFT(chain);

		// Mix dry and wet signals
		(chan * (1 - mix[i])) + (wetSignal * mix[i] * level[i]);
	};

	// Send to output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Spectral delay with external control buffers", category: "Effect/Spectral");
)