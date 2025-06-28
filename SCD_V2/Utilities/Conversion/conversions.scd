~synthCreator.value("Conversions", {|n|
	var input, output, conversionType, bpm;

	// Input value
	input = OceanodeParameterLag.ar(\input, 440, n, 0, 20000, "vf", 1/30, true);

	// BPM parameter for BarTh conversions
	bpm = OceanodeParameterLag.ar(\bpm, 120, n, 1, 999, "vf", 1/30, true);

	// Conversion type dropdown - added BarTh2Ms and Ms2BarTh
	conversionType = OceanodeParameterDropdown.kr(\conversion, 0, n, "Hz2Midi:Midi2Hz:Hz2Ms:Ms2Hz:Hz2S:S2Hz:Linear2Db:Db2Linear:Midi2Ratio:Ratio2Midi:BarTh2Ms:Ms2BarTh");

	// Perform the appropriate conversion based on the selected type
	output = Select.ar(conversionType, [
		// Hz to MIDI note
		input.cpsmidi,

		// MIDI note to Hz
		input.midicps,

		// Hz to milliseconds (period)
		input.reciprocal * 1000,

		// Milliseconds to Hz (frequency)
		1000 / input,

		// Hz to seconds (period)
		input.reciprocal,

		// Seconds to Hz (frequency)
		input.reciprocal,

		// Linear amplitude to dB
		input.ampdb,

		// dB to linear amplitude
		input.dbamp,

		// MIDI note intervals to frequency ratio
		2.pow(input/12),

		// Frequency ratio to MIDI note intervals
		12 * input.log2,

		// BarTh to milliseconds
		// Formula: (60000 / bpm) / (input / 4)
		// 60000ms = 1 minute, divide by bpm to get quarter note duration
		// Then divide by (input/4) to get the subdivision duration
		(60000 / bpm) / (input / 4),

		// Milliseconds to BarTh
		// Inverse of above: (input * (barth / 4)) / (60000 / bpm)
		// Rearranged: (input * bpm) / (60000 / 4) = (input * bpm) / 15000
		(input * bpm) / 15000
	]);

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Utility for common audio and music conversions including bar divisions", category: "Utilities/Conversion");