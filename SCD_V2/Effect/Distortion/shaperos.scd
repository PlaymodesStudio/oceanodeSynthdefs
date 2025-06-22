(
~synthCreator.value("ShaperOS", {|n|
	var sig, distorted, buf, amp, mix;
	// Parameters
	amp = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	buf = OceanodeBuffer.kr(\bufnum);

	// Input stage
	sig = In.ar(OceanodeInput.kr(\in), n);

	// Apply waveshaping
	distorted = ShaperOS.ar(buf, sig, 4);

	// Slew rate limiting - only smooths sudden jumps, preserves volume
	distorted = Slew.ar(distorted, 10000, 10000); // Limits rate of change

	// Mix dry and wet signals
	distorted = XFade2.ar(sig, distorted, mix*2-1);

	// Apply level control
	distorted = distorted * amp;

	// Output
	Out.ar(OceanodeOutput.kr(\out), distorted);
}, description: "Performs waveshaping with slew rate limiting for glitch reduction", category: "Effect/Distortion");
)