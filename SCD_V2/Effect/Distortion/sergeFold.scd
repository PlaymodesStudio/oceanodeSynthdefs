(
~synthCreator.value("SergeFoldOs", {|n|
	var dist, sig, wet, dry, amt, input;

	// Parameters
	amt = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true);
	wet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply wavefolder distortion
	dist = SergeFoldOS.ar(input, amt, 4);

	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(dry, dist, wet * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "A wavefolder in the shape of the classic Serge wavefolder.", category: "Effect/Distortion");
)