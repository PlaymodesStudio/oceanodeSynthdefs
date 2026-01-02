~synthCreator.value("SampleAndHold", {|n, variables|
	var input, gate, edge, valueOut, lastOut;
	var sampledValue, gateRising, prevGate;
	var lastValue, anyGateHigh;
	var edgeMode, gateMode;

	// Input parameters
	input = OceanodeParameter.ar(\input, 0, n, -1, 1, "vf"); // Input signal to sample
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi"); // Gate signal (0 or 1)
	edge = OceanodeParameter.kr(\edge, 1, 1, 0, 1, "b"); // Boolean: true=edge trigger, false=hold while high

	// Detect rising edge of gate
	prevGate = DelayN.ar(gate, 2/SampleRate.ir, 1/SampleRate.ir);
	gateRising = (gate - prevGate) > 0;

	// Edge mode: sample only on rising edge
	edgeMode = Latch.ar(input, gateRising);

	// Gate mode: track input while gate is high, hold when low
	gateMode = Select.ar(gate > 0.5, [
		Latch.ar(input, gateRising), // Gate low: hold last value
		input // Gate high: pass input through
	]);

	// Select between edge and gate mode based on edge parameter
	sampledValue = Select.ar(edge > 0.5, [
		gateMode,  // edge=false: gate mode
		edgeMode   // edge=true: edge mode
	]);

	valueOut = sampledValue;

	// Create mono "last" output - the most recent sampled value from any channel
	// Mix all gate triggers to detect if any channel had a rising edge
	anyGateHigh = Mix(gateRising) > 0;

	// When any gate rises, capture that channel's input value
	lastValue = Latch.ar(
		Mix(input * gateRising) / (Mix(gateRising) + 0.0001), // Avoid divide by zero
		anyGateHigh
	);

	lastOut = lastValue;

	// Outputs
	Out.ar(OceanodeOutput.kr(\output), valueOut);
	Out.ar(OceanodeOutput.kr(\last_mono), lastOut);

}, description: "Sample and Hold with edge/gate modes and last-value output", category: "Modulation/Utility");