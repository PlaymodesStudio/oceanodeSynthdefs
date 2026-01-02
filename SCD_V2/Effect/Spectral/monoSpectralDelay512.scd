(
~synthCreator.value("MonoSpectralDelay512", {|n|
	var input, inputStored, bands, freqs, qs, amps, pans, output, levels, finalOutput, mix, delays, decays, mappedDecays, send, dry;
	var numBands = 512;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);

	// Get input signal and store original for mix mix
	input = In.ar(OceanodeInput.kr(\in), n);
	inputStored = input*send;
	// Mix to mono for processing
	dry = Mix(inputStored) / n.max(1);
	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true);
	delays = OceanodeParameterLag.ar(\delayarray, 0, numBands, 0, 2000, "vf", 1/30, true)/1000.0;
	decays = OceanodeParameterLag.ar(\decayarray, 0, numBands, 0, 1, "vf", 1/30, true);

	// Map decays from 0-1 to 0-inf range
	// Using a scaled tan function to create asymptotic mapping to infinity
	 mappedDecays = tan(decays * pi/2);

	// Get mix mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	// Process through band-pass bank with panning
	bands = Array.fill(numBands, { |i|
		var bpf1 = BPF.ar(dry, freqs[i], qs[i]);
		var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
		// CombC expects: in, maxdelaytime, delaytime, decaytime
		var del = CombC.ar(bpf2, 2, delays[i], mappedDecays[i]);
		PanAz.ar(n, del * amps[i], pans[i])
	});
	// Mix all bands
	output = Mix(bands) * scaling;
	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	output = output * levels;
	// Apply mix mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(input[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});
	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "512-band spectral delay with panning and mapped decay times", category: "Effect/Spectral");
)