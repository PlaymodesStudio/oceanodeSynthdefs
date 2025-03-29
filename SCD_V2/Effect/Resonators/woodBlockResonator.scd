(
~synthCreator.value("WoodBlockResonator", {|n|
	var freq, amp, strikePos, hardness, thickness, hollow, decay, bright, lpf;
	var nModes, modeRatios;
	var sig, input, send, mix;
	var exciter, modes, chanFreq, modeFreqs, modeDecays, modeAmps, chanInput;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 48, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	strikePos = OceanodeParameter.ar(\strikepos, 0.93, n, 0.1, 0.99, "vf");
	hardness = OceanodeParameter.ar(\hardness, 0.027, n, 0.001, 0.1, "vf");
	thickness = OceanodeParameter.ar(\thickness, 0.95, n, 0, 1, "vf");
	hollow = OceanodeParameter.ar(\hollow, 0.97, n, 0, 1, "vf");
	decay = OceanodeParameter.ar(\decay, 1, n, 0.1, 5, "vf");
	bright = OceanodeParameter.ar(\bright, 0.95, n, 0, 1, "vf");
	lpf = OceanodeParameter.ar(\lpf, 5000, n, 20, 20000, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed parameters
	nModes = 12;
	modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62, 6.15, 7.23, 8.17, 9.32];

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate per-channel signals
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan] * 0.2;
		chanFreq = freq[chan];

		// Per-channel mode frequencies
		modeFreqs = modeRatios.collect({ |ratio, i|
			chanFreq * ratio * (1 + (thickness[chan] * 0.1 * i))
		});

		// Per-channel decay times
		modeDecays = Array.fill(nModes, {|i|
			var baseDecay = decay[chan] * (0.1 * exp(-0.25 * i));
			var hollowFactor = hollow[chan].linexp(0, 1, 1, 3);
			baseDecay * hollowFactor
		});

		// Per-channel amplitudes
		modeAmps = Array.fill(nModes, {|i|
			var posAmp = sin(pi * (i + 1) * strikePos[chan]);
			var brightAmp = bright[chan].linexp(0, 1, 0.4, 1.5);
			posAmp * (brightAmp ** (-1 * i/4))
		});

		// Use input signal as exciter
		exciter = chanInput;

		// Modal resonator bank
		modes = Mix.fill(nModes, {|i|
			var mode = Ringz.ar(
				exciter,
				modeFreqs[i] * LFNoise1.kr(10, 0.001, 1),
				modeDecays[i],
				modeAmps[i]
			);

			mode + (
				Ringz.ar(
					mode,
					modeFreqs.wrapAt(i+1),
					modeDecays[i] * 0.5
				) * 0.05
			)
		});

		// Processing
		modes = modes * (1 + (modes * 0.1 * hollow[chan])).clip2(1);

		// Low-pass filter and apply amplitude
		modes = LPF.ar(modes * amp[chan].lincurve(0, 1, 0, 1, 4), lpf[chan]);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], modes, mix[chan] * 2 - 1);
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.9));
}, description: "Woodblock resonator effect that applies woodblock-like resonances to input audio", category: "Effect/Resonators");
)