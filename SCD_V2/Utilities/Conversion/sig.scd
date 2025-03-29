(
~synthCreator.value("Sig", {|n|
	var value, signal;

	value = OceanodeParameterLag.ar(\value, 60, n, 0, 20000, "vf", 1/30, true);

	// Convert parameter to audio-rate signal
	signal = K2A.ar(value);

	// Output the audio signal
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Converts numeric parameter value to audio signal", category: "Utilities/Conversion");
)