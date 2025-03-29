(
~synthCreator.value("LogicOps", {|n|
	var in1, in2, output, operation;
	var threshold;
	var gt, lt, eq, neq, and, or, xor, nand, nor, xnor, ifThenElse;

	// Get the two input signals
	in1 = In.ar(OceanodeInput.kr(\in1), n);
	in2 = In.ar(OceanodeInput.kr(\in2), n);

	// Threshold for comparison operations
	threshold = OceanodeParameterLag.ar(\threshold, 0.5, n, 0, 1, "vf", 1/30, true);

	// Create binary comparison signals using UGens
	gt = BinaryOpUGen('>', in1, in2) * 1.0;
	lt = BinaryOpUGen('<', in1, in2) * 1.0;
	eq = BinaryOpUGen('<', (in1 - in2).abs, threshold * 0.1) * 1.0;
	neq = BinaryOpUGen('>=', (in1 - in2).abs, threshold * 0.1) * 1.0;

	// Boolean logic with threshold
	and = BinaryOpUGen('*', BinaryOpUGen('>', in1, threshold) * 1.0, BinaryOpUGen('>', in2, threshold) * 1.0);
	or = (BinaryOpUGen('>', in1, threshold) + BinaryOpUGen('>', in2, threshold)).min(1.0);
	xor = BinaryOpUGen('==', BinaryOpUGen('>', in1, threshold) + BinaryOpUGen('>', in2, threshold), 1) * 1.0;
	nand = 1.0 - and;
	nor = 1.0 - or;
	xnor = 1.0 - xor;
	ifThenElse = BinaryOpUGen('*', BinaryOpUGen('>', in1, threshold) * 1.0, in2);

	// Operation selector
	operation = OceanodeParameterDropdown.kr(\operation, 0, n, "GreaterThan:LessThan:Equal:NotEqual:AND:OR:XOR:NAND:NOR:XNOR:If-Then-Else");

	// Apply the selected operation
	output = Select.ar(operation, [
		gt,       // Greater Than
		lt,       // Less Than
		eq,       // Equal (with threshold)
		neq,      // Not Equal (with threshold)
		and,      // AND
		or,       // OR
		xor,      // XOR
		nand,     // NAND
		nor,      // NOR
		xnor,     // XNOR
		ifThenElse// If-Then-Else
	]);

	// Output the signal with master level
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Applies logic operations to audio signals", category: "Utilities/Math");
)