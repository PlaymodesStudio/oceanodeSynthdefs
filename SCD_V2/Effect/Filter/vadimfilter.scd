(
~synthCreator.value("VadimFilter", {|n|
	var input, sig, freq, res, filters, dry, mix, type;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 130, n, 20, 135, "vf", 1/30, true).midicps;
	res = OceanodeParameter.ar(\res, 1, n, 0, 1, "vf");
	type = OceanodeParameterDropdown.kr(\type, 0, n, "LowPass:BandPass:HighPass:Notch:Peak:AllPass");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply different filter types
	filters = [
		VadimFilter.ar(input, freq, res, type: 0),  // LowPass
		VadimFilter.ar(input, freq, res, type: 1),  // BandPass
		VadimFilter.ar(input, freq, res, type: 2),  // HighPass
		VadimFilter.ar(input, freq, res, type: 3),  // Notch
		VadimFilter.ar(input, freq, res, type: 4),  // Peak
		VadimFilter.ar(input, freq, res, type: 5)   // AllPass
	];

	sig = Select.ar(type, filters);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, sig, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Vadim filter with multiple filter types", category: "Effect/Filter");
)