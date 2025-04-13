(
~synthCreator.value("FFTVocoderMax", {|n|
	var sig, sig2, chain, chain2, size=2048, finalSig, processedSig, dryWet;
	// Input signals from two audio inputs
	sig = In.ar(OceanodeInput.kr(\in1), n);
	sig2 = In.ar(OceanodeInput.kr(\in2), n);

	// Get mix parameter for dry/wet balance
	dryWet = OceanodeParameter.kr(\mix, 1, n, 0, 1, "vf");
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
			// Take maximum magnitude with corresponding phase
			// Using Select.kr instead of 'if' for UGen compatibility
			var useFirstSignal = mag1 > mag2;
			var resultMag = max(mag1, mag2);
			var resultPhs = Select.kr(useFirstSignal, [phs2, phs1]);
			[resultMag, resultPhs];
		});
		// Convert back to time domain
		IFFT(result);
	});
	// Apply dry/wet mixing
	finalSig = Array.fill(n, {|i|
		XFade2.ar(sig[i], processedSig[i], dryWet * 2 - 1);
	});
	// Apply level control
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Phase vocoder taking maximum magnitude from either input with corresponding phase", category: "Effect/Spectral");
)