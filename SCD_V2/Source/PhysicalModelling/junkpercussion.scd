(
~synthCreator.value("JunkPerc", {|n|
	var curv, dev, rndms, attack, decay, snd, freqs, ratio, velocity, trigger, levels;
	var ratioHash1, ratioHash2, curveEnv;

	// Main parameters - same as before
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	velocity = OceanodeParameter.ar(\velocity, 1, n, 0, 10, "vf");
	ratio = OceanodeParameter.ar(\ratio, 1, n, 0, 10, "vf");
	freqs = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true);

	// Sound shaping parameters - same as before
	dev = OceanodeParameter.ar(\pdevratio, 1, n, 0, 4, "vf");
	decay = OceanodeParameter.ar(\decay, 1, n, 0, 100, "vf");
	attack = OceanodeParameter.ar(\attack, 1, n, 0, 10000, "vf");
	curv = OceanodeParameter.kr(\curve, -4, n, -10, 10, "vf");

	// Generate signals for each channel
	snd = n.collect({ |chan|
		// The key fix: use Schmidt trigger to detect audio-rate triggers reliably
		// Threshold the input to ensure it triggers on any positive value
		var triggerPulse = Schmidt.ar(trigger[chan], 0.0001, 0.0001);
		// Convert to trigger with Trig for better triggering
		var cleanTrigger = Trig.ar(triggerPulse, SampleDur.ir * 2);

		// Generate random variations for each frequency component
		// Use triggerPulse for TRand triggers to ensure proper randomization
		rndms = [
			TRand.ar(1, dev[chan], cleanTrigger),
			TRand.ar(1, dev[chan], cleanTrigger),
			TRand.ar(1, dev[chan], cleanTrigger),
			TRand.ar(1, dev[chan], cleanTrigger)
		];

		// Base oscillators with modulated frequencies - same as before
		snd = SinOsc.ar((freqs[chan] * rndms) * ratio[chan]);

		// Apply initial envelope - use cleanTrigger for all envelope generators
		snd = snd * EnvGen.ar(
			Env.perc(
				0.001 * attack[chan],
				([0.1, 0.03, 0.04, 0.08] * 6 / ratio[chan].squared) * decay[chan],
				curve: curv[chan]
			),
			cleanTrigger
		);

		// Balance the components with random levels - same as before
		snd = snd * ({ Rand(0, -7) } ! snd.size).dbamp;
		snd = snd.sum;
		snd = snd * -6.dbamp;

		// Add modulation for more texture - use cleanTrigger for EnvGen
		ratioHash1 = Hasher.kr(ratio[chan]).linexp(-1, 1, 1000, 4000);
		snd = snd * (1 + (SinOsc.ar(ratioHash1) *
			EnvGen.ar(Env.perc(0.001 * attack[chan], 0.3 * decay[chan], curve: curv[chan]), cleanTrigger) *
			velocity[chan]));

		// Add noise component - use cleanTrigger for EnvGen
		snd = snd + (BPF.ar(WhiteNoise.ar, 1320 * ratio[chan], 0.1) *
			EnvGen.ar(Env.perc(0.003 * attack[chan], 0.03 * decay[chan], curve: curv[chan]), cleanTrigger) *
			3.dbamp);

		// Complex envelope for timbral variation - use cleanTrigger for EnvGen
		curveEnv = EnvGen.ar(
			Env([0, 1, 0.6, 0.9, Rand(0.1, 0.9), 1, 0],
				[0.001 * attack[chan], 0.003 * Rand(1, 2), 0.001 * Rand(1, 2),
				0.01 * Rand(0.3, 1), 0.001, 1 * decay[chan]], -4),
			cleanTrigger);
		snd = snd * curveEnv;

		// Add transient emphasis - use cleanTrigger for EnvGen
		snd = snd * (1 + (EnvGen.ar(
			Env.perc(0.001 * attack[chan], 0.03 * decay[chan], curve: curv[chan]),
			cleanTrigger) * 5));

		// Rest of the processing same as before
		snd = snd * velocity[chan].sqrt;
		snd = snd * Rand(1, 5);
		snd = snd.tanh;

		ratioHash2 = Hasher.kr(ratio[chan] + 1.3).linexp(0, 1, 1, 2);
		snd = snd + PitchShift.ar(snd, 0.07, ratioHash2);
		snd = snd + PitchShift.ar(snd * -6.dbamp, 0.06, 0.7);

		snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio[chan] + 1) * 10).midiratio / 100, 0.1);
		snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio[chan] + 1) * 20).midiratio / 100, 0.03);

		// Overall amplitude envelope - use cleanTrigger for EnvGen
		snd = snd * EnvGen.ar(
			Env.perc(
				velocity[chan].linlin(0, 1, 0.01, 0.001) * attack[chan],
				1 * decay[chan],
				curve: curv[chan]
			),
			cleanTrigger
		);

		// Final level adjustment and limiting - same as before
		snd = snd * -8.dbamp;
		Limiter.ar(snd * levels[chan]);
	});

	// Output the signal - same as before
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Complex percussive sounds with tunable randomness and transient behavior", category: "Source/PhysicalModelling");
)