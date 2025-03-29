(
~synthCreator.value("SimpleSaw", {|n|
	var freq, signal, ampControl;

	// Pitch control with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\hz, 440, n, 0, 20000, "vf", 1/30, true);

	// Create sine oscillator
	signal = Saw.ar(freq);

	// Apply level control with proper dB scaling
	ampControl = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true);
	signal = signal * ampControl;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Simple saw oscillator with frequency and amplitude control", category: "Source/Analog");
)