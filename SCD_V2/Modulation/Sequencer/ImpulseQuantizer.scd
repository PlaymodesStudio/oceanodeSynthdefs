~synthCreator.value("ImpulseQuantizer", {|n|
    var beatTransport, impulseIn, bypass;
    var gridResolution, gridStep, gridChange, gridGate, gridTrig;
    var inputCount, snappedCount, fire, output;

    // --- Inputs ---
    beatTransport = OceanodeParameter.kr(\beattransport, 0, 1, 0, 1e12, "vf");
    impulseIn = In.ar(OceanodeInput.kr(\in), n);

    // --- Parameters ---
    gridResolution = OceanodeParameter.kr(\grid, 0.25, 1, 0.001, 16, "f");
    bypass = OceanodeParameter.kr(\bypass, 0, 1, 0, 1, "i");

    // --- 1. Grid Logic ---
    // Calculate integers at Control Rate (Stable)
    gridStep = (beatTransport / gridResolution).floor;
    // Convert change to Audio Rate Gate
    gridChange = Changed.kr(gridStep);
    gridGate = K2A.ar(gridChange);
    // Create single-sample Grid Trigger
    gridTrig = Trig1.ar(gridGate > 0.1, SampleDur.ir);

    // --- 2. Quantizer Logic (Count & Compare) ---
    // Count input clicks
    inputCount = PulseCount.ar(impulseIn);

    // Snapshot the count at the Grid moment
    snappedCount = Latch.ar(inputCount, gridTrig);

    // If snapshot changed, FIRE.
    fire = HPZ1.ar(snappedCount).abs > 0.1;

    // --- 3. Output ---
    output = fire;
    output = Select.ar(K2A.ar(bypass), [output, impulseIn]);

    Out.ar(OceanodeOutput.kr(\out), output);
},
description: "Quantizes impulses using robust Pulse Counter logic (No Feedback).",
category: "Modulation/Sequencer");