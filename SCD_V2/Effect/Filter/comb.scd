(
~synthCreator.value("Comb", {|n|
	var input, combed, sig, p, finalP, dec, drywet, vib, ing, vibf, viba;

	// Parameters
	ing = OceanodeParameterLag.ar(\inputgain, 1, n, 0, 2, "vf", 1/30, true);
	p = OceanodeParameter.ar(\pitch, 36, n, 24, 96, "vf");
	dec = OceanodeParameter.ar(\decay, 1, n, 0.01, 10, "vf");
	drywet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	
	// Vibrato parameters
	vibf = OceanodeParameter.ar(\vibf, 0, n, 0, 10, "vf");
	viba = OceanodeParameter.ar(\viba, 0, n, 0, 1, "vf");
	vib = SinOsc.ar(vibf, 0, viba, 0);
	
	// Calculate pitch with vibrato
	finalP = p + vib;
	finalP = finalP.midicps;

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply comb filter
	combed = CombL.ar(input * ing, 0.1, 1/finalP, dec, 1, 0) / 2;
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(input, combed, drywet * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Comb filter with pitch and decay controls", category: "Effect/Filter");
)