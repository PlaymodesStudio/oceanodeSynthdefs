(
~synthCreator.value("Quantize", {|n|
	var source, output;
	var qValues, numActive;
	var qSize = 128; // Maximum size for the quantization list

	// Get the input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Get the quantization list as a single array parameter
	qValues = OceanodeParameter.ar(\qvalues, Array.fill(qSize, {|i| i / (qSize - 1)}), n, 0, 1, "vf");

	// Get the number of active values to use
	// Limited to a range of 2-128 (need at least 2 values for meaningful quantization)
	 numActive = OceanodeParameter.kr(\numvalues, 5, n, 2, qSize, "i");

	// This is a more efficient approach without array operations
	// For each channel, we'll quantize using a fold/reduce pattern
	output = n.collect({ |channel|
		var inputSample = source[channel];
		var result = 0;
		var bestDist = 2; // Start with a value larger than maximum possible distance

		// We'll iterate through all possible quantization values
		qSize.do({ |i|
			var currentValue = qValues[i];
			var dist = (currentValue - inputSample).abs;
			var isActive = i < numActive;

			// If this value is active and closer than our current best,
			// update the result and best distance
			var shouldUpdate = isActive * (dist < bestDist);
			result = (shouldUpdate * currentValue) + ((1-shouldUpdate) * result);
			bestDist = (shouldUpdate * dist) + ((1-shouldUpdate) * bestDist);
		});

		result;
	});

	// Apply level control with proper dB scaling
	output = output * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Mix control between original and quantized signal
	output = (output * OceanodeParameter.ar(\amount, 1, n, 0, 1, "vf")) +
	         (source * (1 - OceanodeParameter.ar(\amount, 1, n, 0, 1, "vf")));

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Quantizes a signal to the nearest values in a list of up to 128 values", category: "Effects/Quantization");
)