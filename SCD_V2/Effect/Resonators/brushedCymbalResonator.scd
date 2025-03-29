(
~synthCreator.value("BrushedCymbalResonator", {|n|
	var amp, locut, hicut, time, resolevel, shimmer, resonum, transpose;
	var maxResonators, freqs, res, sig, input, send, mix;
	var chanInput, wet;

	// Continuous control parameters
	amp = OceanodeParameter.ar(\levels, 0.1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	locut = OceanodeParameter.ar(\locut, 4000, n, 200, 20000, "vf");
	hicut = OceanodeParameter.ar(\hicut, 8000, n, 100, 20000, "vf");
	time = OceanodeParameter.kr(\time, 1.2, n, 0.1, 10, "vf");
	resolevel = OceanodeParameter.kr(\resolevel, 2.0, n, 0, 5, "vf");
	shimmer = OceanodeParameter.ar(\shimmer, 0.9, n, 0, 1, "vf");
	resonum = OceanodeParameter.ar(\resonum, 200, n, 0, 200, "vf");
	transpose = OceanodeParameter.ar(\transpose, 0, n, -1000, 1000, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	maxResonators = (200/n).asInteger;  // Fixed maximum

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate base frequencies with transpose
	freqs = {exprand(300, 20000)}.dup(maxResonators) + transpose;

	// Generate per-channel signals
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Resonators with variable active count and shimmer
		res = Ringz.ar(
			chanInput,
			freqs * Array.fill(maxResonators, { |i|
				1 + (shimmer[chan] * (i/maxResonators - 0.5))
			}),
			time[chan]
		);
		
		// Sum only active resonators
		wet = Mix.fill(maxResonators, { |i|
			res[i] * (i < resonum[chan]).asInteger
		}) * resolevel[chan];
		
		// Add high frequency emphasis based on shimmer
		wet = wet + HPF.ar(
			wet * shimmer[chan],
			10000
		);
		
		// Apply amplitude curve for natural level control
		wet = wet * amp[chan] * 0.1;
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Brushed cymbal resonator effect that applies multiple resonant frequencies to input audio", category: "Effect/Resonators");
)