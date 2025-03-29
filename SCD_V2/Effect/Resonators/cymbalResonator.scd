(
~synthCreator.value("CymbalResonator", {|n|
	var minFreq, maxFreq, resonNum, time, resoLevel, amp;
	var freqs, res, input, send, mix;
	var maxResonators = 100;
	var chanInput, wet, isActive;

	// Control parameters
	minFreq = OceanodeParameterLag.ar(\minfreq, 300, n, 0, 20000, "vf", 1/30, true);
	maxFreq = OceanodeParameterLag.ar(\maxfreq, 20000, n, 0, 20000, "vf", 1/30, true);
	time = OceanodeParameterLag.ar(\decay, 5, n, 0.001, 20, "vf", 1/30, true);
	resoLevel = OceanodeParameterLag.ar(\resolevel, 1, n, 0, 1, "vf", 1/30, true);
	resonNum = OceanodeParameter.kr(\resonum, 100, n, 1, 100, "vi");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output level with proper curve scaling
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate per-channel signals
	res = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Generate resonator frequencies - fixed at initialization
		freqs = { exprand(minFreq[chan], maxFreq[chan]) } ! maxResonators;
		
		// Create resonators
		wet = Mix.fill(maxResonators, { |i|
			isActive = i < resonNum[chan];
			Ringz.ar(
				chanInput,
				freqs[i],
				time[chan]
			) * isActive
		}) / maxResonators * resoLevel[chan] * amp[chan];
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output
	Out.ar(OceanodeOutput.kr(\out), res);
}, description: "Cymbal resonator effect that applies multiple resonant filters to input audio", category: "Effect/Resonators");
)