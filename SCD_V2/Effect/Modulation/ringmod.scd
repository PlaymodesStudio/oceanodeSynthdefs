(
~synthCreator.value("RingMod", {|n|
	var input, modulated, sig, wet, dry, p, amt, mix;

	// Parameters with lag for smooth transitions
	p = OceanodeParameterLag.ar(\pitch, 72, n, 12, 120, "vf", 1/30, true).midicps;
	amt = OceanodeParameterLag.kr(\strength, 1, n, 0, 4, "vf", 1/30, true);
	mix = OceanodeParameterLag.kr(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Get input from the bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Apply ring modulation
	modulated = input * (SinOsc.ar(p, 0, 1, 0) * amt);
	modulated = modulated.tanh;

	// Mix using XFade2 for constant power crossfade
	sig = XFade2.ar(input, modulated, mix * 2 - 1);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Ring modulator with frequency and strength control", category: "Effect/Modulation");
)