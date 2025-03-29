(
~synthCreator.value("LadderFilter", {|n|
	var input, sig, freq, res, overdrive, filters, dry, mix, type;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 130, n, 20, 135, "vf", 1/30, true).midicps;
	res = OceanodeParameter.ar(\res, 0.5, n, 0, 1, "vf");
	overdrive = OceanodeParameterLag.ar(\drive, 0, n, 0, 1, "vf", 1/30, true);
	type = OceanodeParameterDropdown.kr(\type, 0, n, "LowPass:BandPass:HighPass:Notch:Peak:AllPass");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply different filter types
	filters = [
		VALadder.ar(input, freq, res, overdrive, type: 0),  // LowPass
		VALadder.ar(input, freq, res, overdrive, type: 1),  // BandPass
		VALadder.ar(input, freq, res, overdrive, type: 2),  // HighPass
		VALadder.ar(input, freq, res, overdrive, type: 3),  // Notch
		VALadder.ar(input, freq, res, overdrive, type: 4),  // Peak
		VALadder.ar(input, freq, res, overdrive, type: 5)   // AllPass
	];

	sig = Select.ar(type, filters);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, sig, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Ladder filter with overdrive and multiple filter types", category: "Effect/Filter");
)