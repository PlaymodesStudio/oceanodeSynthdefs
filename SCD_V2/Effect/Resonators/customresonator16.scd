(
~synthCreator.value("CustomResonator_16_", {|n|
	var partials = 16;
	var pitch, ratios, decays, amps, input, send, mix, levels;
	var sig;

	// Define the fundamental pitch for each channel
	pitch = OceanodeParameterLag.ar(\pitch, 60, n, 24, 96, "vf", 1/30, true).midicps;

	// Define ratios, decays, and amps (only need 128 values total, not per channel)
	ratios = OceanodeParameterLag.ar(\ratioarray, 1.0, partials, 0.01, 20, "vf", 1/30, true);
	decays = OceanodeParameterLag.kr(\decayarray, 0.5, partials, 0.01, 10, "vf", 1/30, true);
	amps = OceanodeParameterLag.ar(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Apply send to input
	input = input * send;

	// Process each channel individually - use the same ratios but different base pitch
	sig = n.collect({ |chan|
		var chanInput = input[chan];
		var chanFreqs = ratios * pitch[chan]; // Calculate frequencies as ratios of pitch

		var processed = Mix.ar(
			Array.fill(partials, { |i|
				Ringz.ar(
					chanInput,
					chanFreqs[i],
					decays[i],
					amps[i]
				)
			})
		) * levels[chan];

		// Apply wet/dry mix
		XFade2.ar(input[chan], processed, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Resonator effect with 16 tunable resonance ratios applied to input audio",
   category: "Effect/Resonators");
)