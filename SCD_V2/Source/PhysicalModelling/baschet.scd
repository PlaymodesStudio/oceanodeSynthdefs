(
~synthCreator.value("CristalBaschet", {|n|
	var freq, amp, rodPressure, rodPosition, metalResonance, diffusion, size;
	var chanSig, sig;

	// Parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	rodPressure = OceanodeParameterLag.ar(\rodpressure, 0.5, n, 0, 1, "vf", 1/30, true);
	rodPosition = OceanodeParameterLag.ar(\rodposition, 0.3, n, 0, 1, "vf", 1/30, true);
	metalResonance = OceanodeParameterLag.ar(\metalres, 0.7, n, 0, 1, "vf", 1/30, true);
	diffusion = OceanodeParameterLag.ar(\diffusion, 0.6, n, 0, 1, "vf", 1/30, true);
	size = OceanodeParameterLag.ar(\size, 1.0, n, 0.1, 2, "vf", 1/30, true);

	// Process each channel separately
	sig = Array.fill(n, { |chan|
		var glass, metal, diffuser, friction;
		var nGlassModes = 5;
		var nMetalModes = 8;
		var glassRatios = [1, 2.756, 5.404, 8.933, 13.339];
		var thisSize = size.asArray[chan];
		var thisFreq = freq.asArray[chan];
		var thisRodPressure = rodPressure.asArray[chan];
		var thisRodPosition = rodPosition.asArray[chan];
		var thisMetalResonance = metalResonance.asArray[chan];
		var thisDiffusion = diffusion.asArray[chan];
		var thisAmp = amp.asArray[chan];

		var glassDecays = Array.fill(nGlassModes, {|i|
			3 * thisSize * exp(-0.5 * i);
		});
		var metalRatios = [1, 2.89, 4.95, 6.99, 9.53, 11.97, 14.88, 17.73];
		var metalDecays = Array.fill(nMetalModes, {|i|
			5 * thisSize * exp(-0.3 * i);
		});

		// Friction excitation
		friction = LPF.ar(
			WhiteNoise.ar(0.1) * thisRodPressure.linexp(0, 1, 0.02, 0.2),
			thisFreq * 4
		);
		friction = friction * SinOsc.ar(
			freq: thisFreq * (1 + LFNoise2.kr(1, 0.001)),
			mul: 0.5,
			add: 0.5
		);

		// Glass resonances
		glass = Mix.fill(nGlassModes, {|i|
			var baseFreq = thisFreq * glassRatios[i];
			var posAmp = sin(pi * thisRodPosition * (i + 1));
			Ringz.ar(
				friction,
				baseFreq,
				glassDecays[i],
				posAmp * exp(-0.5 * i)
			)
		});

		// Metal resonances
		metal = Mix.fill(nMetalModes, {|i|
			var baseFreq = (thisFreq * 0.5) * metalRatios[i];
			var decay = metalDecays[i] * thisMetalResonance;
			Ringz.ar(
				glass,
				baseFreq * LFNoise2.kr(0.1, 0.001, 1),
				decay,
				exp(-0.7 * i) * 0.5
			)
		});

		// Diffuser per channel
		diffuser = Mix.fill(4, {|i|
			var spreadFreq = thisFreq * (1 + (i * 0.02 * thisDiffusion));
			var spreadAmp = exp(-0.5 * i) * thisDiffusion;
			DelayC.ar(
				metal,
				0.05,
				LFNoise2.kr(
					0.1 + (0.05 * i),
					0.001,
					0.002 + (0.001 * i)
				),
				spreadAmp
			)
		});

		// Mix components
		chanSig = (glass * 0.3) + (metal * 0.4 * thisMetalResonance) + (diffuser * 0.3);

		// Body resonance
		chanSig = chanSig + BPF.ar(
			chanSig,
			thisFreq * 0.5,
			0.5,
			0.2
		);

		chanSig * thisAmp
	});

	// Limiter to prevent clipping and output
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig, 0.95));
}, description: "Physical model of the Cristal Baschet instrument", category: "Source/PhysicalModelling");
)