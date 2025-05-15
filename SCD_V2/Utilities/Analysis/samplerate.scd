(
~synthCreator.value("SampleRate", {|n|
	// Define output signal - convert sample rate to audio rate signal
	var signal;

	// Create a DC signal with the value of the current sample rate
	signal = DC.ar(SampleRate.ir)!n;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Outputs the current sample rate as an audio signal", category: "Utilities/Analysis");
)