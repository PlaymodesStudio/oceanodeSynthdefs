(
~synthCreator.value("MonoBandPassBank256", {|n|
	var input, dry, bands, freqs, qs, amps, pans, output, levels, finalOutput, mix;
	var numBands = 256;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get input signal and store original for dry/wet mix
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Mix to mono for processing
	input = Mix(input) / n.max(1);

	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true);

	// Get dry/wet mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process through band-pass bank with panning
	bands = Array.fill(numBands, { |i|
		var bpf1 = BPF.ar(input, freqs[i], qs[i]);
		var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
		PanAz.ar(n, bpf2 * amps[i], pans[i])
	});

	// Mix all bands
	output = Mix(bands) * scaling;

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	output = output * levels;

	// Apply dry/wet mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "256-band bandpass filter with spectral panning", category: "Effect/Filter");
)

(
~synthCreator.value("MonoBandPassBank128", {|n|
	var input, dry, bands, freqs, qs, amps, pans, output, levels, finalOutput, mix;
	var numBands = 128;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get input signal and store original for dry/wet mix
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Mix to mono for processing
	input = Mix(input) / n.max(1);

	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true);

	// Get dry/wet mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process through band-pass bank with panning
	bands = Array.fill(numBands, { |i|
		var bpf1 = BPF.ar(input, freqs[i], qs[i]);
		var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
		PanAz.ar(n, bpf2 * amps[i], pans[i])
	});

	// Mix all bands
	output = Mix(bands) * scaling;

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	output = output * levels;

	// Apply dry/wet mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "128-band bandpass filter with spectral panning", category: "Effect/Filter");
)

(
~synthCreator.value("MonoBandPassBank64", {|n|
	var input, dry, bands, freqs, qs, amps, pans, output, levels, finalOutput, mix;
	var numBands = 64;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get input signal and store original for dry/wet mix
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Mix to mono for processing
	input = Mix(input) / n.max(1);

	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true);

	// Get dry/wet mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process through band-pass bank with panning
	bands = Array.fill(numBands, { |i|
		var bpf1 = BPF.ar(input, freqs[i], qs[i]);
		var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
		PanAz.ar(n, bpf2 * amps[i], pans[i])
	});

	// Mix all bands
	output = Mix(bands) * scaling;

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	output = output * levels;

	// Apply dry/wet mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "64-band bandpass filter with spectral panning", category: "Effect/Filter");
)

(
~synthCreator.value("MonoBandPassBank32", {|n|
	var input, dry, bands, freqs, qs, amps, pans, output, levels, finalOutput, mix;
	var numBands = 64;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get input signal and store original for dry/wet mix
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Mix to mono for processing
	input = Mix(input) / n.max(1);

	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true);

	// Get dry/wet mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process through band-pass bank with panning
	bands = Array.fill(numBands, { |i|
		var bpf1 = BPF.ar(input, freqs[i], qs[i]);
		var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
		PanAz.ar(n, bpf2 * amps[i], pans[i])
	});

	// Mix all bands
	output = Mix(bands) * scaling;

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	output = output * levels;

	// Apply dry/wet mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "32-band bandpass filter with spectral panning", category: "Effect/Filter");
)