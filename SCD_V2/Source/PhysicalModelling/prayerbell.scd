(
~synthCreator.value("PrayerBell", {|n|
	var t_trigArray, freqArray, decayscaleArray, levelsArray;
	var sig, freqscale, mallet, sing, input, first;

	// Main parameters with lag for smooth transitions
	t_trigArray = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	decayscaleArray = OceanodeParameterLag.ar(\decay, 1, n, 0, 10, "vf", 1/30, true);
	levelsArray = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	freqArray = OceanodeParameterLag.ar(\pitch, 24, n, 0, 130, "vf", 1/30, true).midicps;

	// Generate signal for each channel
	sig = n.collect({ |chan|
		var freq, t_trig, decayscale, levels;

		// Get parameters for this channel - fixed indexing
		freq = freqArray.at(chan);
		t_trig = t_trigArray.at(chan);
		decayscale = decayscaleArray.at(chan);
		levels = levelsArray.at(chan);

		// Calculate frequency scaling
		freqscale = freq / 2434;

		// Create mallet excitation
		mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir), 10000 * freqscale);

		// Create singing components
		sing = LPF.ar(
			LPF.ar(
				PinkNoise.ar,
				2434 * freqscale
			) + Dust.ar(0.1), 10000 * freqscale
		) * LFNoise1.kr(0.5).range(-45, -30).dbamp;

		// Combine excitation sources
		input = mallet * levels.lincurve(0, 1, 0, 1, 4);

		// Resonator bank with modal frequencies
		DynKlank.ar(`[
			[
				(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
				first + LFNoise1.kr(0.5).range(1, 3),
				LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
				LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
				LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
				LFNoise1.kr(2).range(8665, 8670),
				LFNoise1.kr(2).range(8704, 8709),
				LFNoise1.kr(2).range(8807, 8817),
				LFNoise1.kr(2).range(9570, 9607),
				LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
				LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
				LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
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
		], input, freqscale, 0, decayscale) * -15.dbamp
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Tibetan prayer bell model with inharmonic resonances", category: "Source/PhysicalModelling");
)