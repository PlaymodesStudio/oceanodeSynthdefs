(
~synthCreator.value("Conversions", {|n|
	var input, output, conversionType;

	// Input value
	input = OceanodeParameterLag.ar(\input, 440, n, 0, 20000, "vf", 1/30, true);

	// Conversion type dropdown
	// Using "Hz2Midi" instead of "Hz2MIDI" to avoid having "d:" in the dropdown text
	conversionType = OceanodeParameterDropdown.kr(\conversion, 0, n, "Hz2Midi:Midi2Hz:Hz2Ms:Ms2Hz:Hz2S:S2Hz:Linear2Db:Db2Linear:Midi2Ratio:Ratio2Midi");

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
		12 * input.log2
	]);

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Utility for common audio and music conversions", category: "Utilities/Conversion");
)