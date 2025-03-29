(
~synthCreator.value("Blit", {|n|
	var p, finalSig, waves, leak, vib, trem, tremRate, tremAmount, vibRate, vibAmount;

	// Parameter setup with OceanodeParameter
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);
	leak = OceanodeParameter.ar(\leak, 0.99, n, 0, 1, "vf");

	// Tremolo and vibrato parameters
	tremRate = OceanodeParameterLag.ar(\tremf, 0, n, 0, 8, "vf", 1/30, true);
	tremAmount = OceanodeParameterLag.ar(\trema, 0, n, 0, 1, "vf", 1/30, true);
	vibRate = OceanodeParameterLag.ar(\vibf, 0, n, 0, 8, "vf", 1/30, true);
	vibAmount = OceanodeParameterLag.ar(\viba, 0, n, 0, 1, "vf", 1/30, true);


	// Apply vibrato to pitch
	vib = SinOsc.ar(vibRate, 0, vibAmount, 0);
	p = p + vib;


	// Different waveforms
	waves = [
		BlitB3.ar(p.midicps, leak),
		BlitB3Saw.ar(p.midicps, leak),
		BlitB3Square.ar(p.midicps, leak),
		BlitB3Tri.ar(p.midicps, leak)
	];

	// Waveform selection
	finalSig = Select.ar(OceanodeParameterDropdown.kr(\type, 0, n, "Blit:BlitSaw:BlitSquare:BlitTri"), waves);

	// Apply tremolo to amplitude
	trem = 1 - ((SinOsc.ar(tremRate, 0, 1, 1) / 2) * tremAmount);

	// Final amplitude
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).linlin(0, 1, -60, 0).dbamp * trem;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Band limited oscillators with different wave shapes", category: "Source/Oscillator");
)