(
~synthCreator.value("Gamelan", {|n|
	var freq, levels, thickness, damping, brightness, mallet, strikePos, detune;
	var pairBalance, gate, sig, chanSig, exciter, modes, pair;
	var nModes, modeRatios, adjustedRatios, modeDecays, modeAmps;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	levels = OceanodeParameterLag.ar(\levels, 0.95, n, 0, 1, "vf", 1/30, true);
	thickness = OceanodeParameter.ar(\thickness, 0.7, n, 0, 1, "vf");
	damping = OceanodeParameter.ar(\damping, 0.3, n, 0, 1, "vf");
	brightness = OceanodeParameter.ar(\brightness, 0.6, n, 0, 1, "vf");
	mallet = OceanodeParameter.ar(\mallet, 0.5, n, 0, 1, "vf");
	strikePos = OceanodeParameter.ar(\strikepos, 0.3, n, 0, 1, "vf");
	detune = OceanodeParameter.ar(\detune, 4.0, n, 0, 10, "vf");
	pairBalance = OceanodeParameter.ar(\pairbalance, 0.95, n, 0, 1, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Fixed values
	nModes = 12;
	modeRatios = [1, 3.37, 6.75, 10.53, 14.96, 19.97, 25.61, 31.84, 38.69, 46.15, 54.23, 62.94];

	// Generate signals for each channel
	sig = n.collect({ |chan|
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

		// Excitation signal
		exciter = EnvGen.ar(
			Env.perc(0.0001, 0.01),
			levelScale: levels[chan],
			gate: gate[chan]
		) * Mix([
			Impulse.ar(0) * mallet[chan],
			HPF.ar(PinkNoise.ar, 500) * (1 - mallet[chan]) * 0.5
		]);

		// Main resonant modes
		modes = Mix.fill(nModes, {|i|
			var baseFreq = freq[chan] * adjustedRatios[i];
			var partialAmp = modeAmps[i];

			DynKlank.ar(`[
				[baseFreq],
				[partialAmp],
				[modeDecays[i]]
			], exciter) * (1/nModes)
		});

		// Second set of modes (paired bar)
		pair = Mix.fill(nModes, {|i|
			var baseFreq = (freq[chan] + detune[chan]) * adjustedRatios[i];
			var partialAmp = modeAmps[i];

			DynKlank.ar(`[
				[baseFreq],
				[partialAmp],
				[modeDecays[i]]
			], exciter) * (1/nModes)
		});

		// Mix primary and secondary bars with balance control
		chanSig = (modes * (1 - (pairBalance[chan] * 0.5))) + (pair * (pairBalance[chan] * 0.5));

		// Add nonlinear response and resonance emphasis
		chanSig = chanSig + (chanSig.abs * chanSig * EnvGen.kr(Env.perc(0.0001, 0.01)) * 0.1);
		chanSig = chanSig + BPF.ar(
			chanSig,
			[freq[chan] * 0.5, freq[chan] * 0.75],
			0.1,
			0.1
		).sum;

		// Apply limiting and final amplitude shaping
		Limiter.ar(chanSig * 2, 0.9) * levels[chan]
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Gamelan percussion instrument model with adjustable parameters", category: "Source/PhysicalModelling");
)