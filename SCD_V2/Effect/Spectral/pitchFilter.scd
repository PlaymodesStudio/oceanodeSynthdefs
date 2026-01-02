(
~synthCreator.value("PitchFilter", {|n|
	var input, outputSignal;
	var pitches, bandwidth, resonance, mix, levels;

	// Parameters with appropriate ranges and defaults
	pitches = OceanodeParameter.ar(\pitches, 60!128, n, 0, 127, "vf");  // Array of MIDI notes
	bandwidth = OceanodeParameter.ar(\bandwidth, 0.1, n, 0.01, 1, "vf");
	resonance = OceanodeParameter.ar(\resonance, 30, n, 1, 100, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);
	input = LeakDC.ar(input);

	// Process each channel using a bank of resonant filters
	outputSignal = Array.fill(n, {|i|
		var localInput = input[i];
		var filtered;

		// Convert MIDI pitches to frequencies
		var freqs = pitches.midicps;

		// Create a bank of Resonant filters (BPF) for each frequency
		// Simplify the approach using a direct filter bank rather than FFT
		filtered = Mix.ar(
			BPF.ar(
				localInput,                   // Input signal
				freqs,                        // Center frequencies (array)
				bandwidth[i],                 // Relative bandwidth
				resonance[i]                  // Resonance/amplitude
			)
		);

		// Apply mix and level
		filtered = (filtered * mix[i]) + (localInput * (1 - mix[i]));
		filtered = filtered * levels[i];

		filtered;
	});

	// Output
	Out.ar(OceanodeOutput.kr(\out), outputSignal);
}, description: "Filter that passes frequencies at specified pitches array", category: "Effect/Spectral", variables: [], variableDimensions: []);
)