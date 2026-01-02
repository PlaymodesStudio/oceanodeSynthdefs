// ------------------------------------------------------------
// MetroSequentialIndex
// Generates sequential impulses with customizable index sequence
// EXTENDED: Added 'index' vector for custom channel sequencing
// ------------------------------------------------------------
~synthCreator.value("MetroSequentialIndex", {|n|
	var signals, trig;
	var hz, chance, reset, seed, reseed, fixednum, random;
	var index; // New Parameter
	var normalRand, seededRand, instanceID, combinedReset;
	var perChannelRand, perChannelSeeded;
	var shouldTrigger, totalTriggersSent;
	var randomStep, currentStep, channelIndex;
	var seedKr, reseedKr, randomKr, min_chan, max_chan, invertKr, invert;
	var trigWithReset;
	var counter;
	var phase, phaseRate, rawTrig;

	// Parameters
	hz       = OceanodeParameterLag.ar(\hz, 1, n, 0.01, 60, "vf", 1/30, true);
	chance   = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset    = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	seed     = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i");
	reseed   = OceanodeParameter.kr(\reseed, 0, 1, 0, 1, "vi");
	fixednum = OceanodeParameter.ar(\fixednum, 0, 1, 0, 1000, "vi");
	random   = OceanodeParameter.kr(\random, 0, 1, 0, 1, "b");
	min_chan = OceanodeParameter.kr(\min_chan, 0, 1, 0, 63, "i");
	max_chan = OceanodeParameter.kr(\max_chan, 63, 1, 0, 63, "i");
	invert   = OceanodeParameter.kr(\invert, 0, 1, 0, 1, "b");

	// New Index Parameter: Default is linear (0, 1, 2...)
	index    = OceanodeParameter.ar(\index, Array.series(n, 0, 1), n, 0, n, "vi");

	seedKr   = seed;
	reseedKr = reseed;
	randomKr = random;
	invertKr = invert;

	// Clamp min/max to valid range of steps (0 to n-1)
	min_chan = min_chan.asInteger.clip(0, n-1);
	max_chan = max_chan.asInteger.clip(0, n-1);
	min_chan = min_chan.min(max_chan);
	max_chan = max_chan.max(min_chan);

	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// --- LOGIC START ---

	// 1. Unified Reset Signal
	combinedReset = Trig.ar(K2A.ar(reset.asArray[0]) + K2A.ar(reseedKr > 0.5), SampleDur.ir);

	// 2. Resettable Clock (Phasor)
	phaseRate = hz.asArray[0] * SampleDur.ir;
	phase = Phasor.ar(combinedReset, phaseRate, 0, 1, 0);

	// Generate trigger when Phase wraps or on Reset
	rawTrig = (HPZ1.ar(phase) < 0) + combinedReset;

	// 3. Limit Triggers (fixednum) using Stepper
	totalTriggersSent = Stepper.ar(rawTrig, combinedReset, 0, 1000000, 1, 0);

	shouldTrigger = Select.ar(K2A.ar(fixednum > 0), [
		K2A.ar(1),
		K2A.ar(totalTriggersSent < K2A.ar(fixednum))
	]);

	// 4. Master Trigger
	trigWithReset = rawTrig * shouldTrigger;

	// 5. Sequence Counter (The "Step" Pointer)
	counter = Stepper.ar(trigWithReset, combinedReset, 0, 1000000, 1, 0);

	// 6. Step Calculation
	// Map the continuous counter to the min_chan/max_chan window
	currentStep = min_chan + (counter % (max_chan - min_chan + 1));

	// Invert logic (Invert the step pointer to read sequence backwards)
	currentStep = Select.ar(K2A.ar(invertKr > 0.5), [
		currentStep,
		max_chan - (currentStep - min_chan)
	]);

	// Random Step Logic
	RandID.ir(seedKr + 23);
	RandSeed.kr(
		(seedKr > 0) * (Changed.kr(seedKr) + (reseedKr > 0.5) + Impulse.kr(0)),
		(seedKr + 23).max(1)
	);

	// Random picks a random step within the min/max window
	randomStep = TIRand.ar(min_chan, max_chan, trigWithReset);

	// Selection (Sequential Step vs Random Step)
	currentStep = Select.ar(K2A.ar(randomKr > 0.5), [currentStep, randomStep]);

	// 7. Index Lookup (The Core Change)
	// Use the calculated step to look up the actual channel index from the vector
	channelIndex = Select.ar(currentStep, index.asArray);

	// Random Values Generation (for Chance)
	perChannelRand = Array.fill(n, {|i|
		RandID.ir(instanceID + (i * 1000));
		TRand.ar(0, 1, trigWithReset);
	});

	perChannelSeeded = Array.fill(n, {|i|
		RandID.ir(seedKr + i);
		RandSeed.kr(
			(seedKr > 0) * (Changed.kr(seedKr) + (reseedKr > 0.5) + Impulse.kr(0)),
			(seedKr + i).max(1)
		);
		TRand.ar(0, 1, trigWithReset);
	});

	// Output Generation
	signals = Array.fill(n, {|i|
		// Compare output channel (i) with the looked-up channel index
		var index_match = BinaryOpUGen.new('==', channelIndex, i);

		var thisChannelRand = Select.ar(
			K2A.ar(seedKr > 0),
			[perChannelRand[i], perChannelSeeded[i]]
		);

		var chance_test = BinaryOpUGen.new('<', thisChannelRand, chance.asArray[i]);

		trigWithReset * index_match * chance_test;
	});

	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Sequential metro with custom index vector support", category: "Modulation/Trigger");