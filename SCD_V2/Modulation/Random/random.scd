~synthCreator.value("RandomValues", {|n|
	var trigger, randomValue, bias, finalValue, rng, max, min, output, quantize, duplicate;
	var seed, reseed, normalRandom, seededRandom, instanceID;

	// Parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};
	bias = OceanodeParameterLag.ar(\bias, 0.5, n, 0, 1, "vf", 1/30, true);
	max = OceanodeParameter.ar(\max, 1, n, -1024, 1024, "vf");
	min = OceanodeParameter.ar(\min, 0, n, -1024, 1024, "vf");
	quantize = OceanodeParameter.ar(\iquantize, 0, n, 0, 1, "vi");
	duplicate = OceanodeParameter.ar(\duplicate, 0, n, 0, 1, "vi");

	// FIX 1: Use single seed for all channels for consistency
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "vi"); // Single seed value
	reseed = OceanodeParameter.ar(\reseed, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};

	// Create a unique instance ID using current time and random
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// Generate normal random (truly random, each synth gets unique generator)
	normalRandom = Array.fill(n, {|i|
		// Use instance ID for unseeded mode to ensure different synths are different
		RandID.ir(instanceID + (i * 1000));
		TRand.ar(0, 1, trigger[i]);
	});

	// FIX 2: Generate seeded random with proper seed management
	seededRandom = Array.fill(n, {|i|
		// Use seed + channel index as random ID for related but different sequences per channel
		RandID.ir(seed + i); // Each channel gets seed+0, seed+1, seed+2, etc.

		// FIX 3: Synchronize reseeding across all channels
		// Reseed when seed changes OR when ANY reseed is triggered (for sync)
		RandSeed.kr(
			(seed > 0) * (Changed.kr(seed) + (reseed.asArray.sum > 0) + Impulse.kr(0)),
			(seed + i).max(1)
		);
		TRand.ar(0, 1, trigger[i]);
	});

	// FIX 4: Fix the Select structure for duplicate mode
	randomValue = Select.ar(
		duplicate.asArray[0], // Use first channel's duplicate setting
		[
			// Individual mode: each channel chooses based on seed
			Array.fill(n, {|i|
				Select.ar(
					(seed > 0), // Use single seed value for all channels
					[normalRandom[i], seededRandom[i]]
				)
			}),
			// Duplicate mode: all channels use first channel's random value
			{
				var firstChannelRandom = Select.ar(
					(seed > 0),
					[normalRandom[0], seededRandom[0]]
				);
				firstChannelRandom.dup(n); // Duplicate to all channels
			}.value
		]
	);

	// Apply bias and range scaling
	rng = max.asArray - min.asArray;

	// Apply bias using power function
	finalValue = Array.fill(n, {|i|
		(randomValue.asArray[i].pow(2.0 * (1 - bias.asArray[i])) * rng[i]) + min.asArray[i];
	});

	// FIX 5: Hold the value until next trigger (per channel)
	finalValue = Array.fill(n, {|i|
		Latch.ar(finalValue[i], trigger[i]);
	});

	// Apply quantization per channel
	output = Array.fill(n, {|i|
		Select.ar(
			quantize.asArray[i],
			[
				finalValue[i], // No quantization
				finalValue[i].round(1) // Integer quantization
			]
		);
	});

	// Output the random values
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Random number generator with synchronized seeds and bias controls", category: "Modulation/Random");