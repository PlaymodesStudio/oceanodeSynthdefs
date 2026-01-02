// ------------------------------------------------------------
// MetroSequential
// Generates sequential impulses (Internal Clock)
// FIXED: Uses Stepper for guaranteed 0-based start on reset
// ------------------------------------------------------------
~synthCreator.value("MetroSequential", {|n|
	var signals, trig;
	var hz, chance, reset, seed, reseed, fixednum, random;
	var normalRand, seededRand, instanceID, combinedReset;
	var perChannelRand, perChannelSeeded;
	var shouldTrigger, totalTriggersSent;
	var randomIndex, currentIndex;
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

	seedKr   = seed;
	reseedKr = reseed;
	randomKr = random;
	invertKr = invert;

	min_chan = min_chan.asInteger.clip(0, n-1);
	max_chan = max_chan.asInteger.clip(0, n-1);
	min_chan = min_chan.min(max_chan);
	max_chan = max_chan.max(min_chan);

	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// --- LOGIC FIX START ---

	// 1. Unified Reset Signal
	combinedReset = Trig.ar(K2A.ar(reset.asArray[0]) + K2A.ar(reseedKr > 0.5), SampleDur.ir);

	// 2. Resettable Clock (Phasor)
	phaseRate = hz.asArray[0] * SampleDur.ir;
	phase = Phasor.ar(combinedReset, phaseRate, 0, 1, 0);

	// Generate trigger when Phase wraps or on Reset
	rawTrig = (HPZ1.ar(phase) < 0) + combinedReset;

	// 3. Limit Triggers (fixednum) using Stepper
	// Stepper ensures that on the frame where reset is high, the output is exactly 0.
	// Arguments: Stepper.ar(trig, reset, min, max, step, resetval)
	totalTriggersSent = Stepper.ar(rawTrig, combinedReset, 0, 1000000, 1, 0);

	shouldTrigger = Select.ar(K2A.ar(fixednum > 0), [
		K2A.ar(1),
		// 0 < 4 (True), 1 < 4 (True), ... 3 < 4 (True), 4 < 4 (False)
		// This allows exactly 4 triggers: indices 0, 1, 2, 3.
		K2A.ar(totalTriggersSent < K2A.ar(fixednum))
	]);

	// 4. Master Trigger
	trigWithReset = rawTrig * shouldTrigger;

	// 5. Sequence Counter using Stepper
	// Reset forces output to 0 immediately, ignoring the trigger increment for that sample.
	counter = Stepper.ar(trigWithReset, combinedReset, 0, 1000000, 1, 0);

	// 6. Index Calculation
	// Counter is 0 on the reset frame -> Channel 1 (min_chan + 0)
	currentIndex = counter;

	// --- LOGIC FIX END ---

	// Wrap index to sequence range
	currentIndex = min_chan + (currentIndex % (max_chan - min_chan + 1));

	// Invert logic
	currentIndex = Select.ar(K2A.ar(invertKr > 0.5), [
		currentIndex,
		max_chan - (currentIndex - min_chan)
	]);

	// Random Index Logic
	RandID.ir(seedKr + 23);
	RandSeed.kr(
		(seedKr > 0) * (Changed.kr(seedKr) + (reseedKr > 0.5) + Impulse.kr(0)),
		(seedKr + 23).max(1)
	);
	randomIndex = TIRand.ar(min_chan, max_chan, trigWithReset);

	// Selection (Sequential vs Random)
	currentIndex = Select.ar(K2A.ar(randomKr > 0.5), [currentIndex, randomIndex]);

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
		var index_match = BinaryOpUGen.new('==', currentIndex, i);

		var thisChannelRand = Select.ar(
			K2A.ar(seedKr > 0),
			[perChannelRand[i], perChannelSeeded[i]]
		);

		var chance_test = BinaryOpUGen.new('<', thisChannelRand, chance.asArray[i]);

		trigWithReset * index_match * chance_test;
	});

	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Sequential or random metro with consistent per-channel random values", category: "Modulation/Trigger");