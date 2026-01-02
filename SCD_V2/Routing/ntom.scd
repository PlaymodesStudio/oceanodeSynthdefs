(
~synthCreator.value("NtoM", {|n, variables|
	var m, source, inPositions, outPositions, signal, i, weights, sumWeights;

	// Get number of output channels from variables
	m = variables[0];

	// Get input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	source = source.asArray;

	// Create position arrays (normalize from 0 to 1)
	inPositions = (0..(n-1)) / (n-1);
	outPositions = (0..(m-1)) / max(m-1, 1); // Protect against division by zero when m=1

	// Create output array
	signal = Array.fill(m, 0);

	// For each output channel, calculate its value based on weighted input contributions
	m.do{|outIndex|
		var outPos = outPositions[outIndex];
		weights = Array.fill(n, {|inIndex|
			var inPos = inPositions[inIndex];
			var distance = abs(outPos - inPos);

			// Linear interpolation weight (inverse of distance, limited to nearest channels)
			if(distance < (1.0/(max(n-1, 1)))) {
				// Use linear falloff based on distance
				max(0, 1.0 - (distance * max(n-1, 1)))
			} {
				0.0 // Only use nearest channels
			}
		});

		// Normalize weights so they sum to 1
		sumWeights = max(weights.sum, 0.000001); // Avoid division by zero
		weights = weights / sumWeights;

		// Calculate output as weighted sum of inputs
		signal[outIndex] = Mix.ar(source * weights);
	};

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Channel count converter with interpolation", category: "Routing", variables: ["NumOut"], variableDimensions: [32]);
)