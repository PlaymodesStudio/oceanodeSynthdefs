(
~synthCreator.value("XORSequencer", {|n|
	var clock, trig, register, output, finalSig;
	var mode, bitSelect, change, chance, numBits, resetval, reset, resetTrig;
	var clockHz, basePitch, quantSteps, scale, levels;
	var combinedTrig;

	// Parameters following Oceanode conventions
	clockHz = OceanodeParameterLag.ar(\clockhz, 4, n, 0.1, 32, "vf", 1/30, true);
	change = OceanodeParameterLag.ar(\change, 0.5, n, 0, 1, "vf", 1/30, true);
	chance = OceanodeParameterLag.ar(\chance, 0.5, n, 0, 1, "vf", 1/30, true);
	numBits = OceanodeParameter.kr(\numbits, 8, n, 1, 16, "vi");
	resetval = OceanodeParameter.kr(\seed, 170, n, 0, 65535, "vi");

	// Reset parameter - resets the sequence when triggered
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Mode selection: 0 = Pitch Mode, 1 = Gate Mode
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Pitch:Gate");
	bitSelect = OceanodeParameter.kr(\bitselect, 0, n, 0, 15, "vi");

	// Musical parameters
	basePitch = OceanodeParameterLag.ar(\basepitch, 60, n, 0, 127, "vf", 1/30, true);
	quantSteps = OceanodeParameter.ar(\quantsteps, 8, n, 1, 16, "vi");
	scale = OceanodeParameterLag.ar(\scale, 12, n, 1, 24, "vf", 1/30, true);

	// Clock trigger
	clock = Impulse.kr(clockHz);

	// Create reset trigger from reset parameter
	resetTrig = Trig.kr(reset, 0.001);

	// Create a new trigger that includes both clock and reset
	// When reset fires, it forces a new DNoiseRing evaluation
	combinedTrig = clock + resetTrig;

	// Use a Gate to control the DNoiseRing - when reset is high, restart
	register = Demand.kr(combinedTrig, 0,
		DNoiseRing(
			change: change,
			chance: chance,
			shift: 1,
			numBits: numBits,
			resetval: resetval
		)
	);

	// Force the register to output the seed value immediately when reset is triggered
	register = Select.kr(resetTrig, [register, resetval]);

	// Mode selection: Pitch values vs Gate values
	output = Select.kr(mode, [
		// Mode 0: Pitch Mode - scale register to MIDI pitch values
		basePitch + (register.linlin(0, (2 ** numBits) - 1, 0, scale).round),

		// Mode 1: Gate Mode - extract single bit and create trigger pulses
		// Use Trig to create proper trigger pulses from bit changes
		Trig.kr(Changed.kr((register >> bitSelect) & 1), 0.01)
	]);

	// Convert control signal to audio rate
	finalSig = K2A.ar(output);

	// Apply level scaling (mainly for amplitude control in gate mode)
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	finalSig = finalSig * levels;

	// Output the numerical values as audio rate signals
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "XOR shift register sequencer outputting pitch or gate values as audio signals", category: "Modulation/Sequencer");
)