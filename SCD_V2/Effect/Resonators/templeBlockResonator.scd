(
~synthCreator.value("TempleBlockResonator", {|n|
	var freq, amp, lpf;
	var nModes, modeRatios, modeFreqs, modeDecays, modeAmps;
	var input, send, mix, sig;
	var chanFreq, chanModeFreqs, chanModeDecays, chanModeAmps, chanInput, modes;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	lpf = OceanodeParameter.ar(\lpf, 5000, n, 20, 20000, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Fixed parameters
	nModes = 8;
	modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62];

	// Generate signal for each channel
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan] * 0.2;
		chanFreq = freq[chan];
		chanModeFreqs = modeRatios * chanFreq;

		// Longer decay times for temple block's hollow resonance
		chanModeDecays = Array.fill(nModes, {|i|
			0.1 * exp(-0.3 * i)
		});

		// Specific mode amplitudes for temple block character
		chanModeAmps = [1, 0.7, 0.45, 0.35, 0.25, 0.15, 0.1, 0.05];

		// Modal resonators
		modes = Mix.fill(nModes, {|i|
			Ringz.ar(
				chanInput,
				chanModeFreqs[i],
				chanModeDecays[i],
				chanModeAmps[i]
			)
		});

		// Low-pass filter and apply amplitude
		modes = LPF.ar(modes * amp[chan].lincurve(0, 1, 0, 1, 4), lpf[chan]);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], modes, mix[chan] * 2 - 1);
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.9));

}, description: "Temple block resonator effect that applies temple block-like resonances to input audio", category: "Effect/Resonators");
)