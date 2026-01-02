(
~synthCreator.value("StoneModel", {|n|
	var gate, freq, levels, strikebow, hardness, complexity, size, damping, brightness, position, resonance, shimmer;
	var exciter, strikeExciter, bowExciter, modes, highModes, chaos, sig;
	var modeRatios, modeAmps, modeDecays, numModes, spread;

	// Control parameters
	gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");
	freq = OceanodeParameter.kr(\pitch, 60, n, 12, 130, "vf").midicps;
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	strikebow = OceanodeParameter.kr(\strikebow, 0, n, 0, 1, "vf");
	hardness = OceanodeParameter.kr(\hardness, 0.7, n, 0, 1, "vf");
	complexity = OceanodeParameter.kr(\complexity, 0.5, n, 0, 1, "vf");
	size = OceanodeParameter.kr(\size, 0.5, n, 0, 1, "vf");
	damping = OceanodeParameter.kr(\damping, 0.7, n, 0, 1, "vf");
	brightness = OceanodeParameter.kr(\brightness, 0.6, n, 0, 1, "vf");
	position = OceanodeParameter.kr(\position, 0.4, n, 0, 1, "vf");
	resonance = OceanodeParameter.kr(\resonance, 0.3, n, 0, 1, "vf");
	shimmer = OceanodeParameter.kr(\shimmer, 0.1, n, 0, 1, "vf");

	// Complexity affects inharmonicity and density
	// Low complexity = polished/concrete (more tonal)
	// High complexity = rough/granular (chaotic)
	spread = complexity.linexp(0, 1, 0.02, 0.4);
	numModes = (8 + (complexity * 12)).round;

	// Generate mode ratios with varying inharmonicity
	modeRatios = Array.fill(20, { |i|
		var base = i + 1;
		var deviation = LFNoise1.kr(0.1 ! n).range(1 - spread, 1 + spread);
		base * deviation
	});

	// Mode amplitudes - more even for chaos, more decay for tonal
	modeAmps = modeRatios.collect({ |ratio, i|
		var posEffect = sin(pi * position * (i + 1)).abs;
		var complexityEffect = complexity.linexp(0, 1, 1 / (i + 1).sqrt, 1 / (i + 1).pow(0.3));
		posEffect * complexityEffect * 0.8
	});

	// Decay times - shorter and more variable for complexity
	modeDecays = modeRatios.collect({ |ratio, i|
		var sizeScale = size.linexp(0, 1, 0.05, 0.3);
		var dampScale = (1 - damping).linexp(0, 1, 0.3, 1);
		var complexityScale = complexity.linlin(0, 1, 1, 0.4);
		var freqDamp = (1 - (i * 0.05)).max(0.1);
		sizeScale * dampScale * complexityScale * freqDamp * (0.5 + (resonance * 1.5))
	});

	// Strike exciter - very sharp, dry impact
	strikeExciter = EnvGen.ar(
		Env.perc(
			0.0001,
			0.001 + (hardness * 0.004) + (complexity * 0.003),
			curve: -8 - (hardness * 4)
		),
		gate: gate > 0
	) * Mix([
		// Sharp transient click
		Impulse.ar(0) * 0.4,
		// High frequency burst
		BPF.ar(
			WhiteNoise.ar(1),
			freq * (4 + (hardness * 8) + (complexity * 4)),
			0.1 + (hardness * 0.2)
		) * 0.6,
		// Dense noise burst for chaos
		Mix.fill(8, {
			BPF.ar(
				WhiteNoise.ar(0.1),
				ExpRand(freq * 0.5, freq * 12),
				ExpRand(0.05, 0.3)
			)
		}) * complexity * 0.4
	]);

	// Bow exciter - friction noise (rubbing stones)
	bowExciter = Mix([
		// Main friction band
		BPF.ar(
			LFNoise1.ar(
				freq * (20 + (hardness * 40) + (complexity * 60)) ! 3
			).sum,
			freq * (2 + (hardness * 2)),
			0.1 + (hardness * 0.2)
		),
		// Granular texture for rough surfaces
		Mix.fill(6, {
			var grainFreq = ExpRand(freq * 0.8, freq * 8);
			BPF.ar(
				Dust.ar(200 + (complexity * 800)),
				grainFreq,
				ExpRand(0.05, 0.2)
			)
		}) * complexity * 0.3,
		// Crackling for very rough contact
		Crackle.ar(1.5 + (complexity * 0.48)) * complexity * 0.2
	] * 0.3) * EnvGen.ar(
		Env.asr(0.01, 1, 0.05),
		gate: gate > 0
	);

	// Crossfade between strike and bow
	exciter = XFade2.ar(strikeExciter, bowExciter, strikebow * 2 - 1);

	// Main modal resonances
	modes = DynKlank.ar(
		`[
			modeRatios.keep(numModes).collect(_ * freq),
			modeAmps.keep(numModes),
			modeDecays.keep(numModes)
		],
		exciter,
		freqscale: 1,
		freqoffset: 0,
		decayscale: 1
	);

	// Higher frequency shimmer/granular content
	highModes = Mix.fill(4, {
		var partialFreq = freq * ExpRand(10, 20);
		var partialAmp = ExpRand(0.01, 0.05);
		SinOsc.ar(partialFreq) * partialAmp
	}) * exciter * shimmer * brightness;

	// Chaotic granular layer for high complexity
	chaos = Mix.fill(12, {
		var grainFreq = ExpRand(freq * 0.5, freq * 16);
		var grainDur = ExpRand(0.003, 0.015);
		var grainEnv = EnvGen.ar(
			Env.perc(0, grainDur, curve: -4),
			gate: Dust.kr(200 * complexity)
		);
		SinOsc.ar(grainFreq) * grainEnv * ExpRand(0.05, 0.15)
	}) * complexity.pow(2) * brightness;

	// Mix components with emphasis on dryness
	sig = Mix([
		modes * (0.5 + (resonance * 0.5)),
		highModes * 0.3,
		chaos * 0.4,
		exciter * 0.2 * hardness  // Keep some attack transient
	]);

	// Filtering - brighter and more open for stone character
	sig = LPF.ar(sig, freq * (12 + (brightness * 24)));
	sig = HPF.ar(sig, freq * (0.3 + (hardness * 0.4)));

	// Very short envelope for dry impact character
	sig = sig * EnvGen.ar(
		Env.asr(
			0.0001,
			1,
			0.01 + (size * 0.1) + (resonance * 0.2) - (damping * 0.15)
		),
		gate: gate > 0,
		doneAction: 2
	);

	// Apply level and limit hard
	sig = Limiter.ar(sig * levels * 1.2, 0.98, 0.001);

	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Physical model of stone percussion and friction from polished to chaotic", category: "Source/PhysicalModeling");
)