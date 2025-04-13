(
~synthCreator.value("PitchShifter", {|n|
	var input, sig, grainSize, pitchShift, pitchDispersion, timeDispersion, mix;

	// Parameters with appropriate ranges
	grainSize = 0.2; //this is a fixed value
	pitchShift = OceanodeParameterLag.ar(\pitchshift, 0, n, -24, 24, "vf", 1/30, true).midiratio;
	pitchDispersion = OceanodeParameterLag.ar(\pitchdisp, 0, n, 0, 1, "vf", 1/30, true);
	timeDispersion = OceanodeParameterLag.ar(\timedisp, 0.0001, n, 0.0001, 0.1, "vf", 1/30, true);
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Pitch shifting
	sig = PitchShift.ar(input, grainSize, pitchShift, pitchDispersion, timeDispersion);

	// Mix between dry and wet signals
	sig = XFade2.ar(input, sig, mix.linlin(0, 1, -1, 1));

	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Pitch shifter with grain size and dispersion controls", category: "Effect/Pitch");
)