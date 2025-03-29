(
~synthCreator.value("ChannelRouter", {|n|
	var input, routeTo, output;

	// Input signal to be routed
	input = In.ar(OceanodeInput.kr(\in), n);

	// Channel to route the signal to (0-based index)
	routeTo = OceanodeParameter.ar(\routeto, 0, n, 0, 80, "vi");

	// Create a multichannel array of zeros
	output = Array.fill(n, 0);

	// For each output channel
	n.do({|i|
		// Instead of direct comparison, calculate absolute difference and check if it's small enough
		var match = (routeTo.round - i).abs < 0.01;

		// Then convert to 0.0 or 1.0 by multiplying by 1.0
		var gain = match * 1.0;

		// Apply the gain to route the input to the right channel
		output[i] = input * gain;
	});

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Routes input signal to a specific channel", category: "Routing");
)