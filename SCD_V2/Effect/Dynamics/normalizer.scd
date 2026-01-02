(
~synthCreator.value("Normalizer", {|n|
	var input, level, dur, dry, wet, mix, output;

	// Get input
	input = In.ar(OceanodeInput.kr(\in), n);

	// Normalization level (0..1, default 1.0)
	level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);

	// Duration / lookahead time (in seconds, 0.01 to 0.1 typical range)
	dur = OceanodeParameterLag.ar(\dur, 0.01, n, 0.001, 0.1, "vf", 1/30, true);

	// Mix control (0 = dry, 1 = wet)
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Dry and wet signals
	dry = input;
	wet = Normalizer.ar(input, level, dur);

	// Equal-power crossfade between dry and wet
	output = XFade2.ar(dry, wet, mix.linlin(0, 1, -1, 1));

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Normalize signal amplitude with dry/wet mix", category: "Effect/Dynamics");
)