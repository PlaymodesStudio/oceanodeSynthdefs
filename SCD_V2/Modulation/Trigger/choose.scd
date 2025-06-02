~synthCreator.value("Choose", {|n|
	var trigger, values, weights, size, duplicate, output, randomValue, cumulativeWeights, totalWeight, selectedValue;
	var maxSize = 24;

	// Parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};
	size = OceanodeParameter.kr(\size, 4, 1, 1, 24, "vi"); // Size of values/weights arrays
	values = OceanodeParameter.ar(\values, 1, maxSize, -1024, 1024, "vf");
	weights = OceanodeParameter.ar(\weights, 0, maxSize, 0, 1, "vf");
	duplicate = OceanodeParameter.ar(\duplicate, 0, n, 0, 1, "vi");

	// Calculate total weight for normalization
	totalWeight = max(weights.sum, 0.001);

	// Create cumulative weights for selection
	cumulativeWeights = weights.integrate / totalWeight;

	// Handle single vs multiple random selection
	randomValue = Select.ar(
		duplicate[0],
		[
			// Case 0: Unique random value per channel (original behavior)
			TRand.ar(0, 1, trigger),
			// Case 1: Same random value for all channels
			TRand.ar(0, 1, trigger[0]).dup(n)
		]
	);

	// Select value based on weighted probability
	// Find the first cumulative weight that is greater than the random value
	selectedValue = Select.ar(
		// Count how many cumulative weights are less than or equal to random value
		// This gives us the correct index
		(cumulativeWeights <= randomValue).sum.min(maxSize - 1),
		values
	);

	// Hold the value until next trigger
	selectedValue = Latch.ar(selectedValue, trigger);

	// Output the selected values
	Out.ar(OceanodeOutput.kr(\out), selectedValue);
}, description: "Weighted random selection from a list of values", category: "Modulation/Random");