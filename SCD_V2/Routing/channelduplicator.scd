(
~synthCreator.value("ChannelDuplicator", {|n|
	var input, indices, output;

	// Input signal to be duplicated
	input = In.ar(OceanodeInput.kr(\in), n);

	// Single parameter for indices - which input channel to use for each output
	// Allow values from -1 to n-1 (where -1 means silent)
	indices = OceanodeParameter.kr(\idx, 0, n, -1, 79, "vi").clip(-1, 79);

	// Create output array
	output = Array.fill(n, {|outChan|
		// Check if index is -1 (silent) or valid (0 to n-1)
		var index = indices.at(outChan);
		var isSilent = index < 0;

		// Select either silence or the appropriate input channel
		Select.ar(isSilent, [
			// Normal case: route from the specified input
			Select.ar(index, input),
			// Silent case: output zero
			DC.ar(0)
		])
	});

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Duplicates input channels according to index mapping", category: "Routing");
)