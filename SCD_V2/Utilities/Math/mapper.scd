(
~synthCreator.value("Mapper", {|n|
	var input, output, minInput, maxInput, minOutput, maxOutput, quantize;

	// Get input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Input and output range parameters with more appropriate defaults for MIDI
	minInput = OceanodeParameterLag.ar(\mininput, 0, n, -100, 20000, "vf", 1/30, true);
	maxInput = OceanodeParameterLag.ar(\maxinput, 1, n, -100, 20000, "vf", 1/30, true);
	minOutput = OceanodeParameterLag.ar(\minoutput, 60, n, -100, 20000, "vf", 1/30, true);
	maxOutput = OceanodeParameterLag.ar(\maxoutput, 120, n, -100, 20000, "vf", 1/30, true);

	// Quantize option (0=off, 1=on)
	quantize = OceanodeParameter.ar(\iquantize, 0, n, 0, 1, "vi");

	// Map input values from input range to output range
	output = input.linlin(minInput, maxInput, minOutput, maxOutput);

	// Apply integer quantization if enabled
	output = Select.ar(
		quantize,
		[
			output, // No quantization
			output.round(1) // Integer quantization
		]
	);

	// Output the mapped value as continuous audio signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Maps input values from one range to another with optional integer quantization", category: "Utilities/Math");
)