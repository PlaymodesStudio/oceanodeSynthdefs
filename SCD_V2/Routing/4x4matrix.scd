(
~synthCreator.value("4x4Matrix", {|n|
	var output1, output2, output3, output4;
	var in1, in2, in3, in4;
	var route1, route2, route3, route4;
	var level;

	// Get input signals
	in1 = In.ar(OceanodeInput.kr(\in1), n);
	in2 = In.ar(OceanodeInput.kr(\in2), n);
	in3 = In.ar(OceanodeInput.kr(\in3), n);
	in4 = In.ar(OceanodeInput.kr(\in4), n);

	// Routing parameters (0-4 range)
	route1 = OceanodeParameterLag.kr(\route1, 0, n, 0, 4, "vf", 1/30, true);
	route2 = OceanodeParameterLag.kr(\route2, 1, n, 0, 4, "vf", 1/30, true);
	route3 = OceanodeParameterLag.kr(\route3, 2, n, 0, 4, "vf", 1/30, true);
	route4 = OceanodeParameterLag.kr(\route4, 3, n, 0, 4, "vf", 1/30, true);

	// Master level
	level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);

	// Calculate outputs with crossfading between adjacent channels
	output1 =
		// Input 1 routing (maps 0-1 and 3-4 ranges to output 1)
		(in1 * (1.0 - route1).clip(0, 1)) +
		(in1 * (route1 - 3.0).clip(0, 1)) +
		// Input 2 routing
		(in2 * (1.0 - route2).clip(0, 1)) +
		(in2 * (route2 - 3.0).clip(0, 1)) +
		// Input 3 routing
		(in3 * (1.0 - route3).clip(0, 1)) +
		(in3 * (route3 - 3.0).clip(0, 1)) +
		// Input 4 routing
		(in4 * (1.0 - route4).clip(0, 1)) +
		(in4 * (route4 - 3.0).clip(0, 1));

	output2 =
		// Input 1 routing
		(in1 * (1.0 - (route1 - 1.0).abs).clip(0, 1)) +
		// Input 2 routing
		(in2 * (1.0 - (route2 - 1.0).abs).clip(0, 1)) +
		// Input 3 routing
		(in3 * (1.0 - (route3 - 1.0).abs).clip(0, 1)) +
		// Input 4 routing
		(in4 * (1.0 - (route4 - 1.0).abs).clip(0, 1));

	output3 =
		// Input 1 routing
		(in1 * (1.0 - (route1 - 2.0).abs).clip(0, 1)) +
		// Input 2 routing
		(in2 * (1.0 - (route2 - 2.0).abs).clip(0, 1)) +
		// Input 3 routing
		(in3 * (1.0 - (route3 - 2.0).abs).clip(0, 1)) +
		// Input 4 routing
		(in4 * (1.0 - (route4 - 2.0).abs).clip(0, 1));

	output4 =
		// Input 1 routing
		(in1 * (1.0 - (route1 - 3.0).abs).clip(0, 1)) +
		// Input 2 routing
		(in2 * (1.0 - (route2 - 3.0).abs).clip(0, 1)) +
		// Input 3 routing
		(in3 * (1.0 - (route3 - 3.0).abs).clip(0, 1)) +
		// Input 4 routing
		(in4 * (1.0 - (route4 - 3.0).abs).clip(0, 1));

	// DC correction and sanitize outputs to prevent blowups
	output1 = LeakDC.ar(Sanitize.ar(output1)) * level;
	output2 = LeakDC.ar(Sanitize.ar(output2)) * level;
	output3 = LeakDC.ar(Sanitize.ar(output3)) * level;
	output4 = LeakDC.ar(Sanitize.ar(output4)) * level;

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out1), output1);
	Out.ar(OceanodeOutput.kr(\out2), output2);
	Out.ar(OceanodeOutput.kr(\out3), output3);
	Out.ar(OceanodeOutput.kr(\out4), output4);

}, description: "4x4 matrix router with interpolation", category: "Routing");
)