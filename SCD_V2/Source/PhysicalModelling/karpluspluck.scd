(
~synthCreator.value("KarplusPluck", {|n|
	var trig, sustain, dur, amp, freq, accent, brightness, damping, env, sig;

	// Main parameters with lag for smooth transitions
	trig = OceanodeParameter.ar(\trig, 0, n, 0, 1, "vi");
	sustain = OceanodeParameter.ar(\sustain, 1, n, 0, 1, "vf");
	dur = OceanodeParameterLag.ar(\pulsedur, 0.01, n, 0, 1, "vf", 1/30, true);
	amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;

	// String physics parameters
	accent = OceanodeParameterLag.ar(\accent, 0.75, n, 0, 1, "vf", 1/30, true);
	brightness = OceanodeParameterLag.ar(\brightness, 0.15, n, 0, 1, "vf", 1/30, true);
	damping = OceanodeParameterLag.ar(\damping, 0.25, n, 0, 1, "vf", 1/30, true);

	// Generate envelope and string sound for each channel
	sig = n.collect({ |chan|
		env = Env.perc.kr(gate: trig[chan], timeScale: dur[chan]);
		StringVoice.ar(
			env,
			structure: 0.5,
			infsustain: sustain[chan],
			freq: freq[chan],
			accent: accent[chan],
			brightness: brightness[chan],
			damping: damping[chan]
		) * amp[chan].lincurve(0, 1, 0, 1, 4)
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Plucked string physical model with adjustable physics parameters", category: "Source/PhysicalModelling");
)