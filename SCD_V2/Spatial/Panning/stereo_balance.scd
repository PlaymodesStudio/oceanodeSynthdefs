(
~synthCreator.value("Balance", {|n, variables|
	var numSpeakers, input, balance, level, equalLoudness, gains, output;
	var inPositions, outPositions, mapped, totalGain, normalizationFactor;

	// Get number of output speakers from variables
	numSpeakers = variables[0];

	// Input signal - n channels
	input = In.ar(OceanodeInput.kr(\in), n);
	input = input.asArray;

	// Balance parameter: -1 (full left) to 1 (full right)
	balance = OceanodeParameterLag.ar(\balance, 0, 1, -1, 1, "vf", 1/30, true);

	// Level control with lincurve for natural dB scaling
	level = OceanodeParameterLag.ar(\levels, 1, 1, 0, 1, "vf", 1/30, true);

	// Equal loudness mode: 0 = normal, 1 = equal loudness
	equalLoudness = OceanodeParameter.kr(\equalloudness, 1, 1, 0, 1, "vi");

	// First, map input channels to output channels (upmix/downmix)
	// Create position arrays (normalize from -1 to 1 for stereo field)
	inPositions = Array.series(n, -1, 2/(n-1).max(1));
	outPositions = Array.series(numSpeakers, -1, 2/(numSpeakers-1).max(1));

	// Map each input channel to output channels
	mapped = Array.fill(numSpeakers, { |outIndex|
		var outPos = outPositions[outIndex];
		var weights = Array.fill(n, { |inIndex|
			var inPos = inPositions[inIndex];
			var distance = (outPos - inPos).abs;

			// Linear interpolation weight for nearby channels
			if(distance < (2.0/n.max(2))) {
				(1.0 - (distance * n.max(2) / 2.0)).max(0)
			} {
				0.0
			}
		});

		// Normalize weights
		weights = weights / weights.sum.max(0.000001);

		// Mix weighted inputs
		Mix(input * weights)
	});

	// Apply balance control with gain vector
	gains = Array.fill(numSpeakers, { |i|
		var speakerPos = outPositions[i];
		var distance = (speakerPos - balance).abs;
		var width = 2.0;  // Control spread of attenuation

		// Raised cosine window centered on balance position
		(cos((distance / width).clip(0, 1) * pi) + 1) * 0.5
	});

	// Calculate total power for equal loudness normalization
	totalGain = gains.sum({ |g| g.squared }).sqrt;

	// Apply normalization only if equal loudness mode is on
	normalizationFactor = Select.kr(
		(equalLoudness > 0) * (totalGain > 0),
		[1.0, 1.0 / totalGain]
	);
	gains = gains * normalizationFactor;

	// Apply gains to mapped signal
	output = mapped * gains * level;

	// Output multichannel signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Multichannel balance with equal loudness", category: "Spatial/Panning", variables: ["NumSpeakers"], variableDimensions: [16]);
)
