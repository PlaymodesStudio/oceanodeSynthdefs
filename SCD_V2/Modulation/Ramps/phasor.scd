(
~synthCreator.value("Phasor", {|n|
	var min, max, beats, bpm, rate, sig, cycledur, range, reset, initPh, fixednum;
	var cycleCounter, shouldRun, combinedReset;

	// Basic LFO controls
	beats = OceanodeParameterLag.ar(\beats, 1, n, 0.001, 128, "vf", 1/30, true);
	bpm = OceanodeParameterLag.ar(\bpm, 120, n, 0, 120, "vf", 1/30, true);
	initPh = OceanodeParameterLag.ar(\phoff, 0, n, -1, 1, "vf", 1/30, true);
	min = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);
	max = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	fixednum = OceanodeParameter.ar(\fixednum, 0, 1, 0, 1000, "vi"); // New fixed number parameter

	// Calculate the cycle duration in seconds
	cycledur = beats * (60 / bpm);
	// Calculate the range the phasor needs to cover
	range = max - min;
	// Calculate the rate per sample
	rate = range / (cycledur * SampleRate.ir());

	// Create combined reset trigger
	combinedReset = Trig.ar(reset, 0.001);

	// Create the basic Phasor signal
	sig = Phasor.ar(combinedReset, rate, min, max, 0);

	// Count completed cycles by detecting when phasor wraps from max back to min
	cycleCounter = PulseCount.ar(Trig.ar(sig < (min + (rate * 2)), 0.001), combinedReset);

	// Determine if phasor should run based on fixednum
	shouldRun = Select.ar(K2A.ar(fixednum > 0), [
		// fixednum = 0: always run (original behavior)
		K2A.ar(1),
		// fixednum > 0: only run if we haven't completed fixednum cycles yet
		K2A.ar(cycleCounter < K2A.ar(fixednum))
	]);

	// When shouldRun becomes 0, hold the phasor at max value
	sig = Select.ar(shouldRun, [max, sig]);

	// Apply phase offset
	sig = (sig + initPh).wrap(min, max);

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Phasor", category: "Modulation/Ramps");
)