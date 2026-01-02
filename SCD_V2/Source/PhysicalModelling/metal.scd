(
~synthCreator.value("MetalPercussion", {|n|
	var sig, exciter, modes, exmode, input;
	var numModes = 60;

	// Main parameters with lag for smooth transitions
	var fundamental = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	var strike = OceanodeParameter.ar(\strike, 0.05, n, 0, 1, "vf");
	var hardness = OceanodeParameter.ar(\hardness, 0.15, n, 0, 1, "vf");
	var harmony = OceanodeParameter.ar(\harmony, 0.0, n, 0, 2, "vf");
	var t60 = OceanodeParameter.ar(\decay, 2.0, n, 0, 10, "vf");
	var bright = OceanodeParameter.ar(\bright, 0.90, n, 0, 1, "vf");
	var damp = OceanodeParameter.ar(\damp, 0.1, n, 0, 1, "vf");
	var amp = OceanodeParameter.ar(\levels, 0.05, n, 0, 1, "vf");
	var gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	var maxFreq = OceanodeParameter.ar(\maxfreq, 12000, n, 100, 20000, "vf");

	// Excitation mode selector as dropdown
	exmode = OceanodeParameterDropdown.kr(\exmode, 0, n, "Internal:External");

	// Input for external excitation
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate per-channel signals
	sig = n.collect({ |chan|
		var chanModes, chanExciter, modeFreqs, modeAmps, modeDecays;
		var trig = gate[chan];  // Use gate directly for triggering

		// Generate new frequencies when triggered
		modeFreqs = Array.fill(numModes, { |i|
			var harmonicFreq = fundamental[chan] * (i + 1);
			var spreadFactor = i * harmony[chan] * 0.02;
			var inharmonicity = harmony[chan] * TRand.kr(1.0, 1.2, trig); // Use TRand for triggerable random
			var rawFreq = harmonicFreq * (1 + (spreadFactor * inharmonicity));
			min(rawFreq, maxFreq[chan])
		});

		// Amplitude distribution for this channel
		modeAmps = Array.fill(numModes, { |i|
			var harmonic = i + 1;
			var pos = strike[chan] * pi * harmonic;
			sin(pos) * (harmonic ** bright[chan].neg)
		});

		// Decay times for this channel
		modeDecays = Array.fill(numModes, { |i|
			var freq = modeFreqs[i];
			var freqScale = (1 / (freq ** 0.5));
			t60[chan] * freqScale * (1 - (damp[chan] * (i / numModes))) * 0.4
		});

		// Select excitation source based on mode
		chanExciter = Select.ar(exmode[chan], [
			// Internal exciter - triggered noise burst
			EnvGen.ar(
				Env.perc(0.001, hardness[chan].linexp(0, 1, 0.001, 0.05)),
				trig
			) * WhiteNoise.ar,

			// External input with envelope
			input[chan]
		]);

		// Resonator bank for this channel
		chanModes = DynKlank.ar(`[
			modeFreqs,
			modeAmps,
			modeDecays
		], chanExciter);

		// Output envelope for this channel
		chanModes * EnvGen.ar(
			Env.perc(0.001, t60[chan] * 1.5, 1, -4),
			trig,
			amp[chan]
		)
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Metal percussion with harmonicity inharmonicity and decay control", category: "Source/PhysicalModelling");
)