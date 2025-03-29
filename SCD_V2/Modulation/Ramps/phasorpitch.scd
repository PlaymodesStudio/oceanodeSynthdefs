(
~synthCreator.value("PhasorPitch", {|n|
	var min, max, hz, rate, sig, cycledur, range, reset, initPh;

	// Basic LFO controls
	cycledur = OceanodeParameterLag.ar(\pitch, 1, n, 0, 128, "vf", 1/30, true).midicps.reciprocal;
	initPh = OceanodeParameterLag.ar(\phoff, 0, n, -1, 1, "vf", 1/30, true);
	min = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);
	max = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Calculate the range the phasor needs to cover
	range = max - min;

	// Calculate the rate per sample
	rate = range / (cycledur * SampleRate.ir());

	// Create the Phasor signal
	sig = Phasor.ar(Trig.ar(reset, 0.001), rate, min, max, 0);
	sig = (sig + initPh).wrap(0, 1);

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Phasor in Pitch", category: "Modulation/Ramps");
)

