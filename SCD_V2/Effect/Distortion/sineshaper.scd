(
~synthCreator.value("SineShaper", {|n|
	var input, shaped, sig, mix, level;

	// Get input from the bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with lag for smooth transitions
	level = OceanodeParameterLag.ar(\level, 1, n, 0, 20, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Apply sine waveshaping to the input signal
	shaped = (input * level).sin;

	// Mix using XFade2 for constant power crossfade
	sig = XFade2.ar(input, shaped, mix * 2 - 1);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Sine waveshaper with constant power crossfade", category: "Effect/Distortion");
)