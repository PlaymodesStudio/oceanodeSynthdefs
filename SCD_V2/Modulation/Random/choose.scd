~synthCreator.value("Choose", {|n|
	var trigger, values, weights, size, duplicate, output, randomValue, cumulativeWeights, totalWeight, selectedValue;
	var seed, reseed, normalRandom, seededRandom, instanceID;
	var reseedTrig, combinedTrigger, sequenceCounter;
	var maxSize = 24;

	// Parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};
	size = OceanodeParameter.kr(\size, 4, 1, 1, 24, "vi"); // Size of values/weights arrays
	values = OceanodeParameter.ar(\values, 1, maxSize, -1024, 1024, "vf");
	weights = OceanodeParameter.ar(\weights, 0, maxSize, 0, 1, "vf");
	duplicate = OceanodeParameter.ar(\duplicate, 0, n, 0, 1, "vi");
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i"); // Single seed for all channels
	reseed = OceanodeParameter.ar(\reseed, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};

	// Create a unique instance ID using current time and random
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// Calculate total weight for normalization
	totalWeight = max(weights.sum, 0.001);

	// Create cumulative weights for selection
	cumulativeWeights = weights.integrate / totalWeight;

	// Create reseed trigger - detects any reseed button press
	reseedTrig = reseed.sum > 0;

	// Combined trigger: normal trigger OR reseed trigger
	combinedTrigger = Array.fill(n, {|i|
		trigger[i] + reseedTrig
	});

	// Generate normal random (truly random, each synth gets unique generator)
	normalRandom = Array.fill(n, {|i|
		// Use instance ID for unseeded mode to ensure different synths are different
		RandID.ir(instanceID + (i * 1000));
		TRand.ar(0, 1, combinedTrigger[i]);
	});

	// Generate deterministic seeded sequence
	seededRandom = Array.fill(n, {|i|
		var resetTrig;

		// Reset seed when reseed is pressed or seed changes - same as MetroSequential
		resetTrig = reseedTrig + Changed.kr(seed) + Impulse.kr(0);

		// Use the same approach as MetroSequential - simple RandSeed + TRand
		RandID.ir(seed + (i * 100)); // Give each channel separation
		RandSeed.kr(
			(seed > 0) * resetTrig,
			(seed + (i * 100)).max(1)
		);

		// Use TRand.ar - this actually works with seeding properly
		TRand.ar(0, 1, combinedTrigger[i]);
	});

	// Handle single vs multiple random selection with seeding
	randomValue = Select.ar(
		duplicate.asArray[0], // Fix: ensure we get first element as scalar
		[
			// Case 0: Individual mode - each channel chooses based on seed
			Array.fill(n, {|i|
				Select.ar(
					(seed > 0), // If seed > 0, use seeded, else normal
					[normalRandom[i], seededRandom[i]]
				)
			}),
			// Case 1: Duplicate mode - all channels use first channel's choice
			{
				var firstChannelRandom = Select.ar(
					(seed > 0),
					[normalRandom[0], seededRandom[0]]
				);
				firstChannelRandom.dup(n); // Properly duplicate to all channels
			}.value
		]
	);

	// Select value based on weighted probability per channel
	selectedValue = Array.fill(n, {|i|
		Select.ar(
			// Count how many cumulative weights are less than or equal to random value
			// This gives us the correct index for this channel
			(cumulativeWeights <= randomValue.asArray[i]).sum.min(maxSize - 1),
			values
		);
	});

	// Hold the value until next trigger or reseed (per channel)
	selectedValue = Array.fill(n, {|i|
		Latch.ar(selectedValue[i], combinedTrigger[i]);
	});

	// Output the selected values
	Out.ar(OceanodeOutput.kr(\out), selectedValue);

}, description: "Weighted random selection with immediate reseed output", category: "Modulation/Random");