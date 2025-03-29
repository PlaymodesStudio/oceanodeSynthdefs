(
~synthCreator.value("RandomValues", {|n|
	var trigger, randomValue, bias, finalValue, rng, max, min, output, quantize;

	// Trigger input - generates a new random value when > 0.5
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};

	// Bias parameter - 0 biases toward 0, 1 biases toward, 0.5 is no bias
	bias = OceanodeParameterLag.ar(\bias, 0.5, n, 0, 1, "vf", 1/30, true);
	max = OceanodeParameter.ar(\max, 1, n, -1024, 1024, "vf");
	min = OceanodeParameter.ar(\min, 0, n, -1024, 1024, "vf");
	quantize = OceanodeParameter.ar(\iquantize, 0, n, 0, 1, "vi");

	// Generate basic random value between 0-1
	randomValue = TRand.ar(0, 1, trigger);

	rng=max-min;

	// Apply bias using power function
	finalValue = (randomValue.pow(2.0 * (1 - bias))*rng)+min;

	// Hold the value until next trigger (crucial for stable audio-rate modulation)
	finalValue = Latch.ar(finalValue, trigger);

	output = Select.ar(
		quantize,
		[
			finalValue, // No quantization
			finalValue.round(1) // Integer quantization
		]
	);

	// Output the random value
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Random number generator with trigger and bias controls", category: "Modulation/Random");
)