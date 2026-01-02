(
~synthCreator.value("ChannelRouter", {|n|
	var input, routeTo, gain, compensation, output;

	// Input signal to be routed
	input = In.ar(OceanodeInput.kr(\in), n);

	// Gain for each input channel before routing
	gain = OceanodeParameter.ar(\gain, 1, n, 0, 1, "vf");

	// Compensation mode dropdown
	compensation = OceanodeParameterDropdown.kr(\compensation, 0, 1, "None:-3dB:-6dB");

	// Channel to route each input channel to (0-based index)
	routeTo = OceanodeParameter.ar(\routeto, 0, n, 0, 100, "vi");

	// Create output by checking which input should go to each output channel
	output = Array.fill(n, {|outChan|
		var sum = 0;
		var inputCount = 0;
		var compensationFactor;

		// First pass: count how many inputs route to this output
		n.do({|inChan|
			var match = (routeTo.at(inChan).round - outChan).abs < 0.5;
			inputCount = inputCount + match;
		});

		// Calculate compensation factor based on input count
		compensationFactor = Select.kr(compensation, [
			1,                           // None: no compensation
			(inputCount + 0.01).pow(-0.5),  // -3dB: 1/sqrt(N)
			(inputCount + 0.01).reciprocal  // -6dB: 1/N
		]);

		// Apply compensation only if multiple inputs route here
		compensationFactor = (inputCount > 1.5) * compensationFactor + (inputCount <= 1.5) * 1;

		// Second pass: sum all inputs that route to this output with compensation
		n.do({|inChan|
			var match = (routeTo.at(inChan).round - outChan).abs < 0.5;
			sum = sum + (input.at(inChan) * gain.at(inChan) * compensationFactor * match);
		});
		sum;
	});

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Routes each input channel to specific output channels n defines max output channels per-channel routing accepts int vectors", category: "Routing");
)