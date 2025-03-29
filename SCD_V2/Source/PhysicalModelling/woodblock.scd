(
~synthCreator.value("WoodBlock", {|n|
	var freq, amp, strikePos, hardness, thickness, hollow, decay, bright, gate, sig;
	var nModes, modeRatios;
	var mode, excite, lpf, input;

	// Mode selector as a dropdown parameter
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Trigger:Drone:Input");

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 48, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	strikePos = OceanodeParameter.ar(\strikepos, 0.93, n, 0.1, 0.99, "vf");
	hardness = OceanodeParameter.ar(\hardness, 0.027, n, 0.001, 0.1, "vf");
	thickness = OceanodeParameter.ar(\thickness, 0.95, n, 0, 1, "vf");
	hollow = OceanodeParameter.ar(\hollow, 0.97, n, 0, 1, "vf");
	decay = OceanodeParameter.ar(\decay, 1, n, 0.1, 5, "vf");
	bright = OceanodeParameter.ar(\bright, 0.95, n, 0, 1, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Additional parameters for drone and input modes
	excite = OceanodeParameter.ar(\excite, 0.2, n, 0, 1, "vf");
	lpf = OceanodeParameter.ar(\lpf, 5000, n, 20, 20000, "vf");

	// Input signal for input-driven mode
	input = In.ar(OceanodeInput.kr(\in), n);

	// Fixed parameters
	nModes = 12;
	modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62, 6.15, 7.23, 8.17, 9.32];

	// Generate per-channel signals
	sig = n.collect({ |chan|
		var exciter, modes;
		var chanFreq = freq[chan];

		// Per-channel mode frequencies
		var modeFreqs = modeRatios.collect({ |ratio, i|
			chanFreq * ratio * (1 + (thickness[chan] * 0.1 * i))
		});

		// Per-channel decay times
		var modeDecays = Array.fill(nModes, {|i|
			var baseDecay = decay[chan] * (0.1 * exp(-0.25 * i));
			var hollowFactor = hollow[chan].linexp(0, 1, 1, 3);
			baseDecay * hollowFactor
		});

		// Per-channel amplitudes
		var modeAmps = Array.fill(nModes, {|i|
			var posAmp = sin(pi * (i + 1) * strikePos[chan]);
			var brightAmp = bright[chan].linexp(0, 1, 0.4, 1.5);
			posAmp * (brightAmp ** (-1 * i/4))
		});

		// Different exciter based on mode
		exciter = Select.ar(mode[chan], [
			// Mode 0: Triggered woodblock hit
			Mix([
				EnvGen.ar(
					Env.perc(0.0001, 0.001, curve: -8),
					levelScale: hardness[chan],
					gate: gate[chan]
				) * WhiteNoise.ar,

				EnvGen.ar(
					Env.perc(0.0005, 0.01, curve: -4),
					levelScale: (1 - hardness[chan]),
					gate: gate[chan]
				) * BPF.ar(WhiteNoise.ar, chanFreq * 2, 0.5),

				EnvGen.ar(
					Env.perc(0.0003, 0.003, curve: -6),
					levelScale: hardness[chan] * 0.3,
					gate: gate[chan]
				) * HPF.ar(BrownNoise.ar, 5000)
			]),

			// Mode 1: Continuous excitation (drone)
			Mix([
				WhiteNoise.ar * 0.1 * hardness[chan],
				BPF.ar(WhiteNoise.ar, chanFreq * 2, 0.5) * 0.2 * (1 - hardness[chan]),
				HPF.ar(BrownNoise.ar, 5000) * 0.05 * hardness[chan]
			]) * excite[chan],

			// Mode 2: Input-driven
			input[chan] * 0.2
		]);

		// Exciter shaping for triggered and drone modes
		exciter = Select.ar(mode[chan] < 2, [
			exciter, // Pass through for input mode
			(exciter * (1 + (exciter * hardness[chan]))).clip2(1) // Process for trigger and drone modes
		]);

		// Modal resonator bank
		modes = Mix.fill(nModes, {|i|
			var mode = Ringz.ar(
				exciter,
				modeFreqs[i] * LFNoise1.kr(10, 0.001, 1),
				modeDecays[i],
				modeAmps[i]
			);

			mode + (
				Ringz.ar(
					mode,
					modeFreqs.wrapAt(i+1),
					modeDecays[i] * 0.5
				) * 0.05
			)
		});

		// Processing
		modes = modes * (1 + (modes * 0.1 * hollow[chan])).clip2(1);

		// Apply envelope only for trigger mode
		modes = Select.ar(mode[chan], [
			// Mode 0: Apply envelope
			modes * EnvGen.ar(
				Env.perc(0.001, 0.2 * decay[chan], 1, -4),
				gate: gate[chan]
			),

			// Mode 1 & 2: No additional envelope
			modes,
			modes
		]);

		// Low-pass filter and apply amplitude
		LPF.ar(modes * amp[chan].lincurve(0, 1, 0, 1, 4), lpf[chan])
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.9));
}, description: "Physical model of a woodblock with adjustable material properties", category: "Source/PhysicalModelling");
)