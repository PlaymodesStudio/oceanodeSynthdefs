(
~synthCreator.value("CrossfadeAB", {|n|
	var inA, inB, xfade, output;

	// Get inputs
	inA = In.ar(OceanodeInput.kr(\ina), n);
	inB = In.ar(OceanodeInput.kr(\inb), n);

	// Crossfade parameter with lag for smooth transitions
	xfade = OceanodeParameterLag.ar(\xfade, 0.5, n, 0, 1, "vf", 1/30, true);

	// Use XFade2 for equal-power crossfading between the inputs
	output = XFade2.ar(inA, inB, xfade.linlin(0, 1, -1, 1));

	// Apply level control with proper dB scaling
	output = output * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Crossfade between two inputs", category: "Mixing");
)