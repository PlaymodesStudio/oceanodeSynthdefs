(
~synthCreator.value("Noise", {|n|
	var d, waves, finalSig;

	// Density parameter controls noise behavior (normalized 0-1)
	d = OceanodeParameterLag.ar(\density, 0.5, n, 0, 1, "vf", 1/30, true);

waves = [
    WhiteNoise.ar(1 ! n, 0),         // n independent white noise generators
    PinkNoise.ar(1 ! n, 0),          // n independent pink noise generators
    BrownNoise.ar(1 ! n, 0),         // n independent brown noise generators
    GrayNoise.ar(1 ! n, 0),          // etc.
    ClipNoise.ar(1 ! n, 0),
    Crackle.ar(d.linlin(0, 1, 1.0, 1.99), 1 ! n, 0),
    LFDNoise3.ar(d.linexp(0, 1, 0.1, 500), 1 ! n, 0),
    Dust2.ar(d.linexp(0, 1, 1, 10000), 1 ! n, 0)
];

	// Select noise type
	finalSig = Select.ar(OceanodeParameterDropdown.kr(\type, 0, n, "White:Pink:Brown:Gray:Clip:Crackle:Smooth:Dust"), waves);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output to the specified bus
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Noise generator with different noise types", category: "Source/Noise");
)