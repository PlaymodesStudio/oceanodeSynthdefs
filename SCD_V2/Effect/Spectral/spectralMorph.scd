(
~synthCreator.value("SpectralMorph", {|n|
	var sig, sig2, chain, chain2, size=2048, finalSig, processedSig, dryWet, morphAmt;
	// Input signals from two audio inputs
	sig = In.ar(OceanodeInput.kr(\in1), n);
	sig2 = In.ar(OceanodeInput.kr(\in2), n);

	// Get mix parameter for mix balance
	dryWet = OceanodeParameter.kr(\mix, 1, n, 0, 1, "vf");
	// Morph parameter
	 morphAmt = OceanodeParameter.kr(\morphamt, 0.5, n, 0, 1, "vf");
	// Process each channel individually
	processedSig = Array.fill(n, {|i|
		var ch1 = sig[i];
		var ch2 = sig2[i];
		var fftchain1, fftchain2, result;
		// Create FFT chains for individual channels
		fftchain1 = FFT(LocalBuf(size), ch1);
		fftchain2 = FFT(LocalBuf(size), ch2);
		// Use pvcalc2 to process spectral data
		result = fftchain1.pvcalc2(fftchain2, size, {
			arg mag1, phs1, mag2, phs2;
			// Morph between both spectral images
			var resultMag = (mag1 * (1-morphAmt)) + (mag2 * morphAmt);
			var resultPhs = (phs1 * (1-morphAmt)) + (phs2 * morphAmt);
			[resultMag, resultPhs];
		});
		// Convert back to time domain
		IFFT(result);
	});
	// Apply mix mixing
	finalSig = Array.fill(n, {|i|
		XFade2.ar(sig[i], processedSig[i], dryWet * 2 - 1);
	});
	// Apply level control
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Phase vocoder morphing between two spectral sources", category: "Effect/Spectral");
)