(
~synthCreator.value("ChannelIndexInvert", {|n|
	var source, signal, invert, reversed;

	// Read input - OceanodeInput returns the bus number
	source = In.ar(OceanodeInput.kr(\in), n);
	source = source.asArray;

	// Invert parameter (0 or 1)
	invert = OceanodeParameter.kr(\invert, 0, n, 0, 1, "vi");

	// Create reversed version
	reversed = source.reverse;

	// Select between original and reversed based on invert parameter
	// We need to select per channel since invert can be multichannel
	signal = n.collect({|i|
		Select.ar(invert.at(i), [source.at(i), reversed.at(i)])
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Inverts channel order", category: "Routing");
)