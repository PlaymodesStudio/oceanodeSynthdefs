(
~synthCreator.value("SquareOS", {|n|
	var freq, signal, ampControl, phase, width,fmin;

	// Pitch control with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	width = OceanodeParameterLag.ar(\width, 0.5, n, 0, 1, "vf", 1/30, true);
	phase = OceanodeParameterLag.ar(\phase, 0, n, -1, 1, "vf", 1/30, true);
	fmin = OceanodeParameterLag.ar(\fm_in, 0, n, -1, 1, "vf", 1/30, true);

	signal = SquareOS.ar(freq+fmin,phase,width,4);

	ampControl = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true);

	// Apply amplitude
	signal = signal * ampControl;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Oversampled Square oscillator with phase control", category: "Source/Oversampling");
)