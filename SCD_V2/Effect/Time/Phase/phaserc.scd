(
~synthCreator.value("PhaserC", {|n|
	var source, wet, sig, k, numchans, freq, minval, maxval, feedback, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	freq = OceanodeParameter.ar(\frequency, 0.1, n, 0, 1, "vf");
	minval = OceanodeParameter.ar(\min, 0, n, 0, 1, "vf");
	maxval = OceanodeParameter.ar(\max, 1, n, 0, 1, "vf");
	feedback = OceanodeParameter.ar(\feedback, 0.5, n, 0, 0.99, "vf");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create phaser effect using FOS filters
	k = SinOsc.ar(freq).linlin(-1, 1, minval, maxval);
	wet = source;
	wet = wet + (LocalIn.ar(n) * feedback);
	
	wet = n.collect { |i|
		var channel = wet[i];
		6.do {
			channel = FOS.ar(channel, k[i].neg, 1, k[i]);
		};
		channel
	};
	
	LocalOut.ar(wet);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), wet, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Phaser effect with FOS filters and feedback", category: "Effect/Time/Phase");
)