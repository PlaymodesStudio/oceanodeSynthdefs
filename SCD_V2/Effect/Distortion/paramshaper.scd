(
~synthCreator.value("ParamShaper", {|n|
	var amount, k, dry, wet, sig, level, mix;

	// Parameters
	amount = OceanodeParameterLag.ar(\amount, 0, n, 0, 1, "vf", 1/30, true);
	level = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Calculate k parameter for the shaping function
	k = 2 * amount / (1 - amount);

	// Input stage
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Apply parametric shaping function
	wet = (1 + k) * dry / (1 + (k * dry.abs));

	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mix*2-1);

	// Apply level control
	sig = sig * level;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Parametric waveshaping distortion with smooth control", category: "Effect/Distortion");
)