~synthCreator.value("indexSequencer", {|n, variables|
	var index, values, valueOut;
	var maxSteps;

	// Maximum number of steps
	maxSteps = 64;

	// Input parameters
	index = OceanodeParameter.ar(\index, 0, n, 0, maxSteps-1, "vi"); // Index selector (0 to maxSteps-1)
	values = OceanodeParameter.ar(\values, 0, maxSteps, 0, 1, "vf"); // Values array

	// Clip index to valid range
	index = index.clip(0, maxSteps - 1);

	// Select the value at the current index
	valueOut = Select.ar(index, values);

	// Output the selected value
	Out.ar(OceanodeOutput.kr(\valueout), valueOut);

}, description: "Index-based sequencer - selects values from array based on index input", category: "Modulation/Sequencer");