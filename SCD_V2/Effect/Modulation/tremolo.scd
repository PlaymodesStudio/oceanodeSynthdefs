(
~synthCreator.value("Tremolo", {|n|
	var trem, signals, dry, mix, hz, pow, amp;

	// Parameters
	hz = OceanodeParameterLag.ar(\hz, 0, n, 0, 20, "vf", 1/30, true);
	pow = OceanodeParameter.ar(\pow, 1, n, 0.1, 4, "vf");
	amp = OceanodeParameter.ar(\amp, 0, n, 0, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	signals = In.ar(OceanodeInput.kr(\in), n);
	dry = signals;

	// Create tremolo effect
	trem = 1 - ((SinOsc.ar(hz, 0, 1, 1) / 2).pow(pow) * amp);
	signals = signals * trem;

	// Mix dry and wet signals
	signals = XFade2.ar(dry, signals, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Tremolo effect with adjustable rate, shape, and depth", category: "Effect/Modulation");
)