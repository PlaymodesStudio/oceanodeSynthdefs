(
~synthCreator.value("Filter4Pole", {|n|
	var input, filters, filtered, freq, res, type, dry, mix, sig,fmin;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 128, n, 20, 135, "vf", 0.05, true).midicps;
	res = OceanodeParameter.ar(\q, 1, n, 0.1, 4, "vf");
	type = OceanodeParameterDropdown.kr(\type, 0, n, "LowPass:HighPass");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	fmin = OceanodeParameterLag.ar(\fm_in, 0, n, -1, 1, "vf", 1/30, true);

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply 4-pole filter
	filters = [
		BLowPass4.ar(input, freq+fmin, res),
		BHiPass4.ar(input, freq+fmin, res)
	];

	filtered = Select.ar(type, filters);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, filtered, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "4-pole filter with lowpass and highpass modes", category: "Effect/Filter");
)

dfm1