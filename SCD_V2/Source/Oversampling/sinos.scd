(
~synthCreator.value("SinOs", {|n|
	var freq, signal, ampControl, phase, fmin;

	// Pitch control with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	phase = OceanodeParameterLag.ar(\phase, 0, n, -1, 1, "vf", 1/30, true);
	fmin = OceanodeParameterLag.ar(\fm_in, 0, n, -1, 1, "vf", 1/30, true);

	signal = SinOscOS.ar(freq+fmin,phase,4);

	ampControl = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true);

	// Apply amplitude
	signal = signal * ampControl;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Oversampled Sinusoidal oscillator with phase control", category: "Source/Oversampling");
)