(
~synthCreator.value("Arithmetic", {|n|
	var in1, in2, output, operation;
	// Get the two input signals
	in1 = In.ar(OceanodeInput.kr(\in1), n);
	in2 = In.ar(OceanodeInput.kr(\in2), n);
	// Operation selector (add, subtract, multiply, divide, modulo, exp, etc.)
	operation = OceanodeParameterDropdown.kr(\operation, 0, n, "Addition:Subtract:Multiply:Divide:Modulo:Max:Min:Pow");
	// Apply the selected operation
	output = Select.ar(operation, [
		in1 + in2,           // Add
		in1 - in2,           // Subtract
		in1 * in2,           // Multiply
		in1 / (in2 + 0.00001), // Divide (with small value to prevent division by zero)
		in1 % (in2 + 0.00001), // Modulo (with small value to prevent division by zero)
		in1.max(in2),        // Max
		in1.min(in2),        // Min
		in1 ** in2           // Exponential (in1 raised to power of in2) - Fixed to use ** operator
	]);
	// Output the signal with master level
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Performs arithmetic operations between two audio signals", category: "Utilities/Math");
)

gendy