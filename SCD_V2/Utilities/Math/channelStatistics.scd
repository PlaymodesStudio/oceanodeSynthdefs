(
~synthCreator.value("ChannelStatistics", {|n, variables|
	var input, signal, operation;

	// Input bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Select operation based on dropdown (using kr instead of ar for operation)
	operation = OceanodeParameterDropdown.kr(\operation, 0, 1, "Sum:Average:Maximum:Minimum:RandomChannel:Multiply:Variance:AbsMax:RMS:CrossCorr:Difference");

	// Apply selected operation across channels to produce a single channel
	// Use Select.kr since operation is at control rate
	signal = K2A.ar(Select.kr(operation, [
		// Sum of all channels
		Mix.ar(input),

		// Average of all channels
		Mix.ar(input) / n.max(1),

		// Maximum value across channels
		input.asArray.reduce({ |a, b| a.max(b) }),

		// Minimum value across channels
		input.asArray.reduce({ |a, b| a.min(b) }),

		// Random channel selection
		input.asArray[n.rand],

		// Multiply all channels
		input.asArray.reduce({ |a, b| a * b }),

		// Variance
		{
			var mean = Mix.ar(input) / n.max(1);
			var deviations = input.asArray.collect({ |item| (item - mean).squared });
			Mix.ar(deviations) / n.max(1);
		},

		// Absolute maximum value
		input.asArray.collect(_.abs).reduce({ |a, b| a.max(b) }),

		// RMS (Root Mean Square)
		(Mix.ar(input.squared) / n.max(1)).sqrt,

		// Cross-correlation between channels
		if(n > 1, {
			Mix.ar(input[0] * input[1..]) / (n-1).max(1);
		}, { input[0] }),

		// Absolute difference between channels
		if(n > 1, {
			Mix.ar(input[0] - input[1..]).abs / (n-1).max(1);
		}, { 0 })
	]));

	// Apply level control with proper dB scaling
	signal = signal * OceanodeParameterLag.ar(\levels, 1, 1, 0, 1, "vf", 1/30, true);

	// Output the signal - single channel replicated to all outputs
	Out.ar(OceanodeOutput.kr(\out), Array.fill(n, { signal }));

}, description: "Global operations across all input channels", category: "Utilities/Math");
)