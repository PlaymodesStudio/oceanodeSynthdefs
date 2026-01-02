(
~synthCreator.value("XPanAz", {|n, variables|
	var source, signal, position, level, width, rotation, numSpeakers, frontPos, backPos, frontSignals, backSignals;
	numSpeakers = variables[0];
	position = OceanodeParameterLag.kr(\position, 0.5, n, 0, 1, "vf", 1/30, true);
	level = OceanodeParameterLag.kr(\level, 1, n, 0, 1, "vf", 1/30, true);
	width = OceanodeParameter.kr(\width, 2, n, 0, 2, "vf");
	rotation = OceanodeParameter.kr(\rotation, 0, n, -1, 1, "vf");

	source = In.ar(OceanodeInput.kr(\in), n);
	source = source.asArray;

	// Calculate front and back positions
	 frontPos = (position * 2 - 1).wrap(-1, 1); // position: 0->-1, 0.5->0, 1->1
	 backPos = (position * -2 + 1).wrap(-1, 1); // position: 0->1, 0.5->0, 1->-1

	// Add rotation
	frontPos = (frontPos + rotation).wrap(-1, 1);
	backPos = (backPos + rotation).wrap(-1, 1);

	// Create front and back signals
	 frontSignals = PanAz.ar(numSpeakers, source, frontPos, level, width);
	 backSignals = PanAz.ar(numSpeakers, source, backPos, level, width);

	// Mix front and back signals
	signal = (frontSignals + backSignals) * 0.5;

	// Collect and sum channels
	signal = signal.flop.collect(Mix(_));

	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Cross panning with front and back distribution", category: "Spatial/Panning", variables: ["NumSpeakers"], variableDimensions: [32]);
)