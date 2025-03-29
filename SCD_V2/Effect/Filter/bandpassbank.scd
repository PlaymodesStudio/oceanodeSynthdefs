(
~synthCreator.value("BandPassBank1024", {|n|
	var input, bands, freqs, qs, amps, output, levels, finalOutput, mix;
	var numBands = 1024;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Get parameter arrays with lag for smooth transitions
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);

	// Get dry/wet mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process each channel individually
	output = Array.fill(n, { |chanNum|
		var chanInput = input[chanNum];
		var chanBands = Array.fill(numBands, { |i|
			// First BPF - single band
			var bpf1 = BPF.ar(chanInput, freqs[i], qs[i]);
			// Second BPF - cascaded for steeper filter
			var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
			bpf2 * amps[i]
		});
		Mix(chanBands) * scaling
	});

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	output = output * levels;

	// Apply dry/wet mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(input[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "1024-band bandpass filter bank", category: "Effect/Filter");
)