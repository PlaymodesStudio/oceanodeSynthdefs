(
~synthCreator.value("MetroSequential", {|n|
	var signals, trig, reset_trig, index_seq, current_index, rand_val;
	var hz, chance, reset;
	var i;

	// Parameters with proper unit tags
	hz = OceanodeParameterLag.ar(\hz, 1, n, 0.01, 60, "vf", 1/30, true);
	chance = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Base trigger at rate hz[0]
	trig = Impulse.ar(hz[0]);

	// Reset trigger - just use the first reset parameter
	reset_trig = Trig.ar(K2A.ar(reset[0]), SampleDur.ir);

	// Define a demand-rate sequence that cycles through indices
	index_seq = Dseq((0..(n-1)), inf);

	// Make the sequence advance on each trigger, reset on reset_trig
	current_index = Demand.ar(trig, reset_trig, index_seq);

	// Generate one random value per trigger
	rand_val = TRand.ar(0, 1, trig);

	// Create output array using a safer approach with BinaryOpUGen
	signals = Array.fill(n, {|i|
		// Use BinaryOpUGen.new to ensure we get a UGen, not a Boolean
		var index_match = BinaryOpUGen.new('==', current_index, i);
		var chance_test = BinaryOpUGen.new('<', rand_val, chance[i]);

		// Output a trigger only when index matches and passes chance test
		trig * index_match * chance_test;
	});

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Metro generator that routes pulses sequentially with probability", category: "Modulation/Trigger");
)