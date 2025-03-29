(
~synthCreator.value("Vocoder", {|n, variables|
	var carrier, modulator, output;
	var fftSize = 1024;
	var blend, levels;

	// Get control parameters with appropriate ranges
	blend = OceanodeParameter.ar(\blend, 1, n, 0, 1, "vf");
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Get input signals from OceanodeInput
	carrier = In.ar(OceanodeInput.kr(\carrier), n);
	modulator = In.ar(OceanodeInput.kr(\modulator), n);

	// Process efficiently using multichannel expansion
	// By keeping the carrier/modulator as arrays rather than iterating through each channel
	carrier = carrier.asArray;
	modulator = modulator.asArray;

	// Create buffer per channel but avoid using collect on the whole process
	carrier = carrier.collect({ |chan| FFT(LocalBuf(fftSize), chan) });
	modulator = modulator.collect({ |chan| FFT(LocalBuf(fftSize), chan) });

	// Using zip to pair corresponding FFT chains
	output = [carrier, modulator].flop.collect { |pair|
		var c = pair[0];
		var m = pair[1];

		// Use pvcalc2 as requested, but directly on the channel pairs
		IFFT(c.pvcalc2(m, fftSize, { |mag1, phase1, mag2, phase2|
			// Blend between carrier and modulator magnitudes
			[mag1 * blend + mag2 * (1 - blend), phase2]
		}));
	};

	// Apply levels and output
	output = output * levels;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "FFT vocoder with adjustable carrier and modulator blend", category: "Effects/Spectral")
)