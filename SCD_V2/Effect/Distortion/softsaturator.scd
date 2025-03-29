(
~synthCreator.value("SoftSaturator", {|n|
	var sig, dist, input, amount, k, wet, dry;

	// Parameters
	amount = OceanodeParameterLag.ar(\amount, 0, n, 0, 1, "vf", 1/30, true);
	wet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Calculate k parameter for the shaping function
	k = 2 * amount / (1 - amount);

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply soft saturation
	dist = (1 + k) * input / (1 + (k * input.abs));

	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(dry, dist, wet * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Soft saturation distortion with smooth control", category: "Effect/Distortion");
)