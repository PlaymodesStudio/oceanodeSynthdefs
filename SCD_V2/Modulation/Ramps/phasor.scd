(
~synthCreator.value("Phasor", {|n|
	var min, max, beats, bpm, rate, sig, cycledur, range, reset, initPh;

	// Basic LFO controls
	beats = OceanodeParameterLag.ar(\beats, 1, n, 0, 128, "vf", 1/30, true);
	bpm = OceanodeParameterLag.ar(\bpm, 120, n, 0, 120, "vf", 1/30, true);
	initPh = OceanodeParameterLag.ar(\phoff, 0, n, -1, 1, "vf", 1/30, true);
	min = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);
	max = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");


	// Calculate the cycle duration in seconds
	cycledur = beats * (60 / bpm);

	// Calculate the range the phasor needs to cover
	range = max - min;

	// Calculate the rate per sample
	rate = range / (cycledur * SampleRate.ir());

	// Create the Phasor signal
	sig = Phasor.ar(Trig.ar(reset, 0.001), rate, min, max, 0);
	sig = (sig + initPh).wrap(0, 1);

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Phasor", category: "Modulation/Ramps");
)

