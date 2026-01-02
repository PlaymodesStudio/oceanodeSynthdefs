(
~synthCreator.value("Compressor", {|n|
	var source, sig, thresh, slopebelow, slopeabove, attack, release, makeup, numchans, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	thresh = OceanodeParameter.ar(\threshold, 0.5, n, 0.01, 1, "vf");
	slopebelow = OceanodeParameter.ar(\slopebelow, 1, n, 0, 1, "vf");
	slopeabove = OceanodeParameter.ar(\slopeabove, 1, n, 0, 1, "vf");
	attack = OceanodeParameter.ar(\attack, 0.005, n, 0, 0.01, "vf");
	release = OceanodeParameter.ar(\release, 0.01, n, 0, 0.05, "vf");
	makeup = OceanodeParameter.ar(\makeup, 1, n, 1, 8, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Apply compressor
	sig = Compander.ar(source, source, thresh, slopebelow, slopeabove, attack, release, 1, 0) * makeup;
	
	// Mix dry and wet signals
	sig = XFade2.ar(source, sig, OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf") * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Dynamic range compressor with threshold and slope controls", category: "Effect/Dynamics");
)