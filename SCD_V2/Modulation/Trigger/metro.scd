(
~synthCreator.value("Metro", {|n|
	var trig, reset_trig, hz, chance, duplicate, signal, reset;

	// Define parameters
	hz = OceanodeParameterLag.ar(\hz, 1, n, 0.01, 60, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	chance = OceanodeParameter.kr(\chance, 1, n, 0, 1, "vf");
	duplicate = OceanodeParameterDropdown.kr(\duplicate, 0, n, "Individual:Shared");

	// Create base trigger signal at audio rate
	trig = Impulse.ar(hz);

	// Add reset trigger functionality
	reset_trig = Trig.ar(K2A.ar(reset), SampleDur.ir);
	trig = trig + reset_trig;

	// Apply probabilistic behavior
	signal = Select.ar(duplicate, [
		// Individual mode: each channel has its own random behavior
		trig * (chance.at(0) > Array.fill(n, { TRand.ar(0.0, 1.0, trig) })),

		// Shared mode: same random behavior for all channels
		trig * (chance.at(0) > TRand.ar(0.0, 1.0, trig)).dup(n)
	]);

	// Output the signal at audio rate
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Metro trigger generator with chance parameter", category: "Modulation/Trigger");
)