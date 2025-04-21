(
~synthCreator.value("RandomValues", {|n|
	var trigger, randomValue, bias, finalValue, rng, max, min, output, quantize, duplicate;
	// Parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};
	bias = OceanodeParameterLag.ar(\bias, 0.5, n, 0, 1, "vf", 1/30, true);
	max = OceanodeParameter.ar(\max, 1, n, -1024, 1024, "vf");
	min = OceanodeParameter.ar(\min, 0, n, -1024, 1024, "vf");
	quantize = OceanodeParameter.ar(\iquantize, 0, n, 0, 1, "vi");
	duplicate = OceanodeParameter.ar(\duplicate, 0, n, 0, 1, "vi"); // New parameter

	// Handle single vs multiple random values
	randomValue = Select.ar(
		duplicate[0], // Use just the first value for the selection
		[
			// Case 0: Unique random value per channel (original behavior)
			TRand.ar(0, 1, trigger),

			// Case 1: Same random value for all channels
			TRand.ar(0, 1, trigger[0]).dup(n) // Generate once, duplicate for all channels
		]
	);

	rng = max - min;
	// Apply bias using power function
	finalValue = (randomValue.pow(2.0 * (1 - bias)) * rng) + min;
	// Hold the value until next trigger
	finalValue = Latch.ar(finalValue, trigger);

	output = Select.ar(
		quantize,
		[
			finalValue, // No quantization
			finalValue.round(1) // Integer quantization
		]
	);

	// Output the random values
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Random number generator with trigger and bias controls", category: "Modulation/Random");
)