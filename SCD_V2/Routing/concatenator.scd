(
~synthCreator.value("ChannelConcatenator", {|n, variables|
	var inputs, levels, output;

	// Read level controls for each of the 8 inputs
	levels = OceanodeParameter.ar(\levels, 1, 8, 0, 1, "vf");

	// Initialize array to hold all concatenated channels
	output = [];

	// Read each input and concatenate channels
	8.do({|i|
		var input, scaledInput;
		input = In.ar(OceanodeInput.kr(("in" ++ (i+1)).asSymbol), n);
		scaledInput = input * levels.at(i);
		output = output ++ scaledInput.asArray;
	});

	// Output the concatenated signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Concatenates 8 audio inputs into sequential channel array", category: "Routing");
)