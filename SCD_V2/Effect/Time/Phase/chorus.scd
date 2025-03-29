(
~synthCreator.value("Chorus", {|n|
	var source, wet, sig, numchans, freq, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	freq = OceanodeParameter.ar(\frequency, 0.01, n, 0, 1, "vf");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create chorus effect
	wet = Mix.fill(10, { |i|
		DelayL.ar(
			source, 
			0.1, // maxDelayTime
			LFDNoise3.ar(freq).range(0.001, 0.005) // modulated delay time
		)
	});
	
	// Normalize the wet signal
	wet = wet / 2;
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), wet, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Classic chorus effect with modulated delay times", category: "Effect/Time/Phase");
)