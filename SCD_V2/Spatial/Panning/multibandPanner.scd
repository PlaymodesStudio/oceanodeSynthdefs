(
~synthCreator.value("MultibandPanaz1024", {|n|
	var input, dry, frequencies, bpfs, mixedBands, pannedBands, output, bandAmps, panPositions, mix, levels;
	var numBands = 1024;

	// Get input signal and store original for dry/wet mix
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Define parameters for the bands
	bandAmps = OceanodeParameterLag.ar(\bandamps, 1, numBands, 0, 1, "vf", 1/30, true);
	panPositions = OceanodeParameterLag.ar(\positions, 0, numBands, -1, 1, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Calculate frequency bands using Mel scale for better perceptual division
	// Low freq = 20Hz, High freq = 20000Hz
	frequencies = Array.fill(numBands, {|i|
		var melLow = 1127 * log(1 + (20/700));
		var melHigh = 1127 * log(1 + (20000/700));
		var melStep = (melHigh - melLow) / (numBands+1);
		var melPoint = melLow + (melStep * (i+1));
		// Convert back from Mel to Hz
		700 * (exp(melPoint / 1127) - 1);
	});

	// Process each input channel through band-pass filters
	bpfs = Array.fill(n, {|chanIdx|
		Array.fill(numBands, {|bandIdx|
			var centerFreq = frequencies[bandIdx];
			var q = centerFreq / (centerFreq / 1.5); // Approximately 1.5 octave bandwidth

			// Apply bandpass filter to the input channel
			BPF.ar(input[chanIdx], centerFreq, 1/q);
		});
	});

	// Mix the same frequency bands from all channels
	mixedBands = Array.fill(numBands, {|bandIdx|
		var bandSum = Array.fill(n, {|chanIdx|
			bpfs[chanIdx][bandIdx];
		});
		Mix(bandSum) / n.max(1); // Normalize to avoid clipping
	});

	// Apply band amplitude control and pan each mixed band
	pannedBands = Array.fill(numBands, {|bandIdx|
		PanAz.ar(n, mixedBands[bandIdx] * bandAmps[bandIdx], panPositions[bandIdx]);
	});

	// Sum all panned bands to get the output
	output = Mix(pannedBands);

	// Apply level control
	output = output * levels;

	// Apply dry/wet mix using XFade2
	output = Array.fill(n, {|i|
		XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1));
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "1024-band panner with perceptual frequency division", category: "Spatial");
)