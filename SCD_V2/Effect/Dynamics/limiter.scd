(
~synthCreator.value("Limiter", {|n|
	var source, sig, level, numchans, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	level = OceanodeParameter.ar(\level, 1, n, 0.01, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Apply limiter with DC offset removal
	sig = Limiter.ar(LeakDC.ar(source), level, 0.01) * level.reciprocal;
	
	// Mix dry and wet signals
	sig = XFade2.ar(source, sig, OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf") * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Hard limiter with DC offset removal", category: "Effect/Dynamics");
)