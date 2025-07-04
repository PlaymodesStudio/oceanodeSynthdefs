(
~synthCreator.value("XORShiftRegister", {|n|
	var clock, register, output, finalSig;
	var mode, bitSelect, numBits, seed, reset, resetTrig;
	var clockHz, basePitch, scale, levels;
	var tap1, tap2;
	var buf, trig, currentVal, bit0, bit1, feedbackBit, newVal, mask;

	// Parameters following Oceanode conventions
	clockHz = OceanodeParameterLag.ar(\clockhz, 4, n, 0.1, 32, "vf", 1/30, true);
	numBits = OceanodeParameter.kr(\numbits, 8, n, 4, 16, "vi");
	seed = OceanodeParameter.kr(\seed, 170, n, 1, 65535, "vi");

	// XOR feedback taps (standard 2-tap configuration)
	tap1 = OceanodeParameter.kr(\tap1, 7, n, 0, 15, "vi");
	tap2 = OceanodeParameter.kr(\tap2, 5, n, 0, 15, "vi");

	// Reset parameter
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Mode selection: 0 = Pitch Mode, 1 = Gate Mode
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Pitch:Gate");
	bitSelect = OceanodeParameter.kr(\bitselect, 0, n, 0, 15, "vi");

	// Musical parameters
	basePitch = OceanodeParameterLag.ar(\basepitch, 60, n, 0, 127, "vf", 1/30, true);
	scale = OceanodeParameterLag.ar(\scale, 12, n, 1, 24, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create single sample buffer for storing register state
	buf = LocalBuf(1);
	buf.set(seed);

	// Clock trigger (convert to audio rate for Demand UGens)
	trig = Impulse.ar(clockHz);
	resetTrig = Trig.ar(reset, 0.001);

	// Read current register value
	currentVal = Demand.ar(trig + resetTrig, 0, Dbufrd(buf));

	// Reset to seed when reset triggered (convert seed to audio rate)
	currentVal = Select.ar(resetTrig, [currentVal, K2A.ar(seed)]);

	// Extract bits at tap positions for XOR feedback (convert params to audio rate)
	bit0 = (currentVal >> K2A.ar(tap1)) & 1;
	bit1 = (currentVal >> K2A.ar(tap2)) & 1;

	// Calculate XOR feedback
	feedbackBit = bit0.bitXor(bit1);

	// Shift left and insert feedback bit at LSB
	newVal = (currentVal << 1) | feedbackBit;

	// Mask to keep only the specified number of bits (convert to audio rate)
	mask = (2 ** K2A.ar(numBits)) - 1;
	register = newVal & mask;

	// Write new value back to buffer
	Demand.ar(trig + resetTrig, 0, Dbufwr(register, buf));

	// Mode selection: Pitch values vs Gate values (convert params to audio rate)
	output = Select.ar(K2A.ar(mode), [
		// Mode 0: Pitch Mode - scale register to MIDI pitch values
		K2A.ar(basePitch) + (register.linlin(0, mask, 0, K2A.ar(scale)).round),

		// Mode 1: Gate Mode - extract single bit and create trigger pulses
		Trig.ar(Changed.ar((register >> K2A.ar(bitSelect)) & 1), 0.01)
	]);

	// Apply level scaling (convert to audio rate)
	finalSig = output * K2A.ar(levels).lincurve(0, 1, 0, 1, 4);

	// Output the values as audio rate signals
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "True XOR shift register sequencer using LocalBuf feedback", category: "Modulation/Sequencer");
)