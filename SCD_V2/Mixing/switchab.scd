~synthCreator.value("SwitchAB", {|n|
	var inA, inB, select, out;

	// Get input signals
	inA = In.ar(OceanodeInput.kr(\in_a), n);
	inB = In.ar(OceanodeInput.kr(\in_b), n);

	// Switch parameter: 0 = A, 1 = B
	select = OceanodeParameter.kr(\switch, 0, 1, 0, 1, "i");

	// Select between A and B for each channel
	out = Select.ar(K2A.ar(select), [inA, inB]);

	// Output
	Out.ar(OceanodeOutput.kr(\out), out);
}, description: "Switch between two inputs (A or B)", category: "Routing");
