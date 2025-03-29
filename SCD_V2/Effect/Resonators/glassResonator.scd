(
~synthCreator.value("GlassResonator", {|n|
	var freq, amp, pos, size, damping, sig;
	var modes, nModes, modeRatios, baseDecay;
	var input, send, mix, chanInput, wet;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameter.ar(\pos, 0.3, n, 0, 1, "vf");
	size = OceanodeParameter.ar(\size, 1.0, n, 0.1, 2, "vf");
	damping = OceanodeParameter.ar(\damping, 0.5, n, 0, 1, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed values
	nModes = 6;
	modeRatios = [1, 2.32, 4.25, 6.63, 9.38, 12.22];

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Calculate decay time based on size and damping
		baseDecay = 3.0 * size[chan] * (1 - damping[chan]);

		// Modal synthesis
		wet = Mix.fill(nModes, {|i|
			var decay = baseDecay * exp(-0.5 * i);
			var modalAmp = exp(-0.5 * i) * sin(pi * pos[chan] * (i + 1));
			Ringz.ar(
				chanInput,
				freq[chan] * modeRatios[i],
				decay,
				modalAmp
			)
		});

		// Apply amplitude
		wet = wet * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Glass resonator effect that applies glass-like resonances to input audio", category: "Effect/Resonators");
)