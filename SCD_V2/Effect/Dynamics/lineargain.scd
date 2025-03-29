(
~synthCreator.value("LinearGain", {|n|
	var source, sig, gain, curve, numchans;

	// All variables must be declared at the beginning
	numchans = n;

	// Parameters with appropriate ranges from synthdefs.json
	gain = OceanodeParameterLag.ar(\gain, 1, n, 0, 8, "vf", 1/30, true);

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Apply gain with adjustable curve
	sig = source * gain;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Linear gain", category: "Effect/Dynamics");
)