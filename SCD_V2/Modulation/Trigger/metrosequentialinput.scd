

// ------------------------------------------------------------
// MetroSequentialInput
// Distributes incoming impulses sequentially (or random)
// ------------------------------------------------------------
~synthCreator.value("MetroSequentialInput", {|n|
	var input, trig;
	var reset, seed, reseed, fixednum, random, chance;
	var combinedReset;
	var indexSeq, currentIndex, randomIndex;
	var perChannelRand, perChannelSeeded;
	var totalTriggers, shouldTrigger;
	var signals;
	var seedKr, randomKr, min_chan, max_chan;

	// input impulse (single channel)
	input = In.ar(OceanodeInput.kr(\in), 1);
	trig  = Trig.ar(input > 0.1, 0.001);

	// params
	reset    = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	chance   = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	seed     = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i");
	reseed   = OceanodeParameter.kr(\reseed, 0, 1, 0, 1, "vi");
	fixednum = OceanodeParameter.ar(\fixednum, 0, 1, 0, 100000, "vi");
	random   = OceanodeParameter.kr(\random, 0, 1, 0, 1, "b");
	min_chan = OceanodeParameter.kr(\min_chan, 0, 1, 0, 63, "i"); // Minimum channel to sequence from (max 63 for any synth)
	max_chan = OceanodeParameter.kr(\max_chan, n-1, 1, 0, 63, "i"); // Maximum channel to sequence to (max 63 for any synth)

	seedKr   = seed;
	randomKr = random;
	min_chan = min_chan.asInteger.clip(0, n-1); // Ensure it's an integer and within valid range
	max_chan = max_chan.asInteger.clip(0, n-1); // Ensure it's an integer and within valid range
	// Ensure min_chan <= max_chan
	min_chan = min_chan.min(max_chan);
	max_chan = max_chan.max(min_chan);

	combinedReset = Trig.ar(
		K2A.ar(reset.asArray.sum) + K2A.ar(reseed > 0),
		SampleDur.ir
	);

	// fixednum handling
	totalTriggers = PulseCount.ar(trig, combinedReset);
	shouldTrigger = Select.ar(K2A.ar(fixednum > 0), [
		K2A.ar(1),
		K2A.ar(totalTriggers <= fixednum)
	]);
	trig = trig * shouldTrigger;

	// sequential index
	indexSeq = Dseq((0..(n-1)), inf);
	currentIndex = Demand.ar(trig, combinedReset, indexSeq);

	// Wrap the sequential index to fit within min_chan..max_chan range
	currentIndex = min_chan + ((currentIndex - min_chan) % (max_chan - min_chan + 1));

	// random index
	RandID.ir(seedKr + 23);
	RandSeed.kr(
		(seedKr > 0) * (Changed.kr(seedKr) + (reseed > 0)),
		(seedKr + 23).max(1)
	);
	randomIndex = TIRand.ar(min_chan, max_chan, trig);

	currentIndex = Select.ar(K2A.ar(randomKr > 0.5), [
		currentIndex,
		randomIndex
	]);

	// per-channel random (for chance)
	perChannelRand = Array.fill(n, {|i|
		RandID.ir(i * 1000 + 1234);
		TRand.ar(0, 1, trig);
	});

	perChannelSeeded = Array.fill(n, {|i|
		RandID.ir(seedKr + i);
		RandSeed.kr(
			(seedKr > 0) * (Changed.kr(seedKr) + (reseed > 0)),
			(seedKr + i).max(1)
		);
		TRand.ar(0, 1, trig);
	});

	// output
	signals = Array.fill(n, {|i|
		var indexMatch = BinaryOpUGen.new('==', currentIndex, i);
		var randVal = Select.ar(
			K2A.ar(seedKr > 0),
			[perChannelRand[i], perChannelSeeded[i]]
		);
		trig * indexMatch * (randVal < chance.asArray[i])
	});

	Out.ar(OceanodeOutput.kr(\out), signals);
},
description: "Sequential / random distribution of incoming impulses",
category: "Modulation/Trigger");
