(
~synthCreator.value("PhaserB", {|n|
	var source, dsig, sig, numchans, freq, skew, feedback, mod, stages, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	freq = OceanodeParameter.ar(\frequency, 2, n, 0, 10, "vf");
	skew = OceanodeParameter.ar(\skew, 0, n, -1, 1, "vf");
	feedback = OceanodeParameter.ar(\feedback, 0.5, n, 0, 0.95, "vf");
	mod = OceanodeParameter.ar(\mod, 0.5, n, 0, 1, "vf");
	stages = OceanodeParameter.kr(\stages, 25, n, 1, 50, "vf");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create phaser effect using AnalogPhaser
	dsig = AnalogPhaser.ar(source, SinOsc.ar(freq), skew, feedback, mod, stages);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), dsig, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Advanced phaser effect with analog modeling", category: "Effect/Time/Phase");
)