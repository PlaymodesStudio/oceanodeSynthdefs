(
~synthCreator.value("MoogVCF", {|n|
	var input, filters, filtered, freq, res, type, dry, mix, sig;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 128, n, 20, 135, "vf", 0.05, true).midicps;
	res = OceanodeParameter.ar(\reso, 1, n, 0, 1, "vf");
	type = OceanodeParameterDropdown.kr(\type, 0, n, "MoogVCF:MoogFF:BMoog:MoogLadder");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	dry = input;

	// Apply different Moog filter implementations
	filters = [
		MoogVCF.ar(input, freq, res),
		MoogFF.ar(input, freq, res * 4),
		BMoog.ar(input, freq, 1 - res),
		MoogLadder.ar(input, freq, res)
	];

	filtered = Select.ar(type, filters);

	// Mix dry and wet signals
	sig = XFade2.ar(dry, filtered, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Collection of different Moog filter implementations", category: "Effect/Filter");
)