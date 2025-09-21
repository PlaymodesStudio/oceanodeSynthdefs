(
~synthCreator.value("PanAz", {|n, variables|
	var source, signal, position, level, width, orientation, numSpeakers;
	numSpeakers = variables[0];
	position = OceanodeParameterLag.ar(\position, 0, n, 0, 2, "vf", 1/30, true);
	level = OceanodeParameter.kr(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	width = OceanodeParameter.kr(\width, 2, n, 0, 6, "vf");
	orientation = OceanodeParameter.kr(\orientation, 0.5, 1, 0, 1, "f");
	source = In.ar(OceanodeInput.kr(\in), n);
	source = source.asArray;
	signal = PanAz.ar(numSpeakers, source, position, level, width, orientation).flop.collect(Mix(_));
	Out.ar(OceanodeOutput.kr(\out), signal);
}, category: "Spatial/Panning", variables: ["NumSpeakers"], variableDimensions: [32]);
)














