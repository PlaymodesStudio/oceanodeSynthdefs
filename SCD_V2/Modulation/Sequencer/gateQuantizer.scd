~synthCreator.value("GateQuantizer", {|n|
	var beatTransport, gateIn, bypass;
	var gridResolution;
	var gridStep, gridChange, gridGate, gridTrig;
	var isHigh, gateRising;
	var memory, hasStartRequest, fireStart, nextMemory;
	var outputGate, capturedVelocity, output;

	// --- Inputs ---
	beatTransport = OceanodeParameter.kr(\beattransport, 0, 1, 0, 1e12, "vf");
	gateIn = OceanodeParameter.ar(\in, 0, n, -1, 1, "va");

	// --- Parameters ---
	gridResolution = OceanodeParameter.kr(\grid, 0.25, 1, 0.001, 16, "f");
	bypass = OceanodeParameter.kr(\bypass, 0, 1, 0, 1, "i");

	// --- 1. Robust Grid Logic ---
	gridStep = (beatTransport / gridResolution).floor;
	gridChange = Changed.kr(gridStep);
	gridGate = K2A.ar(gridChange);
	gridTrig = Trig1.ar(gridGate > 0.1, SampleDur.ir);

	// --- 2. Input Analysis ---
	// Detect Start: Signal goes from near-zero to active
	isHigh = gateIn.abs > 0.01;
	gateRising = Trig1.ar(isHigh, SampleDur.ir);

	// --- 3. Start Request Latch ---
	// "Remember" that a start happened until the grid arrives
	memory = LocalIn.ar(n);

	// Set memory if rising edge detected
	hasStartRequest = (memory + gateRising).clip(0, 1);

	// Fire Start if Request is ON and Grid is HERE
	fireStart = hasStartRequest * gridTrig;

	// Clear memory if fired
	nextMemory = Select.ar(fireStart > 0.5, [hasStartRequest, DC.ar(0)]);
	LocalOut.ar(nextMemory);

	// --- 4. Value Capture (Velocity) ---
	// We want to output the EXACT value the gate had when it started.
	// We latch the input value at the moment the 'fireStart' happens.
	// NOTE: We rely on 'gateIn' still being high. If it was a short trigger,
	// we might need to Latch the value at 'gateRising' instead.
	// Let's be safe and Latch at rising edge, then hold it.
	capturedVelocity = Latch.ar(gateIn, gateRising); // Capture instantly
	capturedVelocity = Latch.ar(capturedVelocity, fireStart); // Update output on grid

	// --- 5. Gate Generation ---
	// Open gate on 'fireStart', Close gate when input 'isHigh' drops to 0.
	outputGate = SetResetFF.ar(fireStart, 1 - isHigh);

	// Apply the captured velocity to the generated gate
	output = outputGate * capturedVelocity;

	// --- Output ---
	output = Select.ar(K2A.ar(bypass), [output, gateIn]);

	Out.ar(OceanodeOutput.kr(\out), output);
},
description: "Quantizes gate starts to a rhythmic grid, preserving amplitude/velocity.",
category: "Modulation/Sequencer");