(
~synthCreator.value("SpectralDelay512", {|n|
	var input, inputStored, output, levels, finalOutput, mix, freqs, qs, amps, delays, decays, mappedDecays, send;
	var numBands = 512;
	var scaling = 1/numBands.sqrt;  // Compensate for band summation

	// Get parameter arrays
	freqs = OceanodeParameterLag.ar(\pitcharray, 60, numBands, 0, 130, "vf", 1/30, true).midicps;
	qs = OceanodeParameterLag.ar(\qarray, 1, numBands, 0.005, 1, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	delays = OceanodeParameterLag.ar(\delayarray, 0, numBands, 0, 2000, "vf", 1/30, true)/1000.0;
	decays = OceanodeParameterLag.ar(\decayarray, 0, numBands, 0, 1, "vf", 1/30, true);
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);

	// Get input signal and store original for mix mix
	input = In.ar(OceanodeInput.kr(\in), n);
	inputStored = input * send;

	// Map decays from 0-1 to 0-inf range using tangent function
	 mappedDecays = tan(decays * pi/2);

	// Get mix mix parameter
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Process each channel individually with the same spectral parameters
	output = Array.fill(n, { |chanNum|
		var chanInput = inputStored[chanNum];
		var chanBands = Array.fill(numBands, { |i|
			// First BPF - single band
			var bpf1 = BPF.ar(chanInput, freqs[i], qs[i]);
			// Second BPF - cascaded for steeper filter
			var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
			// CombC expects: in, maxdelaytime, delaytime, decaytime
			var del = CombC.ar(bpf2, 2, delays[i], mappedDecays[i]);
			del * amps[i]
		});

		// Mix all bands for this channel
		Mix(chanBands) * scaling
	});

	// Apply level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	output = output * levels;

	// Apply mix mix using XFade2
	finalOutput = Array.fill(n, { |i|
		XFade2.ar(input[i], output[i], mix[i].linlin(0, 1, -1, 1))
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "512-band spectral delay with multichannel support", category: "Effect/Spectral");
)