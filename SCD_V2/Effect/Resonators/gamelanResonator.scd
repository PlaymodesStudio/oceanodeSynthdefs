(
~synthCreator.value("GamelanResonator", {|n|
	var freq, amp, thickness, damping, brightness, strikePos, detune;
	var pairBalance, sig, chanSig, modes, pair;
	var nModes, modeRatios, adjustedRatios, modeDecays, modeAmps;
	var input, send, mix, chanInput, baseFreq, partialAmp, wet;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.95, n, 0, 1, "vf", 1/30, true);
	thickness = OceanodeParameter.ar(\thickness, 0.7, n, 0, 1, "vf");
	damping = OceanodeParameter.ar(\damping, 0.3, n, 0, 1, "vf");
	brightness = OceanodeParameter.ar(\brightness, 0.6, n, 0, 1, "vf");
	strikePos = OceanodeParameter.ar(\strikepos, 0.3, n, 0, 1, "vf");
	detune = OceanodeParameter.ar(\detune, 4.0, n, 0, 10, "vf");
	pairBalance = OceanodeParameter.ar(\pairbalance, 0.95, n, 0, 1, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed values
	nModes = 12;
	modeRatios = [1, 3.37, 6.75, 10.53, 14.96, 19.97, 25.61, 31.84, 38.69, 46.15, 54.23, 62.94];

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Adjusted ratios based on thickness
		adjustedRatios = modeRatios * (1 + (thickness[chan] * [0, 0.01, 0.02, 0.035, 0.05, 0.07, 0.09, 0.11, 0.13, 0.15, 0.17, 0.19]));

		// Mode decay rates
		modeDecays = Array.fill(nModes, {|i|
			exp(-0.5 * i) * (1 - damping[chan]) * 3
		});

		// Mode amplitudes
		modeAmps = Array.fill(nModes, {|i|
			var posAmp = sin(pi * strikePos[chan] * (i + 1));
			posAmp * exp(-1 * i * (1 - brightness[chan]))
		});

		// Main resonant modes
		modes = Mix.fill(nModes, {|i|
			baseFreq = freq[chan] * adjustedRatios[i];
			partialAmp = modeAmps[i];

			DynKlank.ar(`[
				[baseFreq],
				[partialAmp],
				[modeDecays[i]]
			], chanInput) * (1/nModes)
		});

		// Second set of modes (paired bar)
		pair = Mix.fill(nModes, {|i|
			baseFreq = (freq[chan] + detune[chan]) * adjustedRatios[i];
			partialAmp = modeAmps[i];

			DynKlank.ar(`[
				[baseFreq],
				[partialAmp],
				[modeDecays[i]]
			], chanInput) * (1/nModes)
		});

		// Mix primary and secondary bars with balance control
		wet = (modes * (1 - (pairBalance[chan] * 0.5))) + (pair * (pairBalance[chan] * 0.5));

		// Add nonlinear response and resonance emphasis
		wet = wet + (wet.abs * wet * 0.1);
		wet = wet + BPF.ar(
			wet,
			[freq[chan] * 0.5, freq[chan] * 0.75],
			0.1,
			0.1
		).sum;

		// Apply limiting and final amplitude shaping
		wet = Limiter.ar(wet * 2, 0.9) * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Gamelan resonator effect that applies gamelan-like resonances to input audio", category: "Effect/Resonators");
)