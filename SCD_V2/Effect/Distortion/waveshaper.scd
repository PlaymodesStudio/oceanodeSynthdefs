(
~synthCreator.value("WaveShaper", {|n|
	var sig, distorted, buf, amp, mix;

	// Parameters
	amp = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	buf = OceanodeParameter.kr(\bufnum, 0, n, 0, 100, "vi");

	// Input stage
	sig = In.ar(OceanodeInput.kr(\in), n);

	// Apply waveshaping using buffer
	distorted = Shaper.ar(buf, sig);

	// Mix dry and wet signals
	distorted = XFade2.ar(sig, distorted, mix*2-1);

	// Apply level control
	distorted = distorted * amp;

	// Output
	Out.ar(OceanodeOutput.kr(\out), distorted);
}, description: "Buffer-based waveshaping distortion using transfer functions", category: "Effect/Distortion");
)