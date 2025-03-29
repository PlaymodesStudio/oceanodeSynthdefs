(
~synthCreator.value("CustomResonator_128", {|n|
	var partials = 128;
	var freqs, decays, amps, input, send, mix, levels;
	var sig;

	// Define parameters
	freqs = OceanodeParameterLag.kr(\freqarray, 220, partials*n, 20, 20000, "vf", 1/30, true);
	decays = OceanodeParameterLag.kr(\decayarray, 0.5, partials*n, 0.01, 10, "vf", 1/30, true);
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials*n, 0, 1, "vf", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Reshape parameter arrays for multichannel processing
	freqs = freqs.reshape(n, partials);
	decays = decays.reshape(n, partials);
	amps = amps.reshape(n, partials);

	// Process each channel individually
	sig = n.collect({ |chan|
		var chanInput = input[chan] * send[chan];
		var processed = Mix.ar(
			Array.fill(partials, { |i|
				Ringz.ar(
					chanInput,
					freqs[chan][i],
					decays[chan][i],
					amps[chan][i]
				)
			})
		) * levels[chan];

		// Apply wet/dry mix
		XFade2.ar(input[chan], processed, mix[chan] * 2 - 1);
	});

	// Output the final signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Resonator effect with 128 tunable resonators applied to input audio",
   category: "Effect/Resonators");
)