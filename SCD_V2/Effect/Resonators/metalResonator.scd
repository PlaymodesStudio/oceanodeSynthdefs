(
~synthCreator.value("MetalResonator", {|n|
	var sig, input, modes;
	var numModes = 60;

	// Main parameters with lag for smooth transitions
	var fundamental = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	var harmony = OceanodeParameter.ar(\harmony, 0.0, n, 0, 2, "vf");
	var t60 = OceanodeParameter.ar(\decay, 2.0, n, 0, 10, "vf");
	var bright = OceanodeParameter.ar(\bright, 0.90, n, 0, 1, "vf");
	var damp = OceanodeParameter.ar(\damp, 0.1, n, 0, 1, "vf");
	var amp = OceanodeParameter.ar(\amp, 0.05, n, 0, 1, "vf");
	var maxFreq = OceanodeParameter.ar(\maxfreq, 12000, n, 100, 20000, "vf");
	var mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	var send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input for excitation
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate per-channel signals
	sig = n.collect({ |chan|
		var chanModes, modeFreqs, modeAmps, modeDecays;
		var chanInput = input[chan] * send[chan];

		// Generate frequencies
		modeFreqs = Array.fill(numModes, { |i|
			var harmonicFreq = fundamental[chan] * (i + 1);
			var spreadFactor = i * harmony[chan] * 0.02;
			var inharmonicity = harmony[chan] * (1.0 + (0.2.rand)); // Random inharmonicity factor
			var rawFreq = harmonicFreq * (1 + (spreadFactor * inharmonicity));
			min(rawFreq, maxFreq[chan])
		});

		// Amplitude distribution for this channel
		modeAmps = Array.fill(numModes, { |i|
			var harmonic = i + 1;
			var pos = 0.05 * pi * harmonic; // Fixed strike position
			sin(pos) * (harmonic ** bright[chan].neg)
		});

		// Decay times for this channel
		modeDecays = Array.fill(numModes, { |i|
			var freq = modeFreqs[i];
			var freqScale = (1 / (freq ** 0.5));
			t60[chan] * freqScale * (1 - (damp[chan] * (i / numModes))) * 0.4
		});

		// Resonator bank for this channel
		chanModes = DynKlank.ar(`[
			modeFreqs,
			modeAmps,
			modeDecays
		], chanInput);

		// Mix dry and wet signals
		XFade2.ar(input[chan], chanModes * amp[chan].lincurve(0, 1, 0, 1, 4), mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Metal resonator effect that applies metallic modal resonance to input audio", category: "Effect/Resonators");
)