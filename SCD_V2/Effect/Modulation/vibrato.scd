(
~synthCreator.value("Vibrato", {|n|
	var sigout, sig, mod1, depth, mfreq, mix, x;

	// Parameters
	depth = OceanodeParameterLag.ar(\depth, 0.1, n, 0, 0.5, "vf", 1/30, true);
	mfreq = OceanodeParameterLag.ar(\freq, 5, n, 0.1, 20, "vf", 1/30, true);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	sig = In.ar(OceanodeInput.kr(\in), n);

	// Create vibrato effect
	mod1 = SinOsc.ar(mfreq, 0, depth, depth);
	x = DelayC.ar(sig, 0.2, mod1);

	// Mix dry and wet signals (already using XFade2)
	sigout = XFade2.ar(sig, x, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sigout);
}, description: "Vibrato effect with adjustable rate and depth", category: "Effect/Modulation");
)