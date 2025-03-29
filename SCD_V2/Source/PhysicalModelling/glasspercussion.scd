//afegir input exciter

(
~synthCreator.value("GlassPercussion", {|n|
	var freq, amp, pos, size, damping, gate, sig;
	var exciter, modes, nModes, modeRatios, baseDecay;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameter.ar(\pos, 0.3, n, 0, 1, "vf");
	size = OceanodeParameter.ar(\size, 1.0, n, 0.1, 2, "vf");
	damping = OceanodeParameter.ar(\damping, 0.5, n, 0, 1, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Fixed values
	nModes = 6;
	modeRatios = [1, 2.32, 4.25, 6.63, 9.38, 12.22];

	// Generate signals for each channel
	sig = n.collect({ |chan|
		// Calculate decay time based on size and damping
		baseDecay = 3.0 * size[chan] * (1 - damping[chan]);

		// Filtered noise burst for strike
		exciter = EnvGen.ar(
			Env.perc(0.0001, 0.001),
			gate: gate[chan]
		) * HPF.ar(WhiteNoise.ar, 3000);

		// Modal synthesis
		modes = Mix.fill(nModes, {|i|
			var decay = baseDecay * exp(-0.5 * i);
			var modalAmp = exp(-0.5 * i) * sin(pi * pos[chan] * (i + 1));
			Ringz.ar(
				exciter,
				freq[chan] * modeRatios[i],
				decay,
				modalAmp
			)
		});

		// Envelope and output
		modes * amp[chan].lincurve(0, 1, 0, 1, 4) * EnvGen.kr(
			Env.perc(0.001, baseDecay),
			gate: gate[chan],
			doneAction: 0
		)
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Glass percussion physical model with strike position and damping", category: "Source/PhysicalModelling");
)