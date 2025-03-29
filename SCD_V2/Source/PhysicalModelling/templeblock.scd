(
~synthCreator.value("TempleBlock", {|n|
	var freq, amp, gate, exciter, modes, sig;
	var nModes, modeRatios, modeFreqs, modeDecays, modeAmps;
	var mode, excite, lpf, input;

	// Mode selector as a dropdown parameter
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Trigger:Drone:Input");

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Additional parameters for drone and input modes
	excite = OceanodeParameter.ar(\excite, 0.2, n, 0, 1, "vf");
	lpf = OceanodeParameter.ar(\lpf, 5000, n, 20, 20000, "vf");

	// Input signal for input-driven mode
	input = In.ar(OceanodeInput.kr(\in), n);

	// Fixed parameters
	nModes = 8;
	modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62];

	// Generate signal for each channel
	sig = n.collect({ |chan|
		var chanFreq = freq[chan];
		var chanModeFreqs = modeRatios * chanFreq;

		// Longer decay times for temple block's hollow resonance
		var chanModeDecays = Array.fill(nModes, {|i|
			0.1 * exp(-0.3 * i)
		});

		// Specific mode amplitudes for temple block character
		var chanModeAmps = [1, 0.7, 0.45, 0.35, 0.25, 0.15, 0.1, 0.05];

		// Different exciter based on mode
		exciter = Select.ar(mode[chan], [
			// Mode 0: Triggered temple block hit
			WhiteNoise.ar() * EnvGen.ar(
				Env.perc(0.0005, 0.01, curve: -4),
				gate: gate[chan]
			) * 0.3,

			// Mode 1: Continuous excitation (drone)
			WhiteNoise.ar() * 0.1 * excite[chan],

			// Mode 2: Input-driven
			input[chan] * 0.2
		]);

		// Modal resonators
		modes = Mix.fill(nModes, {|i|
			Ringz.ar(
				exciter,
				chanModeFreqs[i],
				chanModeDecays[i],
				chanModeAmps[i]
			)
		});

		// Apply overall envelope only for trigger mode
		modes = Select.ar(mode[chan], [
			// Mode 0: Apply envelope
			modes * EnvGen.ar(Env.perc(0.001, 0.2), gate: gate[chan]),

			// Mode 1 & 2: No additional envelope
			modes,
			modes
		]);

		// Low-pass filter and apply amplitude
		LPF.ar(modes * amp[chan].lincurve(0, 1, 0, 1, 4), lpf[chan])
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.9));

}, description: "Physical model of a temple block with inharmonic resonances", category: "Source/PhysicalModelling");
)