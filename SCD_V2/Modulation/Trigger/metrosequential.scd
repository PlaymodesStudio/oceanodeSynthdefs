~synthCreator.value("MetroSequential", {|n|
	var signals, trig, reset_trig, index_seq, current_index, rand_val;
	var hz, chance, reset, seed, reseed;
	var normalRand, seededRand, instanceID, combinedReset;
	var perChannelRand, perChannelSeeded; // Per-channel random values

	// Parameters with proper unit tags
	hz = OceanodeParameterLag.ar(\hz, 1, n, 0.01, 60, "vf", 1/30, true);
	chance = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i"); // Single seed for all channels
	reseed = OceanodeParameter.ar(\reseed, 0, 1, 0, 1, "vi"); // Single reseed trigger

	// Create a deterministic instance ID - only use time-based ID for unseeded mode
	// For seeded mode, we want pure determinism
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// Base trigger at rate hz[0]
	trig = Impulse.ar(hz[0]);

	// Combine reset and reseed - reseed forces a reset to sync timing
	combinedReset = Trig.ar(K2A.ar(reset[0]) + (reseed > 0.5), SampleDur.ir);

	// Define a demand-rate sequence that cycles through indices
	index_seq = Dseq((0..(n-1)), inf);

	// Make the sequence advance on each trigger, reset on combinedReset
	current_index = Demand.ar(trig, combinedReset, index_seq);

	// FIX: Generate per-channel random values with deterministic seeding
	// This ensures the same random value is always used for the same channel index
	perChannelRand = Array.fill(n, {|i|
		// For unseeded mode, use instanceID (will be different each time)
		// For seeded mode, this won't be used anyway
		RandID.ir(instanceID + (i * 1000));
		TRand.ar(0, 1, trig);
	});

	perChannelSeeded = Array.fill(n, {|i|
		// FIX: Use ONLY the seed for deterministic sequences
		// This ensures the same sequence every time the synth is created
		RandID.ir(seed + i); // Pure determinism - no instanceID involved
		RandSeed.kr(
			(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
			(seed + i).max(1) // Use seed directly for the random seed value
		);
		TRand.ar(0, 1, trig);
	});

	// Create output array with proper per-channel chance testing
	signals = Array.fill(n, {|i|
		// Use BinaryOpUGen.new to ensure we get a UGen, not a Boolean
		var index_match = BinaryOpUGen.new('==', current_index, i);

		// FIX: Use the random value that corresponds to THIS channel
		// Select between normal and seeded random for this specific channel
		var thisChannelRand = Select.ar(
			(seed > 0), // If seed > 0, use seeded, else normal
			[perChannelRand[i], perChannelSeeded[i]]
		);

		var chance_test = BinaryOpUGen.new('<', thisChannelRand, chance.asArray[i]);

		// Output a trigger only when index matches and passes chance test
		trig * index_match * chance_test;
	});

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Sequential metro with consistent per-channel random values tied to sequence position", category: "Modulation/Trigger");