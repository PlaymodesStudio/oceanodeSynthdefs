(
~synthCreator.value("CombFeed", {|n|
	var input, combed, sig, p, finalP, fb, decaytime, drywet, vib, ing, vibf, viba, prelpf, postlpf;

	// Parameters
	ing = OceanodeParameterLag.ar(\inputgain, 1, n, 0, 2, "vf", 1/30, true);
	p = OceanodeParameterLag.ar(\pitch, 36, n, 24, 96, "vf", 1/30, true);
	fb = OceanodeParameterLag.ar(\feedback, 0.5, n, 0, 0.99, "vf", 1/30, true);
	drywet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	
	// Vibrato parameters
	vibf = OceanodeParameter.ar(\vibf, 0, n, 0, 10, "vf");
	viba = OceanodeParameter.ar(\viba, 0, n, 0, 1, "vf");
	
	// Filter parameters
	prelpf = OceanodeParameterLag.ar(\prelpf, 130, n, 20, 130, "vf", 1/30, true);
	postlpf = OceanodeParameterLag.ar(\postlpf, 130, n, 20, 130, "vf", 1/30, true);

	// Input stage
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply vibrato
	vib = SinOsc.ar(vibf, 0, viba, 0);
	finalP = p + vib;
	finalP = finalP.midicps;
	
	// Convert feedback to decay time
	decaytime = (1/finalP) * log(0.001) / log(fb.abs) * fb.sign;
	
	// Pre-filter
	input = LPF.ar(input, prelpf.midicps);
	
	// Apply comb filter with feedback
	combed = CombC.ar(input * ing, 0.1, 1/finalP, decaytime, 1, 0) / 2;
	
	// Post-filter and DC removal
	combed = LPF.ar(combed, postlpf.midicps);
	combed = LeakDC.ar(combed);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(input, combed, drywet * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Comb filter with feedback control and additional filtering", category: "Effect/Filter");
)