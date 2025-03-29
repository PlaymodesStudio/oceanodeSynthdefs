(
~synthCreator.value("Distort", {|n|
	var input, distort, distortions, type, sig, wet, dry, distamp, tp;

	// Parameters
	distamp = OceanodeParameterLag.ar(\pregain, 0.2, n, 0, 1, "vf", 1/30, true).pow(2) * 80;
	tp = OceanodeParameterDropdown.kr(\type, 0, n, "Distort:SoftClip:Clip2:Fold2:Wrap2:Tanh");
	wet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	input = LeakDC.ar(input);
	dry = input;

	// Different distortion algorithms
	distortions = [
		(input * distamp).distort,
		(input * distamp).softclip,
		(input * distamp).clip2,
		(input * distamp).fold2,
		(input * distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs))
	];

	// Select distortion type
	distort = Select.ar(tp, distortions);

	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(dry, distort, wet * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Multi-algorithm distortion effect with various distortion types", category: "Effect/Distortion");
)