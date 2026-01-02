(
~synthCreator.value("BubbleB", {|n|
	var sig, env, senv, trig, dur, k, amp, pan;

	// Parameters
	trig = OceanodeParameter.ar(\trig, 0, n, 0, 1, "vi");
	dur = OceanodeParameter.ar(\dur, 0.1, n, 0.01, 1, "vf");
	k = OceanodeParameter.ar(\k, 0.2, n, 0, 1, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	pan = OceanodeParameter.ar(\pan, 0, n, -1, 1, "vf");

	// Short impulse envelope
	senv = EnvGen.ar(Env([1, 1, 0, 0], [3/SampleRate.ir, 0.0, 1.0]), trig);
	
	// Excitation signal
	sig = WhiteNoise.ar() * senv;
	
	// Main envelope
	env = EnvGen.ar(Env([0, 1, 1, 0], [0.001] ++ ((dur - 0.001) * [0.4, 0.6])), trig);
	
	// TwoTube physical model
	sig = TwoTube.ar(sig, k, 0.999, 1, 2);
	
	// Multiple bandpass filters with random modulation
	sig = BPF.ar(
		sig,
		LFNoise1.kr({LFNoise1.kr(0.13).exprange(3, 4)}!8).exprange(30, 6000),
		LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08, 0.35)}!8).range(0.005, 0.1)
	);
	
	// Apply envelope and amplitude
	sig = sig * env * 10 * amp;
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), Pan2.ar(sig, pan));
}, description: "Complex bubble sound using TwoTube physical model", category: "Source/Special");
)