(
~synthCreator.value("JunkPerc", {|n|
	var curv, dev, rndms, attack, decay, snd, freqs, ratio, velocity, trigger;
	var ratioHash1, ratioHash2, curveEnv;

	// Main parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	velocity = OceanodeParameter.ar(\velocity, 1, n, 0, 10, "vf");
	ratio = OceanodeParameter.ar(\ratio, 1, n, 0, 10, "vf");
	freqs = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;

	// Sound shaping parameters
	dev = OceanodeParameter.ar(\pdevratio, 1, n, 0, 4, "vf");
	decay = OceanodeParameter.ar(\decay, 1, n, 0, 100, "vf");
	attack = OceanodeParameter.ar(\attack, 1, n, 0, 10000, "vf");
	curv = OceanodeParameter.kr(\curve, -4, n, -10, 10, "vf");

	// Generate signals for each channel
	snd = n.collect({ |chan|
		// Generate random variations for each frequency component
		rndms = [
			TRand.kr(1, dev[chan], trigger[chan]),
			TRand.kr(1, dev[chan], trigger[chan]),
			TRand.kr(1, dev[chan], trigger[chan]),
			TRand.kr(1, dev[chan], trigger[chan])
		];

		// Base oscillators with modulated frequencies
		snd = SinOsc.ar((freqs[chan] * rndms) * ratio[chan]);

		// Apply initial envelope
		snd = snd * EnvGen.kr(
			Env.perc(
				0.001 * attack[chan],
				([0.1, 0.03, 0.04, 0.08] * 6 / ratio[chan].squared) * decay[chan],
				curve: curv[chan]
			),
			trigger[chan]
		);

		// Balance the components with random levels
		snd = snd * ({ Rand(0, -7) } ! snd.size).dbamp;
		snd = snd.sum;
		snd = snd * -6.dbamp;

		// Add modulation for more texture
		ratioHash1 = Hasher.kr(ratio[chan]).linexp(-1, 1, 1000, 4000);
		snd = snd * (1 + (SinOsc.ar(ratioHash1) *
			EnvGen.kr(Env.perc(0.001 * attack[chan], 0.3 * decay[chan], curve: curv[chan]), trigger[chan]) *
			velocity[chan]));

		// Add noise component
		snd = snd + (BPF.ar(WhiteNoise.ar, 1320 * ratio[chan], 0.1) *
			EnvGen.kr(Env.perc(0.003 * attack[chan], 0.03 * decay[chan], curve: curv[chan]), trigger[chan]) *
			3.dbamp);

		// Complex envelope for timbral variation
		curveEnv = EnvGen.kr(
			Env([0, 1, 0.6, 0.9, Rand(0.1, 0.9), 1, 0],
				[0.001 * attack[chan], 0.003 * Rand(1, 2), 0.001 * Rand(1, 2),
				0.01 * Rand(0.3, 1), 0.001, 1 * decay[chan]], -4),
			trigger[chan]);
		snd = snd * curveEnv;

		// Add transient emphasis
		snd = snd * (1 + (EnvGen.kr(
			Env.perc(0.001 * attack[chan], 0.03 * decay[chan], curve: curv[chan]),
			trigger[chan]) * 5));

		// Apply velocity scaling and random gain
		snd = snd * velocity[chan].sqrt;
		snd = snd * Rand(1, 5);

		// Soft clipping
		snd = snd.tanh;

		// Add pitch shifted versions for more complexity
		ratioHash2 = Hasher.kr(ratio[chan] + 1.3).linexp(0, 1, 1, 2);
		snd = snd + PitchShift.ar(snd, 0.07, ratioHash2);
		snd = snd + PitchShift.ar(snd * -6.dbamp, 0.06, 0.7);

		// Add resonance with comb filters
		snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio[chan] + 1) * 10).midiratio / 100, 0.1);
		snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio[chan] + 1) * 20).midiratio / 100, 0.03);

		// Overall amplitude envelope
		snd = snd * EnvGen.kr(
			Env.perc(
				velocity[chan].linlin(0, 1, 0.01, 0.001) * attack[chan],
				1 * decay[chan],
				curve: curv[chan]
			),
			trigger[chan]
		);

		// Final level adjustment and limiting
		snd = snd * -8.dbamp;
		Limiter.ar(snd * velocity[chan].lincurve(0, 1, 0, 1, 4));
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), snd);

}, description: "Complex percussive sounds with tunable randomness and transient behavior", category: "Source/PhysicalModelling");
)