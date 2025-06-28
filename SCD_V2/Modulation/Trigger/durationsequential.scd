~synthCreator.value("DurationSequential", {|n|
	var signals, durationVec;
	var index, stepTrig, reset, chance;
	var normalRand, seededRand, seed, reseed, instanceID;
	var perChannelRand, perChannelSeeded;
	var minDuration = 0.001; // Minimum duration in seconds to avoid timing issues
	var durationArray, rand_val;
	var resetTrig, combinedReset;
	var dutyTrig;

	// Parameters
	durationVec = OceanodeParameterLag.ar(\durationvec, 100, n, 1, 10000, "vf", 1/30, true); // Duration in ms for each channel
	chance = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, 1, 0, 1, "vi");
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i");
	reseed = OceanodeParameter.ar(\reseed, 0, 1, 0, 1, "vi");

	// Convert durations from ms to seconds and ensure minimum duration
	durationArray = if(n == 1,
		{ [(durationVec * 0.001).max(minDuration)] },
		{ (durationVec * 0.001).max(minDuration) }
	);

	// Combined reset trigger
	resetTrig = Trig.ar(K2A.ar(reset[0]) + (reseed > 0.5), SampleDur.ir);
	combinedReset = resetTrig;

	// Create instance ID for random values
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// For single channel, just trigger periodically
	if(n == 1, {
		// Use Duty for timed triggers
		dutyTrig = Duty.ar(durationArray[0], combinedReset, 1);
		stepTrig = Trig.ar(dutyTrig, SampleDur.ir);

		// Generate random value for chance
		normalRand = {
			RandID.ir(instanceID);
			TRand.ar(0, 1, stepTrig);
		}.value;

		seededRand = {
			RandID.ir(seed);
			RandSeed.kr(
				(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
				seed.max(1)
			);
			TRand.ar(0, 1, stepTrig);
		}.value;

		// Select between normal and seeded random
		rand_val = Select.ar(K2A.ar(seed > 0), [normalRand, seededRand]);

		// Apply chance
		signals = [stepTrig * (rand_val < chance[0])];
	}, {
		// Multi-channel case
		// Create a demand-rate sequence of durations
		var durSeq = Dseq(durationArray, inf);
		var indexSeq = Dseries(0, 1, inf) % n; // Cycles 0, 1, 2, ..., n-1, 0, 1, ...

		// Duty outputs a trigger after each duration in the sequence
		dutyTrig = Duty.ar(durSeq, combinedReset, 1);
		stepTrig = Trig.ar(dutyTrig, SampleDur.ir);

		// Get the current index using Demand
		index = Demand.ar(stepTrig + Impulse.ar(0), combinedReset, indexSeq);

		// Generate per-channel random values
		perChannelRand = Array.fill(n, {|i|
			RandID.ir(instanceID + (i * 1000));
			TRand.ar(0, 1, stepTrig);
		});

		perChannelSeeded = Array.fill(n, {|i|
			RandID.ir(seed + i);
			RandSeed.kr(
				(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
				(seed + i).max(1)
			);
			TRand.ar(0, 1, stepTrig);
		});

		// Create output signals
		signals = Array.fill(n, {|i|
			var index_match = BinaryOpUGen.new('==', index, i);
			var thisChannelRand = Select.ar(
				K2A.ar(seed > 0),
				[perChannelRand[i], perChannelSeeded[i]]
			);
			var chance_test = thisChannelRand < chance[i];

			// Output trigger when this channel is active and passes chance test
			stepTrig * index_match * chance_test;
		});
	});

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Sequential trigger with individual duration per channel", category: "Modulation/Trigger");