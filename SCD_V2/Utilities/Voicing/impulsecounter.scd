(
~synthCreator.value("ImpulseCounter", {|n|
	var input, reset, count, enableModulo, moduloValue, output;

	// Input signal (should be impulses/triggers)
	input = In.ar(OceanodeInput.kr(\in), n);

	// Reset trigger
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi") > 0.5;

	// Enable modulo option (checkbox)
	enableModulo = OceanodeParameter.kr(\enablemodulo, 0, n, 0, 1, "vi");

	// Modulo value (only used when modulo is enabled)
	moduloValue = OceanodeParameter.kr(\modulovalue, 8, n, 1, 128, "vi");

	// Count the impulses
	count = PulseCount.ar(input, reset);

	// Apply modulo if enabled
	output = Select.ar(enableModulo, [
		count,
		count % moduloValue
	]);

	// Output the result
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Counts impulses with optional modulo functionality", category: "Utilities/Voicing");
)