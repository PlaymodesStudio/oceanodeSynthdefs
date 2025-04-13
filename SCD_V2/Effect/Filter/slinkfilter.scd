(
~synthCreator.value("SlinkFilter", {|n|
	var inSig, sig, offset, density, rq, minFreq, maxFreq, numBands, ratio, freqs, amps, sigs;

	// Parameters
	density = OceanodeParameterLag.ar(\density, 0.85, n, 0, 1, "vf", 1/30, true);
	offset = OceanodeParameterLag.ar(\offset, 0, n, 0, 1, "vf", 1/30, true);
	rq = OceanodeParameterLag.ar(\rq, 0.05, n, 0.01, 1, "vf", 1/30, true);
	minFreq = OceanodeParameterLag.ar(\minfreq, 120, n, 20, 1000, "vf", 1/30, true);
	maxFreq = OceanodeParameterLag.ar(\maxfreq, 16000, n, 1000, 20000, "vf", 1/30, true);

	// Filter bank implementation
	numBands = 32;

	// Input signal
	inSig = In.ar(OceanodeInput.kr(\in), n);

	// High shelf filter
	sig = BHiShelf.ar(inSig, 1320, 0.5, 10);

	// Calculate logarithmic ratio
	ratio = log2(maxFreq / minFreq) / (numBands - 1);

	// Create and run filter bank
	sigs = n.collect({|ch|
		var channelSig = sig[ch];
		var filteredSigs = Array.fill(numBands, {|i|
			var localFreq, amp;
			localFreq = minFreq * (2 ** ((i * ratio * density[ch]) + sin(i * offset[ch])));
			localFreq = min(localFreq, maxFreq);

			// Calculate amplitude (fade out highest frequencies)
			amp = (1 - ((localFreq - (maxFreq - 2000)) / 2000)).clip(0, 1);

			// Apply band-pass filter and amplitude
			BPF.ar(channelSig, localFreq, rq[ch]) * amp;
		});

		// Sum all filtered signals
		filteredSigs.sum;
	});

	// Apply level control with proper dB scaling
	sigs = sigs * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Mix control
	sigs = XFade2.ar(inSig, sigs, OceanodeParameterLag.ar(\mix, 1, n, -1, 1, "vf", 1/30, true));

	// Output
	Out.ar(OceanodeOutput.kr(\out), sigs);

}, description: "Spectral filtering effect with modulated bandpass filterbank", category: "Effect/Filter");
)