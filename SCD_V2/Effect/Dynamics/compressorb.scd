(
~synthCreator.value("CompressorB", {|n|
	var source, sig, thresh, ratio, attack, release, makeup, numchans, amplitudeDb, gainDb, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	thresh = OceanodeParameter.ar(\threshold, -6, n, -60, 0, "vf");
	ratio = OceanodeParameter.ar(\ratio, 4, n, 0, 60, "vf");
	attack = OceanodeParameter.ar(\attack, 0.005, n, 0, 0.01, "vf");
	release = OceanodeParameter.ar(\release, 0.01, n, 0, 0.05, "vf");
	makeup = OceanodeParameter.ar(\makeup, 1, n, 1, 8, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Calculate amplitude in dB and apply gain reduction
	amplitudeDb = Amplitude.ar(source, attack, release).ampdb;
	gainDb = ((amplitudeDb - thresh) * (1 / ratio - 1)).min(0);
	sig = source * gainDb.dbamp * makeup;
	
	// Mix dry and wet signals
	sig = XFade2.ar(source, sig, OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf") * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Alternative compressor with ratio-based compression", category: "Effect/Dynamics");
)