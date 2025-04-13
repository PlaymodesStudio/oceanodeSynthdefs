(
~synthCreator.value("Noise", {|n|
	var d, waves, finalSig;

	// Density parameter controls noise behavior (normalized 0-1)
	d = OceanodeParameterLag.ar(\density, 0.5, n, 0, 1, "vf", 1/30, true);

	waves = [
		WhiteNoise.ar(1, 0),         // White noise
		PinkNoise.ar(1, 0),          // Pink noise
		BrownNoise.ar(1, 0),         // Brown/red noise (deeper, rumbling)
		GrayNoise.ar(1, 0),          // Gray noise (filtered white noise)
		ClipNoise.ar(1, 0),          // Clip noise (binary noise)
		Crackle.ar(d.linlin(0, 1, 1.0, 1.99), 1, 0),  // Crackle noise (fractal) - safer range
		LFDNoise3.ar(d.linexp(0, 1, 0.1, 500), 1, 0), // Smoothed noise (cubic interpolation)
		Dust2.ar(d.linexp(0, 1, 1, 10000), 1, 0)      // Dust noise (sparse, random impulses)
	];

	// Select noise type
	finalSig = Select.ar(OceanodeParameterDropdown.kr(\type, 0, n, "White:Pink:Brown:Gray:Clip:Crackle:Smooth:Dust"), waves);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output to the specified bus
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Noise generator with different noise types", category: "Source/Noise");
)