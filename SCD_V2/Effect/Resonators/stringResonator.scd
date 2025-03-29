(
~synthCreator.value("StringResonator", {|n|
	var freq, amp, pos, invDec, highLoss, inharm, preLPF, lpf, levels;
	var inp, son, rel, send, mix;
	var chanInput, filtered, wet;

	// Control parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameterLag.ar(\pos, 0.1, n, 0, 1, "vf", 1/30, true);
	invDec = OceanodeParameterLag.ar(\invdec, 1, n, 0, 10, "vf", 1/30, true);
	highLoss = OceanodeParameterLag.ar(\highloss, 3000, n, 0.1, 3000, "vf", 1/30, true);
	inharm = OceanodeParameterLag.ar(\inharm, 80, n, 0, 1000, "vf", 1/30, true);
	preLPF = OceanodeParameterLag.ar(\prelpf, 80, n, 0, 130, "vf", 1/30, true).midicps;
	lpf = OceanodeParameterLag.ar(\lpf, 90, n, 0, 130, "vf", 1/30, true).midicps;
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed release to prevent synth from being freed
	rel = 1000;

	// Process input signal
	inp = In.ar(OceanodeInput.kr(\in), n);
	
	// Generate per-channel signals
	son = n.collect({ |chan|
		chanInput = inp[chan] * send[chan];
		filtered = LPF.ar(chanInput, preLPF[chan]);
		
		// Generate plucked string sound using the input
		wet = DWGPluckedStiff.ar(
			freq[chan], 
			amp[chan], 
			0, // No trigger needed
			pos[chan], 
			invDec[chan], 
			highLoss[chan], 
			filtered, 
			rel, 
			inharm[chan]
		);
		
		// Apply filtering
		wet = LPF.ar(wet, lpf[chan]);
		
		// Mix dry and wet signals
		XFade2.ar(inp[chan], wet * levels[chan] * 0.2, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), son);
}, description: "String resonator effect that applies plucked string resonances to input audio", category: "Effect/Resonators");
)