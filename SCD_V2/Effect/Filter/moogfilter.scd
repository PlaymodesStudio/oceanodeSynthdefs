(
~synthCreator.value("MoogFilter", {|n|
	var input, filtered, freq, q, mode, saturation, dry, mix, sig;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 128, n, 20, 135, "vf", 0.1, true).midicps;
	q = OceanodeParameter.ar(\q, 0.2, n, 0.01, 4, "vf");
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "LowPass:BandPass:HighPass:Notch");
	saturation = OceanodeParameter.ar(\saturation, 0.95, n, 0, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply Moog filter
	filtered = BMoog.ar(input, freq, q, mode, saturation);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, filtered, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Moog filter with multiple filter modes and saturation control", category: "Effect/Filter");
)