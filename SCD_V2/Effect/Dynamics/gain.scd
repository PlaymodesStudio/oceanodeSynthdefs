(
~synthCreator.value("Gain", {|n|
	var source, sig, gain, numchans;

	// All variables must be declared at the beginning
	numchans = n;

	// Parameters with appropriate ranges from synthdefs.json
	gain = OceanodeParameterLag.ar(\gainmult, 1, n, 0, 1, "vf", 1/30, true);

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Apply exponential gain curve for better perceptual control
	// Using formula from original: 0.000031623*exp(10.36*ctl) for 90dB dynamic range
	gain = 0.000031623 * exp(10.36 * gain);

	// Apply gain to signal
	sig = source * gain;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Gain control with exponential curve for natural level control", category: "Effect/Dynamics");
)

LeakDC.ar(((x * 5 - 13) * x + 3) / (x * 2 + 3)).neg