(
~synthCreator.value("Phaser", {|n|
	var source, dsig, sig, numchans, freq, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	freq = OceanodeParameter.ar(\frequency, 2, n, 0, 10, "vf");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create phaser effect
	dsig = AllpassL.ar(source, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), dsig, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Phaser effect with allpass filter", category: "Effect/Time/Phase");
)