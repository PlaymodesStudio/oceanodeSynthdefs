(
~synthCreator.value("BrushedCymbal", {|n|
	var amp, locut, hicut, excitation, time, resolevel, shimmer, resonum, transpose;
	var maxResonators, freqs, lodriver, hidriver, res, sig;

	// Continuous control parameters
	amp = OceanodeParameter.ar(\levels, 0.1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	locut = OceanodeParameter.ar(\locut, 4000, n, 200, 20000, "vf");
	hicut = OceanodeParameter.ar(\hicut, 8000, n, 100, 20000, "vf");
	excitation = OceanodeParameter.ar(\excitation, 0.2, n, 0, 1, "vf");
	time = OceanodeParameter.kr(\time, 1.2, n, 0.1, 10, "vf");
	resolevel = OceanodeParameter.kr(\resolevel, 2.0, n, 0, 5, "vf");
	shimmer = OceanodeParameter.ar(\shimmer, 0.9, n, 0, 1, "vf");
	resonum = OceanodeParameter.ar(\resonum, 200, n, 0, 200, "vf");
	transpose = OceanodeParameter.ar(\transpose, 0, n, -1000, 1000, "vf");

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
	sig = sig * amp.lincurve(0, 1, 0, 1, 4) * 0.1;

	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Brushed cymbal with resonant frequencies and shimmer control", category: "Source/PhysicalModelling");
)