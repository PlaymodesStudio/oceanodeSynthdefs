(
~synthCreator.value("Chance", {|n|
	var input, chanceProb, duplicate, seed, reseed, output;
	var normalChanceRand, seededChanceRand, instanceID;

	// Get the input trigger signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Chance probability parameter (0 = never pass, 1 = always pass)
	chanceProb = OceanodeParameterLag.ar(\chance, 0.5, n, 0, 1, "vf", 1/30, true);

	// Duplicate mode: Individual or Shared random generation
	duplicate = OceanodeParameterDropdown.kr(\duplicate, 0, n, "Individual:Shared");

	// Seed and reseed controls
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i"); // Single seed for all channels
	reseed = OceanodeParameter.ar(\reseed, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};

	// Create a unique instance ID using current time and random
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// Generate normal random (truly random, each synth gets unique generator)
	normalChanceRand = Array.fill(n, {|i|
		// Use instance ID for unseeded mode to ensure different synths are different
		RandID.ir(instanceID + (i * 1000));
		TRand.ar(0.0, 1.0, input.asArray[i]);
	});

	// Generate seeded random for chance - use seed + channel index
	seededChanceRand = Array.fill(n, {|i|
		// Use seed + channel index as random ID for related but different sequences per channel
		RandID.ir(seed + i); // Each channel gets seed+0, seed+1, seed+2, etc.
		// Reseed when seed changes OR when any reseed is triggered
		RandSeed.kr(
			(seed > 0) * (Changed.kr(seed) + (reseed.asArray.sum > 0) + Impulse.kr(0)),
			(seed + i).max(1)
		);
		TRand.ar(0.0, 1.0, input.asArray[i]);
	});

	// Apply probabilistic "chance" and "duplicate" logic with seeding
	output = Select.ar(duplicate, [
		// Individual mode: each channel gets its own random draw
		Array.fill(n, {|i|
			var chanceRand = Select.ar(
				(seed > 0), // If seed > 0, use seeded, else normal
				[normalChanceRand[i], seededChanceRand[i]]
			);
			input.asArray[i] * (chanceRand < chanceProb.asArray[i]);
		}),
		// Shared mode: one random draw, duped to all channels
		{
			var chanceRand = Select.ar(
				(seed > 0),
				[normalChanceRand[0], seededChanceRand[0]]
			);
			(input.asArray[0] * (chanceRand < chanceProb.asArray[0])).dup(n);
		}.value
	]);

	// Output the filtered trigger signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Randomly passes or blocks triggers based on chance probability with seed control", category: "Modulation/Random");
)