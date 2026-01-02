(
~synthCreator.value("Panner", {|n, variables|
	var source, signal, position, level, width, numSpeakers;
	numSpeakers = variables[0];
	position = OceanodeParameterLag.ar(\position, 0, n, 0, 1, "vf", 1/30, true);
	level = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf");
	width = OceanodeParameter.kr(\width, 2, n, 0, 2, "vf");
	source = In.ar(OceanodeInput.kr(\in), n);
	source = source.asArray;
	signal = PanX.ar(numSpeakers, source, position, level, width).flop.collect(Mix(_));
	Out.ar(OceanodeOutput.kr(\out), signal);
}, category: "Spatial/Panning", variables: ["NumSpeakers"], variableDimensions: [32]);
)