(
~synthCreator.value("Handpan", {|n|
	var freq, amp, strikePos, strikeCurve, coupling, damping, stiffness, brightness, decayTime, gate;
	var exciter, modes, highModes, coupledModes, sig;
	var nModes = 6;
	var nHighModes = 4;
	var modeRatios = [1, 2.0, 2.83, 3.91, 4.95, 6.12];
	var highRatios = [8.23, 9.87, 11.54, 13.21];

	// Parameters with proper ranges
	gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");
	freq = OceanodeParameter.kr(\pitch, 60, n, 0, 130, "vf").midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	strikePos = OceanodeParameter.kr(\strikepos, 0.3, n, 0, 1, "vf");
	strikeCurve = OceanodeParameter.kr(\strikecurve, 0.7, n, 0, 1, "vf");
	coupling = OceanodeParameter.kr(\coupling, 0.3, n, 0, 1, "vf");
	damping = OceanodeParameter.kr(\damping, 0.2, n, 0, 1, "vf");
	stiffness = OceanodeParameter.kr(\stiffness, 0.7, n, 0, 1, "vf");
	brightness = OceanodeParameter.kr(\brightness, 0.7, n, 0, 5, "vf");
	decayTime = OceanodeParameter.kr(\decaytime, 3.4, n, 0.1, 10, "vf");

	// Using multichannel expansion instead of array indexing
	// Excitation signal - using gate > 0 for triggering
	exciter = Mix([
		EnvGen.ar(
			Env.perc(0.0005, 0.01),
			gate: gate > 0,
			levelScale: 0.5
		) * Mix([
			BPF.ar(WhiteNoise.ar(0.2), freq * 2, 0.5),
			HPF.ar(WhiteNoise.ar(0.1), 5000) * brightness
		]),
		EnvGen.ar(
			Env.perc(0.001, 0.02),
			gate: gate > 0,
			levelScale: 0.3
		) * SinOsc.ar(freq)
	]);

	// Let SuperCollider handle multichannel expansion for modes
	modes = Mix.new(
		DynKlank.ar(
			// For each modeRatio (1, 2.0, etc), create specs
			`[
				[
					freq * modeRatios[0] * (1 + (stiffness * 0 * 0.005)),
					freq * modeRatios[0] * (1 + (stiffness * 0 * 0.005 * 1.1)),
					freq * modeRatios[1] * (1 + (stiffness * 1 * 0.005)),
					freq * modeRatios[1] * (1 + (stiffness * 1 * 0.005 * 1.1)),
					freq * modeRatios[2] * (1 + (stiffness * 2 * 0.005)),
					freq * modeRatios[2] * (1 + (stiffness * 2 * 0.005 * 1.1)),
					freq * modeRatios[3] * (1 + (stiffness * 3 * 0.005)),
					freq * modeRatios[3] * (1 + (stiffness * 3 * 0.005 * 1.1)),
					freq * modeRatios[4] * (1 + (stiffness * 4 * 0.005)),
					freq * modeRatios[4] * (1 + (stiffness * 4 * 0.005 * 1.1)),
					freq * modeRatios[5] * (1 + (stiffness * 5 * 0.005)),
					freq * modeRatios[5] * (1 + (stiffness * 5 * 0.005 * 1.1))
				],
				[
					sin(pi * strikePos * (0 + 1)) * 0.3,
					sin(pi * strikePos * (0 + 1)) * 0.15,
					sin(pi * strikePos * (1 + 1)) * 0.3,
					sin(pi * strikePos * (1 + 1)) * 0.15,
					sin(pi * strikePos * (2 + 1)) * 0.3,
					sin(pi * strikePos * (2 + 1)) * 0.15,
					sin(pi * strikePos * (3 + 1)) * 0.3,
					sin(pi * strikePos * (3 + 1)) * 0.15,
					sin(pi * strikePos * (4 + 1)) * 0.3,
					sin(pi * strikePos * (4 + 1)) * 0.15,
					sin(pi * strikePos * (5 + 1)) * 0.3,
					sin(pi * strikePos * (5 + 1)) * 0.15
				],
				[
					decayTime * (1 - damping) * exp(-0.3 * 0),
					decayTime * (1 - damping) * exp(-0.3 * 0) * 0.8,
					decayTime * (1 - damping) * exp(-0.3 * 1),
					decayTime * (1 - damping) * exp(-0.3 * 1) * 0.8,
					decayTime * (1 - damping) * exp(-0.3 * 2),
					decayTime * (1 - damping) * exp(-0.3 * 2) * 0.8,
					decayTime * (1 - damping) * exp(-0.3 * 3),
					decayTime * (1 - damping) * exp(-0.3 * 3) * 0.8,
					decayTime * (1 - damping) * exp(-0.3 * 4),
					decayTime * (1 - damping) * exp(-0.3 * 4) * 0.8,
					decayTime * (1 - damping) * exp(-0.3 * 5),
					decayTime * (1 - damping) * exp(-0.3 * 5) * 0.8
				]
			],
			exciter
		) * 0.2
	);

	// Higher modes using frequency expansion
	highModes = Mix.new(
		DynKlank.ar(
			`[
				[
					freq * highRatios[0],
					freq * highRatios[0] * 1.001,
					freq * highRatios[1],
					freq * highRatios[1] * 1.001,
					freq * highRatios[2],
					freq * highRatios[2] * 1.001,
					freq * highRatios[3],
					freq * highRatios[3] * 1.001
				],
				[
					sin(pi * strikePos * (0 + 7)) * brightness * 0.1,
					sin(pi * strikePos * (0 + 7)) * brightness * 0.05,
					sin(pi * strikePos * (1 + 7)) * brightness * 0.1,
					sin(pi * strikePos * (1 + 7)) * brightness * 0.05,
					sin(pi * strikePos * (2 + 7)) * brightness * 0.1,
					sin(pi * strikePos * (2 + 7)) * brightness * 0.05,
					sin(pi * strikePos * (3 + 7)) * brightness * 0.1,
					sin(pi * strikePos * (3 + 7)) * brightness * 0.05
				],
				[
					decayTime * 0.5 * exp(-0.2 * 0) * 0.3,
					decayTime * 0.5 * exp(-0.2 * 0) * 0.2,
					decayTime * 0.5 * exp(-0.2 * 1) * 0.3,
					decayTime * 0.5 * exp(-0.2 * 1) * 0.2,
					decayTime * 0.5 * exp(-0.2 * 2) * 0.3,
					decayTime * 0.5 * exp(-0.2 * 2) * 0.2,
					decayTime * 0.5 * exp(-0.2 * 3) * 0.3,
					decayTime * 0.5 * exp(-0.2 * 3) * 0.2
				]
			],
			exciter
		) * 0.15
	);

	// Coupled modes for resonance between tones
	coupledModes = Mix.new(
		DynKlank.ar(
			`[
				[freq * 1.5, freq * 2],
				[coupling * 0.1 * (1 - (0 * 0.3)), coupling * 0.1 * (1 - (1 * 0.3))],
				[decayTime * (1 - damping) * 0.3, decayTime * (1 - damping) * 0.3]
			],
			modes
		)
	);

	// Mix all components
	sig = Mix([
		modes,
		highModes * brightness,
		coupledModes * coupling * 0.3
	]);

	// Add subtle distortion
	sig = sig + (sig.abs * sig * 0.02);

	// Apply EQ
	sig = BPeakEQ.ar(sig, freq * 2.5, 0.7, 2);
	sig = BHiShelf.ar(sig, 5000, 1, brightness * 6);

	// Apply amplitude envelope
	sig = sig * EnvGen.ar(
		Env.new(
			levels: [0, 1, 0],
			times: [0.001, decayTime],
			curve: [-4, -4]
		),
		gate: gate > 0
	);

	// Add reverb
	sig = FreeVerb.ar(sig, 0.15, 0.6, 0.1);

	// Apply amplitude and sanitize
	sig = Sanitize.ar(Limiter.ar(sig * amp, 0.95));

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Physical model of a handpan with adjustable tone and resonance characteristics", category: "Source/PhysicalModelling");
)