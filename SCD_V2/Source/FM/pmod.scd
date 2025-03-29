(
~synthCreator.value("PMod", {|n|
	var carfreq, modfreq, pmidx, sig;

	// Parameters with lag for smooth changes
	carfreq = OceanodeParameterLag.ar(\carp, 48, n, 0, 127, "vf", 1/30, true).midicps;
	modfreq = OceanodeParameterLag.ar(\modp, 60, n, 0, 127, "vf", 1/30, true).midicps;
	pmidx = OceanodeParameterLag.ar(\pmindex, 0, n, 0, 10, "vf", 1/30, true);

	// Phase modulation oscillator
	sig = PMOsc.ar(carfreq, modfreq, pmidx, 0);

	// Apply level control with proper scaling
	sig = sig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Phase modulation oscillator with carrier and modulator", category: "Source/FM");
)