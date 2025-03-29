(
~synthCreator.value("UnaryOps", {|n|
	var input, output, operation;

	// Get the input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Operation selector
	operation = OceanodeParameterDropdown.kr(\operation, 0, n, "Abs:Reciprocal:Invert:Square:Cube:Sqrt:Log:Sin:Cos:Tan:Tanh:Distort:Softclip:Clip");

	// Apply the selected operation
	output = Select.ar(operation, [
		input.abs,                 // Absolute value
		input.reciprocal,          // Reciprocal (1/x)
		1 - input,                 // Invert (1-x)
		input.squared,             // Squared
		input.cubed,               // Cubed
		input.sqrt,                // Square root
		input.log,                 // Natural logarithm
		input.sin,                 // Sine
		input.cos,                 // Cosine
		input.tan,                 // Tangent
		input.tanh,                // Hyperbolic tangent
		input.distort,             // Distortion
		input.softclip,            // Soft clipping
		input.clip2(0.5)           // Hard clipping at ±0.5
	]);


	// Output the signal with master level
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Applies unary operations to audio signals", category: "Utilities/Math");
)