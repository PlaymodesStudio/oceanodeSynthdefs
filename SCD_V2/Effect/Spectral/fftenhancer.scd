(
~synthCreator.value("FFTEnhancer", {|n|
	var sig, size=2048, finalSig, processedSig, dryWet;
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);

	// Parameters

	dryWet = OceanodeParameter.kr(\mix, 1, n, 0, 1, "vf");

	// Process each channel individually
	processedSig = Array.fill(n, {|i|
		var ch = sig[i];
		var chain;

		// Create FFT chain
		chain = FFT(LocalBuf(size), ch);

		// Simpler approach - just use MagSquared to emphasize harmonics
		// This boosts strong frequencies and attenuates weak ones
		// without the complexity that was causing errors
		chain = PV_MagSquared(chain);

		// Convert back to time domain
		IFFT(chain);
	});

	// Apply mix mixing
	finalSig = Array.fill(n, {|i|
		XFade2.ar(sig[i], processedSig[i], dryWet * 2 - 1);
	});

	// Apply level control
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Simple spectral enhancer for emphasizing harmonic content", category: "Effect/Spectral", variables: [], variableDimensions: []);
)