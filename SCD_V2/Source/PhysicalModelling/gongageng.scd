(
~synthCreator.value("GongAgeng", {|n|
	var freq, levels, thickness, damping, brightness, mallet, strikePos;
	var shimmerSpeed, shimmerDepth, gate, sig, chanSig, exciter, modes;
	var nModes, modeRatios, adjustedRatios, modeDecays, modeAmps;

	// Main parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true);

	// Sound shaping parameters
	thickness = OceanodeParameter.ar(\thickness, 0.8, n, 0, 1, "vf");
	damping = OceanodeParameter.ar(\damping, 0.2, n, 0, 1, "vf");
	brightness = OceanodeParameter.ar(\brightness, 0.7, n, 0, 1, "vf");
	mallet = OceanodeParameter.ar(\mallet, 0.3, n, 0, 1, "vf");
	strikePos = OceanodeParameter.ar(\strikepos, 0.4, n, 0, 1, "vf");

	// Shimmer effect parameters
	shimmerSpeed = OceanodeParameter.ar(\shimmerspeed, 3, n, 0.1, 10, "vf");
	shimmerDepth = OceanodeParameter.ar(\shimmerdepth, 0.3, n, 0, 1, "vf");

	// Trigger parameter
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Fixed values
	nModes = 15;
	modeRatios = [1, 2.1, 3.79, 5.13, 6.75, 8.21, 10.05, 11.98, 13.65, 15.71, 17.89, 20.15, 22.67, 25.34, 28.19];

	// Generate signals for each channel
	sig = n.collect({ |chan|
		// Adjusted ratios based on thickness
		adjustedRatios = modeRatios * (1 + (thickness[chan] * Array.series(nModes, 0, 0.02)));

		// Mode decay rates
		modeDecays = Array.fill(nModes, {|i|
			(exp(-0.3 * i) * (1 - damping[chan]) * 8).clip(0.5, 10)
		});

		// Mode amplitudes with shimmer modulation
		modeAmps = Array.fill(nModes, {|i|
			var posAmp = sin(pi * strikePos[chan] * (i + 1));
			var shimmer = SinOsc.kr(
				shimmerSpeed[chan] * (i + 1) * 0.1,
				0,
				shimmerDepth[chan] * i/nModes * 0.5,
				1 - (shimmerDepth[chan] * 0.5)
			);
			posAmp * exp(-0.7 * i * (1 - brightness[chan])) * shimmer
		});

		// Excitation signal
		exciter = EnvGen.ar(
			Env.perc(0.005, 0.1),
			levelScale: levels[chan],
			gate: gate[chan]
		) * Mix([
			Impulse.ar(0) * mallet[chan] * 0.7,
			HPF.ar(PinkNoise.ar, 200) * (1 - mallet[chan])
		]);

		// Resonant modes
		modes = Mix.fill(nModes, {|i|
			var baseFreq = freq[chan] * adjustedRatios[i];
			var partialAmp = modeAmps[i];

			DynKlank.ar(`[
				[baseFreq],
				[partialAmp],
				[modeDecays[i]]
			], exciter) * (1/nModes)
		});

		// Apply envelope for overall dynamics
		chanSig = modes * EnvGen.kr(
			Env([0, 1, 0.7, 0], [0.002, 0.2, 7], [-2, -1, -4]),
			gate: gate[chan]
		);

		// Emphasize certain harmonics with bandpass filters
		chanSig = chanSig + Mix([
			BPF.ar(chanSig, freq[chan] * [0.5, 0.75, 1.5], 0.1, [0.1, 0.07, 0.05])
		]);

		// Apply limiting and final amplitude shaping
		Limiter.ar(chanSig, 0.95) * levels[chan]
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Javanese large gong model with shimmer and adjustable resonance", category: "Source/PhysicalModelling");
)