(
~synthCreator.value("BrushedCymbal", {|n|
	var amp, locut, hicut, excitation, time, resolevel, shimmer, resonum, transpose;
	var maxResonators, freqs, lodriver, hidriver, res, sig;

	// Continuous control parameters
	amp = OceanodeParameterLag.ar(\levels, 0.1, n, 0, 1, "vf", 1/30, true);
	locut = OceanodeParameterLag.ar(\locut, 4000, n, 200, 20000, "vf", 1/30, true);
	hicut = OceanodeParameterLag.ar(\hicut, 8000, n, 100, 20000, "vf", 1/30, true);
	excitation = OceanodeParameterLag.ar(\excitation, 0.2, n, 0, 1, "vf", 1/30, true);
	time = OceanodeParameterLag.kr(\time, 1.2, n, 0.1, 10, "vf", 1/30, true);
	resolevel = OceanodeParameterLag.kr(\resolevel, 2.0, n, 0, 5, "vf", 1/30, true);
	shimmer = OceanodeParameterLag.ar(\shimmer, 0.9, n, 0, 1, "vf", 1/30, true);
	resonum = OceanodeParameterLag.ar(\resonum, 200, n, 0, 200, "vf", 1/30, true);
	transpose = OceanodeParameterLag.ar(\transpose, 0, n, -1000, 1000, "vf", 1/30, true);

	maxResonators = (200/n).asInteger;  // Fixed maximum

	// Generate base frequencies with transpose
	freqs = {exprand(300, 20000)}.dup(maxResonators) + transpose;

	// Noise drivers with cutoffs
	lodriver = LPF.ar(
		WhiteNoise.ar(0.1),
		excitation.lag(0.05).linexp(0, 1, 200, locut)
	);

	hidriver = HPF.ar(
		WhiteNoise.ar(0.05),
		excitation.lag(0.05).linexp(0, 1, hicut, 2000)
	);

	// Resonators with variable active count and shimmer
	res = Ringz.ar(
		(lodriver + hidriver) * excitation.lag(0.05),
		freqs * Array.fill(maxResonators, { |i|
			1 + (shimmer * (i/maxResonators - 0.5))
		}),
		time
	);

	// Sum only active resonators
	sig = Mix.fill(maxResonators, { |i|
		res[i] * (i < resonum).asInteger
	}) * resolevel;

	// Add high frequency emphasis based on shimmer
	sig = sig + HPF.ar(
		sig * shimmer,
		10000
	);

	// Apply amplitude curve for natural level control
	sig = sig * amp * 0.1;

	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Brushed cymbal with resonant frequencies and shimmer control", category: "Source/PhysicalModelling");
)