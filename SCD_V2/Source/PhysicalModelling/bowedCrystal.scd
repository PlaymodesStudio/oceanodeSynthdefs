(
~synthCreator.value("BowedCrystal", {|n|
	var freq, amp, bowPressure, bowPosition, size, damping, movement;
	var sig, bow, modes, nModes, modeRatios;

	// Main parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 0.83, n, 0, 1, "vf", 1/30, true);

	// Bow control parameters
	bowPressure = OceanodeParameterLag.ar(\bowpressure, 0.5, n, 0, 1, "vf", 1/30, true);
	bowPosition = OceanodeParameterLag.ar(\bowposition, 0.2, n, 0, 1, "vf", 1/30, true);

	// Physical model parameters
	size = OceanodeParameterLag.ar(\size, 1.0, n, 0.1, 2, "vf", 1/30, true);
	damping = OceanodeParameterLag.ar(\damping, 0.3, n, 0, 1, "vf", 1/30, true);
	movement = OceanodeParameterLag.ar(\movement, 1, n, 0, 1, "vf", 1/30, true);

	// Fixed values
	nModes = 6;
	modeRatios = [1, 2.32, 4.25, 6.63, 9.38, 12.22];

	// Generate signals for each channel
	sig = n.collect({ |chan|
		// Bow excitation
		bow = LPF.ar(
			WhiteNoise.ar(0.1) * bowPressure[chan].linexp(0, 1, 0.02, 0.1),
			freq[chan] * 2
		);

		// Frequency movement
		bow = bow * SinOsc.ar(
			freq: freq[chan] * (1 + LFNoise2.kr(1, 0.001)),
			mul: 0.5,
			add: 0.5
		) * movement[chan];

		// Modal resonator bank
		modes = Mix.fill(nModes, {|i|
			var baseFreq = freq[chan] * modeRatios[i];
			var decayTime = size[chan] * (2.0 - (i * 0.1)) * (1 - damping[chan]);
			var posAmp = sin(pi * bowPosition[chan] * (i + 1));
			Ringz.ar(
				bow,
				baseFreq,
				decayTime,
				posAmp * (1.0 - (i * 0.1))
			)
		});

		// Shimmer effect
		modes = modes + DelayC.ar(
			modes,
			0.02,
			LFNoise2.kr(0.1).range(0.01, 0.02)
		) * 0.1;

		// Final channel output with amplitude curve
		modes * amp[chan]
	});

	// Output with limiter
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.95));

}, description: "Bowed crystal physical model with vibrato and shimmer", category: "Source/PhysicalModelling");
)