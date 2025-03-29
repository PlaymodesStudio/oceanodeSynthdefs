(
~synthCreator.value("FreqShifter", {|n|
	var input, sig, freqShift, phase, mix;
	
	// Parameters with appropriate ranges
	freqShift = OceanodeParameterLag.ar(\freqshift, 150, n, -2000, 2000, "vf", 1/30, true);
	phase = OceanodeParameterLag.ar(\phase, 3.14, n, 0, 6.28, "vf", 1/30, true);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	
	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Frequency shifting
	sig = FreqShift.ar(input, freqShift, phase);
	
	// Mix between dry and wet signals
	sig = XFade2.ar(input, sig, mix.linlin(0, 1, -1, 1));
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Frequency shifter with phase control", category: "Effect/Pitch");
)