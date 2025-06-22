(
~synthCreator.value("MetroSequential", {|n|
	var signals, trig, reset_trig, index_seq, current_index, rand_val;
	var hz, chance, reset, seed, reseed;
	var normalRand, seededRand, instanceID, combinedReset;

	// Parameters with proper unit tags
	hz = OceanodeParameterLag.ar(\hz, 1, n, 0.01, 60, "vf", 1/30, true);
	chance = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i"); // Single seed for all channels
	reseed = OceanodeParameter.ar(\reseed, 0, 1, 0, 1, "vi"); // Single reseed trigger

	// Create a unique instance ID using current time and random
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// Base trigger at rate hz[0]
	trig = Impulse.ar(hz[0]);

	// Combine reset and reseed - reseed forces a reset to sync timing
	combinedReset = Trig.ar(K2A.ar(reset[0]) + (reseed > 0.5), SampleDur.ir);

	// Define a demand-rate sequence that cycles through indices
	index_seq = Dseq((0..(n-1)), inf);

	// Make the sequence advance on each trigger, reset on combinedReset
	current_index = Demand.ar(trig, combinedReset, index_seq);

	// Generate normal random (truly random, unique per synth instance)
	normalRand = {
		RandID.ir(instanceID);
		TRand.ar(0, 1, trig);
	}.value;

	// Generate seeded random for chance - use single seed for consistency
	seededRand = {
		// Use seed value as random ID for consistent sequences
		RandID.ir(seed);
		// Reseed when seed changes OR when reseed is triggered (which also resets sequence)
		RandSeed.kr(
			(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
			seed.max(1)
		);
		TRand.ar(0, 1, trig);
	}.value;

	// Select between normal and seeded random based on seed value
	rand_val = Select.ar(
		(seed > 0), // If seed > 0, use seeded, else normal
		[normalRand, seededRand]
	);

	// Create output array using a safer approach with BinaryOpUGen
	signals = Array.fill(n, {|i|
		// Use BinaryOpUGen.new to ensure we get a UGen, not a Boolean
		var index_match = BinaryOpUGen.new('==', current_index, i);
		var chance_test = BinaryOpUGen.new('<', rand_val, chance[i]);

		// Output a trigger only when index matches and passes chance test
		trig * index_match * chance_test;
	});

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Metro generator with synchronized reset and reseed for consistent timing", category: "Modulation/Trigger");
)