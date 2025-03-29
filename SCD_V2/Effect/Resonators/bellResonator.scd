(
~synthCreator.value("BellResonator", {|n|
	var freqArray, decayscaleArray, levelsArray;
	var sig, freqscale, input, first;
	var send, mix, freq, decayscale, levels, chanInput, wet;

	// Main parameters with lag for smooth transitions
	decayscaleArray = OceanodeParameterLag.ar(\decay, 1, n, 0, 10, "vf", 1/30, true);
	levelsArray = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	freqArray = OceanodeParameterLag.ar(\pitch, 24, n, 0, 130, "vf", 1/30, true).midicps;
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	sig = n.collect({ |chan|
		// Get parameters for this channel
		freq = freqArray[chan];
		decayscale = decayscaleArray[chan];
		levels = levelsArray[chan];
		chanInput = input[chan] * send[chan] * levels.lincurve(0, 1, 0, 1, 4);

		// Calculate frequency scaling
		freqscale = freq / 2434;

		// Resonator bank with modal frequencies
		wet = DynKlank.ar(`[
			[
				(first = LFNoise1.kr(0.5).range(2424, 2444) * freqscale) + Line.kr(20, 0, 0.5),
				first + LFNoise1.kr(0.5).range(1, 3),
				LFNoise1.kr(1.5).range(5435, 5440) * freqscale - Line.kr(35, 0, 1),
				LFNoise1.kr(1.5).range(5480, 5485) * freqscale - Line.kr(10, 0, 0.5),
				LFNoise1.kr(2).range(8435, 8445) * freqscale + Line.kr(15, 0, 0.05),
				LFNoise1.kr(2).range(8665, 8670) * freqscale,
				LFNoise1.kr(2).range(8704, 8709) * freqscale,
				LFNoise1.kr(2).range(8807, 8817) * freqscale,
				LFNoise1.kr(2).range(9570, 9607) * freqscale,
				LFNoise1.kr(2).range(10567, 10572) * freqscale - Line.kr(20, 0, 0.05),
				LFNoise1.kr(2).range(10627, 10636) * freqscale + Line.kr(35, 0, 0.05),
				LFNoise1.kr(2).range(14689, 14697) * freqscale - Line.kr(10, 0, 0.05)
			],
			[
				LFNoise1.kr(1).range(-10, -5).dbamp,
				LFNoise1.kr(1).range(-20, -10).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				-20.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp,
				-10.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp
			],
			[
				20 * freqscale.pow(0.2),
				20 * freqscale.pow(0.2),
				5,
				5,
				0.6,
				0.5,
				0.3,
				0.25,
				0.4,
				0.5,
				0.4,
				0.6
			] * freqscale.reciprocal.pow(0.5)
		], chanInput, 1, 0, decayscale) * -15.dbamp;

		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Bell resonator effect that applies inharmonic bell-like resonances to input audio", category: "Effect/Resonators");
)