(
SynthDef(\prayerbell2, {
	arg out=0;
	var t_trig, freq, amp = 1, decayscale, lag = 1;
	var sig, input, first, freqscale, mallet, sing, levels;

	t_trig=\trigger.kr(1);
	freq=\pitch.kr(88).midicps;
	decayscale=\decay.kr(1);
	levels=\levels.kr(1);

	freqscale = freq / 2434;
	decayscale = Lag3.kr(decayscale, lag);

	mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir), 10000 * freqscale)!2;
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar
			}!2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet*levels;


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
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
	], input, freqscale, 0, decayscale);
	Out.ar(out, sig * -15.dbamp);
}).play();
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\prayerbell13, {
	arg out=0;
	var t_trigArray, freqArray, amp = 1, decayscaleArray, lag = 1;
	var sig, input, first, freqscale, mallet, sing, levelsArray, sigArray;

	// Define arrays for controls
	t_trigArray = \trigger.kr(0!13);
	decayscaleArray = \decay.kr(1!13, 1/30, fixedLag: true);
	levelsArray = \levels.kr(1!13, 1/30, fixedLag: true);
	freqArray = \pitch.kr(60!13, 1/30, fixedLag: true).midicps;

	// Initialize an array to hold the output signals for each channel
	sigArray = Array.fill(13, { |i|
		// Set frequency, trigger, decay, and levels for each channel from the arrays
		var freq = freqArray[i];
		var t_trig = t_trigArray[i];
		var decayscale = decayscaleArray[i];
		var levels = levelsArray[i];

		freqscale = freq / 2434;

		mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir), 10000 * freqscale);
		sing = LPF.ar(
			LPF.ar(
				PinkNoise.ar,
				2434 * freqscale
			) + Dust.ar(0.1), 10000 * freqscale
		) * LFNoise1.kr(0.5).range(-45, -30).dbamp;

		input = mallet * levels;

		// Synthesize the sound for this channel
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
		], input, freqscale, 0, decayscale)
	});

	// Output each channel to its corresponding output
	Out.ar(out, sigArray.collect { |sig, i| sig * -15.dbamp });

}).writeDefFile(d);
)
