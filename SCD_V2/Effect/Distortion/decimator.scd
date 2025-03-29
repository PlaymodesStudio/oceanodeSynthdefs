(
~synthCreator.value("Decimator", {|n|
	var input, sig, rate, bits, dry, wet, mix, finalSig;

	// Parameters
	rate = OceanodeParameterLag.ar(\samplerate, 44100, n, 100, 48000, "vf", 1/30, true);
	bits = OceanodeParameterLag.ar(\bitdepth, 24, n, 1, 24, "vf", 1/30, true);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply decimation effect
	wet = Decimator.ar(input, rate, bits);

	// Mix dry and wet signals
	finalSig = XFade2.ar(dry, wet, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Bit crusher and sample rate reducer effect", category: "Effect/Distortion");
)