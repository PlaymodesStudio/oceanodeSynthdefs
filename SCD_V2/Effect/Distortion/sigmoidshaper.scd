(
~synthCreator.value("SigmoidShaper", {|n|
	var steep, inflec, level, mix, dry, wet, sig;

	// Parameters
	steep = OceanodeParameterLag.ar(\steep, 0.5, n, -1, 1, "vf", 1/30, true);
	inflec = OceanodeParameterLag.ar(\inflec, 0.5, n, -1, 1, "vf", 1/30, true);
	level = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Apply sigmoid shaping function
	wet = { |ph, steep, inflec|
		var y = (((inflec * (steep - 1) * ((ph / inflec) - 1)) /
				((4 * steep) * (ph - inflec).abs - steep - 1)) +
				((inflec * (steep - 1)) / ((4 * inflec * steep) - steep - 1))) /
				(((inflec * (steep - 1) * ((1 / inflec) - 1)) /
				((4 * steep) * (1 - inflec).abs - steep - 1)) +
				((inflec * (steep - 1)) / ((4 * inflec * steep) - steep - 1)));
		y.clip(0, 1)  // Ensure output is between 0 and 1
	}.value(dry, steep, inflec);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mix*2-1);

	// Apply level control
	sig = sig * level;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Sigmoid waveshaping distortion with steepness and inflection controls", category: "Effect/Distortion");
)