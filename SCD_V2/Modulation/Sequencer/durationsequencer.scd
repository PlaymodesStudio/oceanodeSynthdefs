~synthCreator.value("DurationSequencer", {|n|
	var signals, rhVec, bpm;
	var index, stepTrig, reset, chance;
	var normalRand, seededRand, seed, reseed, instanceID;
	var perChannelRand, perChannelSeeded;
	var minDuration = 0.001; // Minimum duration in seconds to avoid timing issues
	var durationArray, rand_val;
	var resetTrig, combinedReset;
	var dutyTrig, initialTrig;
	var beatDuration;

	// Parameters
	rhVec = OceanodeParameter.ar(\th_vec, 4, n, 1, 64, "vf"); // Rhythmic values (4 = quarter note, 8 = eighth note, etc.)
	bpm = OceanodeParameterLag.ar(\bpm, 120, 1, 1, 999, "vf", 1/30, true); // BPM parameter
	chance = OceanodeParameterLag.ar(\chance, 1, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, 1, 0, 1, "vi");
	seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i");
	reseed = OceanodeParameter.ar(\reseed, 0, 1, 0, 1, "vi");

	// Calculate beat duration in seconds (quarter note duration)
	beatDuration = 60 / bpm;

	// Convert rhythmic values to durations in seconds
	// rhVec of 4 = quarter note, 8 = eighth note, etc.
	// Duration = (4 / rhythmValue) * beatDuration
	durationArray = if(n == 1,
		{ [(4 / rhVec * beatDuration).max(minDuration)] },
		{ (4 / rhVec * beatDuration).max(minDuration) }
	);

	// Combined reset trigger
	resetTrig = Trig.ar(K2A.ar(reset[0]) + (reseed > 0.5), SampleDur.ir);
	combinedReset = resetTrig;
	initialTrig = Impulse.ar(0); // Initial trigger when synth starts

	// Create instance ID for random values
	instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

	// For single channel, just trigger periodically
	if(n == 1, {
		// Use TDuty for timed triggers (TDuty is more reliable than Duty)
		dutyTrig = TDuty.ar(durationArray[0], combinedReset + initialTrig, 1);
		stepTrig = dutyTrig;

		// Add initial trigger
		stepTrig = stepTrig + initialTrig;

		// Generate random value for chance
		normalRand = {
			RandID.ir(instanceID);
			TRand.ar(0, 1, stepTrig);
		}.value;

		seededRand = {
			RandID.ir(seed);
			RandSeed.kr(
				(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
				seed.max(1)
			);
			TRand.ar(0, 1, stepTrig);
		}.value;

		// Select between normal and seeded random
		rand_val = Select.ar(K2A.ar(seed > 0), [normalRand, seededRand]);

		// Apply chance
		signals = [stepTrig * (rand_val < chance[0])];
	}, {
		// Multi-channel case
		// Use a counter that increments with each trigger
		var counter = PulseCount.ar(Impulse.ar(0), combinedReset) - 1;

		// Create the trigger sequence using TDuty
		var durSeq = Dseq(durationArray, inf);
		dutyTrig = TDuty.ar(durSeq, combinedReset + initialTrig, 1);

		// Include initial trigger
		stepTrig = dutyTrig + initialTrig;

		// Calculate index from counter
		counter = PulseCount.ar(stepTrig, combinedReset);
		index = (counter - 1) % n;

		// Generate per-channel random values
		perChannelRand = Array.fill(n, {|i|
			RandID.ir(instanceID + (i * 1000));
			TRand.ar(0, 1, stepTrig);
		});

		perChannelSeeded = Array.fill(n, {|i|
			RandID.ir(seed + i);
			RandSeed.kr(
				(seed > 0) * (Changed.kr(seed) + (reseed > 0.5) + Impulse.kr(0)),
				(seed + i).max(1)
			);
			TRand.ar(0, 1, stepTrig);
		});

		// Create output signals
		signals = Array.fill(n, {|i|
			var index_match = BinaryOpUGen.new('==', index, i);
			var thisChannelRand = Select.ar(
				K2A.ar(seed > 0),
				[perChannelRand[i], perChannelSeeded[i]]
			);
			var chance_test = thisChannelRand < chance[i];

			// Output trigger when this channel is active and passes chance test
			stepTrig * index_match * chance_test;
		});
	});

	// Output the signals
	Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Sequential trigger with individual rhythm per channel", category: "Modulation/Sequencer");