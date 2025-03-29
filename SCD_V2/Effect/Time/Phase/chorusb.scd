(
~synthCreator.value("ChorusB", {|n|
	var source, wet, sig, tapCount, numchans, freq, mx, feedback, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	tapCount = 6;
	
	// Parameters with appropriate ranges from synthdefs.json
	freq = OceanodeParameter.ar(\frequency, 0.01, n, 0, 1, "vf");
	feedback = OceanodeParameter.ar(\feedback, 0.5, n, 0, 2, "vf");
	mx = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create chorus effect with feedback
	wet = LeakDC.ar(LocalIn.ar(n)).tanh * feedback;
	wet = wet + source;
	
	wet = n.collect { |channel|
		var channelWet = wet[channel];
		var phases = (0..tapCount-1) / tapCount * 2pi + (channel / n * 2pi);
		
		tapCount.collect { |tap|
			DelayC.ar(
				channelWet,
				0.03,
				SinOsc.ar(freq[channel], phases[tap]).linlin(-1, 1, 0.005, 0.02)
			)
		}.sum / sqrt(tapCount)
	};
	
	LocalOut.ar(wet);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), wet, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Advanced chorus effect with feedback and multiple taps", category: "Effect/Time/Phase");
)