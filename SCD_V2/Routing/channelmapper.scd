(
~synthCreator.value("ChannelMapper", {|n|
	var input, mapping, gaincomp, output, channelSum, targetOutput, isValidMapping, shouldRoute, inputCount, finalOutput;

	// Input audio
	input = In.ar(OceanodeInput.kr(\in), n);

	// Mapping parameter - default to sequential 1,2,3,4...
	mapping = OceanodeParameter.ar(\mapping, (1..n), n, 0, n, "vi");

	// Gain compensation on/off
	gaincomp = OceanodeParameter.ar(\gaincomp, 1, n, 0, 1, "vi");

	// Create output channels by processing the mapping
	output = Array.fill(n, { |outputIndex|

		// For each output channel, sum all inputs that map to it
		channelSum = Mix.fill(n, { |inputIndex|

			// Get target output channel (convert from 1-based to 0-based)
			targetOutput = (Select.ar(inputIndex, mapping) - 1).max(0).min(n-1);

			// Check if mapping is valid
			isValidMapping = (Select.ar(inputIndex, mapping) >= 1) *
			                (Select.ar(inputIndex, mapping) <= n);

			// Check if this input should route to current output
			shouldRoute = ((targetOutput - outputIndex).abs < 0.5) * isValidMapping;

			// Return the input signal if it should route here, 0 otherwise
			Select.ar(inputIndex, input) * shouldRoute;
		});

		// Calculate gain compensation by counting inputs mapped to this output
		inputCount = Mix.fill(n, { |inputIndex|
			targetOutput = (Select.ar(inputIndex, mapping) - 1).max(0).min(n-1);
			isValidMapping = (Select.ar(inputIndex, mapping) >= 1) *
			                (Select.ar(inputIndex, mapping) <= n);
			((targetOutput - outputIndex).abs < 0.5) * isValidMapping;
		}).max(1);

		// Apply gain compensation if enabled, otherwise pass through
		finalOutput = Select.ar(Select.ar(outputIndex, gaincomp), [
			channelSum,           // No gain compensation
			channelSum / inputCount  // With gain compensation
		]);

		finalOutput;
	});

	// Output the mapped channels
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Routes input channels to output channels with configurable mapping", category: "Routing");
)