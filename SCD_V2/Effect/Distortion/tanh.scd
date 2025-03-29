(
~synthCreator.value("Tanh", {|n|
	var dry, dcCorrected, wet, sig, drive, clip, level, mix;

	// Parameters
	drive = OceanodeParameter.ar(\drive, 10, n, 1, 100, "vf");
	clip = OceanodeParameter.ar(\clip, 0.8, n, 0.01, 1, "vf");
	level = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Get input signal
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Apply DC correction
	dcCorrected = LeakDC.ar(dry);

	// Apply hyperbolic tangent distortion
	wet = (dcCorrected * drive).tanh(clip);

	// Apply level control and limiting
	wet = wet * level;
	wet = Limiter.ar(wet, 0.99);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mix*2-1);

	// Final safety limiter
	sig = Limiter.ar(sig, 0.99);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Hyperbolic tangent distortion effect with smooth saturation", category: "Effect/Distortion");
)