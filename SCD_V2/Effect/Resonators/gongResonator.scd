(
~synthCreator.value("GongResonator", {|n|
	var freq, amp, thickness, damping, brightness, strikePos;
	var shimmerSpeed, shimmerDepth, sig, modes;
	var nModes, modeRatios, adjustedRatios, modeDecays, modeAmps;
	var input, send, mix, chanInput, wet;

	// Main parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);

	// Sound shaping parameters
	thickness = OceanodeParameter.ar(\thickness, 0.8, n, 0, 1, "vf");
	damping = OceanodeParameter.ar(\damping, 0.2, n, 0, 1, "vf");
	brightness = OceanodeParameter.ar(\brightness, 0.7, n, 0, 1, "vf");
	strikePos = OceanodeParameter.ar(\strikepos, 0.4, n, 0, 1, "vf");

	// Shimmer effect parameters
	shimmerSpeed = OceanodeParameter.ar(\shimmerspeed, 3, n, 0.1, 10, "vf");
	shimmerDepth = OceanodeParameter.ar(\shimmerdepth, 0.3, n, 0, 1, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed values
	nModes = 15;
	modeRatios = [1, 2.1, 3.79, 5.13, 6.75, 8.21, 10.05, 11.98, 13.65, 15.71, 17.89, 20.15, 22.67, 25.34, 28.19];

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Adjusted ratios based on thickness
		adjustedRatios = modeRatios * (1 + (thickness[chan] * Array.series(nModes, 0, 0.02)));

		// Mode decay rates
		modeDecays = Array.fill(nModes, {|i|
			(exp(-0.3 * i) * (1 - damping[chan]) * 8).clip(0.5, 10)
		});

		// Mode amplitudes with shimmer modulation
		modeAmps = Array.fill(nModes, {|i|
			var posAmp = sin(pi * strikePos[chan] * (i + 1));
			var shimmerMod = SinOsc.kr(
				shimmerSpeed[chan] * (i + 1) * 0.1,
				0,
				shimmerDepth[chan] * i/nModes
			);
			var shimmerValue = shimmerMod.linlin(-1, 1, 1-shimmerDepth[chan], 1);
			posAmp * exp(-0.7 * i * (1 - brightness[chan])) * shimmerValue
		});

		// Resonant modes
		wet = Mix.fill(nModes, {|i|
			var thisFreq = freq[chan] * adjustedRatios[i];
			var thisAmp = modeAmps[i];

			DynKlank.ar(`[
				[thisFreq],
				[thisAmp],
				[modeDecays[i]]
			], chanInput) * (1/nModes)
		});

		// Emphasize certain harmonics with bandpass filters
		wet = wet + Mix([
			BPF.ar(wet, freq[chan] * 0.5, 0.1, 0.1),
			BPF.ar(wet, freq[chan] * 0.75, 0.1, 0.07),
			BPF.ar(wet, freq[chan] * 1.5, 0.1, 0.05)
		]);

		// Apply limiting and final amplitude shaping
		wet = Limiter.ar(wet, 0.95) * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Javanese gong resonator effect that applies gong-like resonances to input audio", category: "Effect/Resonators");
)