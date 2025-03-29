(
~synthCreator.value("CymbalPad", {|n|
	var locut, hicut, hi, lo, level;
	var lodriver, hidriver, freqs, res, sig;

	// Control parameters
	locut = OceanodeParameterLag.ar(\locut, 20000, n, 0, 20000, "vf", 1/30, true);
	hicut = OceanodeParameterLag.ar(\hicut, 10000, n, 0, 20000, "vf", 1/30, true);
	hi = OceanodeParameterLag.ar(\hi, 1, n, 0, 1, "vf", 1/30, true);
	lo = OceanodeParameterLag.ar(\lo, 1, n, 0, 1, "vf", 1/30, true);

	// Output level with proper curve scaling
	level = OceanodeParameterLag.ar(\level, 0.1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Generate noise sources
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locut);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicut);

	// Create resonators (frequencies are fixed per channel but randomized)
	freqs = Array.fill(100, { exprand(300, 20000) });
	res = Ringz.ar((lodriver * lo) + (hidriver * hi), freqs).mean;

	// Final mix
	sig = ((res * 1) + (lodriver * lo * 2)) * level;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Metallic pad synthesizer based on cymbal resonance", category: "Source/PhysicalModelling");
)