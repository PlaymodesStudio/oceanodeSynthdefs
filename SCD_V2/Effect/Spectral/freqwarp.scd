(
~synthCreator.value("FreqWarp", {|n, variables|
	var source, outSig, numFreqs, spacing;
	var minFreq, maxFreq, outMinFreq, outMaxFreq;
	var mix, level, attack, release;
	var envShape, shapeFactor;

	// Number of frequency bands - keep this small for real-time efficiency
	numFreqs = 128;

	// Input signal - process each channel independently
	source = In.ar(OceanodeInput.kr(\in), n);

	// Get parameter values
	minFreq = OceanodeParameter.kr(\minfreq, 60, n, 20, 500, "f");
	maxFreq = OceanodeParameter.kr(\maxfreq, 6000, n, 1000, 18000, "f");
	outMinFreq = OceanodeParameter.kr(\outminfreq, 60, n, 20, 500, "f");
	outMaxFreq = OceanodeParameter.kr(\outmaxfreq, 6000, n, 1000, 18000, "f");
	attack = OceanodeParameter.kr(\attack, 0.01, n, 0.001, 0.1, "f");
	release = OceanodeParameter.kr(\release, 0.05, n, 0.01, 0.5, "f");
	level = OceanodeParameter.kr(\level, 0.2, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.kr(\mix, 1, n, 0, 1, "vf");
	envShape = OceanodeParameterDropdown.kr(\envtype, 0, n, "Linear:Convex:S-curve:Reversed");
	shapeFactor = OceanodeParameter.kr(\shapefactor, 0, n, -2, 2, "f");

	// Process each input channel independently
	outSig = n.collect({ |chan|
		var channelOutput, bandAmps, inFreqs, outFreqs, bwFactors;
		var sines;

		// Create frequencies evenly distributed in logarithmic space
		// We have to avoid Array methods that cause issues in SynthDef

		// Process the signal through bands
		sines = numFreqs.collect({ |i|
			var norm = i / (numFreqs - 1);
			var inFreq, outFreq, bw, amp;

			// Calculate input frequency for this band (logarithmic spacing)
			inFreq = minFreq * ((maxFreq / minFreq) ** norm);

			// Calculate bandwidth for this band (proportional to frequency)
			bw = 0.2; // A reasonable Q factor for the filter

			// Shape the normalized position based on envType
			norm = Select.kr(
				envShape,
				[
					norm, // Linear
					norm.squared, // Convex curve
					0.5 * (1 - cos(norm * pi)), // Smooth S-curve
					1 - norm // Reversed linear
				]
			);

			// Apply additional shape factor
			norm = (norm * (1 + shapeFactor * (norm - 0.5)));
			norm = norm.clip(0, 1);

			// Calculate output frequency
			outFreq = outMinFreq * ((outMaxFreq / outMinFreq) ** norm);

			// Analyze the input at this frequency
			amp = Amplitude.kr(
				Resonz.ar(source[chan], inFreq, bw),
				attackTime: attack[chan],
				releaseTime: release[chan]
			);

			// Generate sine at the morphed frequency with the analyzed amplitude
			SinOsc.ar(outFreq, 0, amp)
		});

		// Sum all the bands and apply level control
		Mix.new(sines) * level[chan];
	});

	// Mix wet and dry signals
	outSig = SelectX.ar(mix, [source, outSig]);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), outSig);
}, category: "Effects/Spectral", description: "Spectral morphing effect");
)