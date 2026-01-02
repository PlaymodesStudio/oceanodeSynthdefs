~synthCreator.value("ValueQuantizer", {|n|
	var beatTransport, valueIn, bypass;
	var gridResolution;
	var gridStep, gridChange, gridGate, gridTrig; // New stable grid variables
	var sampledValue, output;

	// --- Inputs ---
	beatTransport = OceanodeParameter.kr(\beattransport, 0, 1, 0, 1e12, "vf");
	valueIn = OceanodeParameter.ar(\in, 0, n, -1, 1, "vf");

	// --- Parameters ---
	gridResolution = OceanodeParameter.kr(\grid, 0.25, 1, 0.001, 16, "f");
	bypass = OceanodeParameter.kr(\bypass, 0, 1, 0, 1, "i");

	// --- 1. Robust Grid Logic ---
	// Calculate integer grid steps at Control Rate (Stable)
	gridStep = (beatTransport / gridResolution).floor;

	// Convert 'Change' to a wide Audio Rate Gate
	gridChange = Changed.kr(gridStep);
	gridGate = K2A.ar(gridChange);

	// Create a precise single-sample trigger
	gridTrig = Trig1.ar(gridGate > 0.1, SampleDur.ir);

	// --- 2. Quantization (Sample & Hold) ---
	// Simply sample the input exactly when the grid triggers
	sampledValue = Latch.ar(valueIn, gridTrig);

	// --- Output ---
	output = sampledValue;
	output = Select.ar(K2A.ar(bypass), [output, valueIn]);

	Out.ar(OceanodeOutput.kr(\out), output);
},
description: "Samples and holds input values at a rhythmic grid rate (Robust Timing).",
category: "Modulation/Sequencer");