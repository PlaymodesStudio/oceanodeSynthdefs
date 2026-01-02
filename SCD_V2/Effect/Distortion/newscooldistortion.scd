(
~synthCreator.value("NewscoolDistortion", {|n|
	var input, output, sig, drive, mix;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	drive = OceanodeParameterLag.ar(\drive, 0.4, n, 0.01, 0.8, "vf", 1/30, true);
	drive=0.81-drive;
	drive=drive*drive;

	// Wet/dry mix
	mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	sig = input.abs;

	output = input/(sig+drive);

	// Mix dry/wet using XFade2 for equal power crossfade
	output = XFade2.ar(input, output, (mix*2)-1);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Asymmetric waveshaping distortion using rational function processing", category: "Effect/Distortion");
)