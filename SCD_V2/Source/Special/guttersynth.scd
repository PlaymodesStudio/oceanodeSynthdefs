(
~synthCreator.value("GutterSynth", {|n|
	var sig, freqs1, freqs2, pitch, pan;
	var mod, omega, damp, rate, gain, soften, gain1, gain2, q1, q2, dist;

	// Parameters
	mod = OceanodeParameter.ar(\mod, 0.2, n, 0, 10, "vf");
	omega = OceanodeParameter.ar(\omega, 0.0002, n, 0.0001, 1, "vf");
	damp = OceanodeParameter.ar(\damp, 0.01, n, 0.0001, 1, "vf");
	rate = OceanodeParameter.ar(\rate, 0.03, n, 0, 5, "vf");
	gain = OceanodeParameter.ar(\gain, 1.4, n, 0, 4, "vf");
	soften = OceanodeParameter.ar(\soften, 1, n, 0, 5, "vf");
	gain1 = OceanodeParameter.ar(\gain1, 1.5, n, 0, 2, "vf");
	gain2 = OceanodeParameter.ar(\gain2, 1.5, n, 0, 2, "vf");
	dist = OceanodeParameterDropdown.kr(\distortionmethod, 1, n, "Method1:Method2:Method3:Method4:Method5");
	freqs1 = OceanodeParameter.ar(\freqs1, 20, n, 20, 2000, "vf");
	freqs2 = OceanodeParameter.ar(\freqs2, 25, n, 20, 2000, "vf");
	q1 = OceanodeParameter.ar(\q1, 10, n, 10, 1000, "vf");
	q2 = OceanodeParameter.ar(\q2, 10, n, 10, 1000, "vf");
	pan = OceanodeParameter.ar(\pan, 0, n, -1, 1, "vf");

	// Create GutterSynth
	sig = GutterSynth.ar(
		gamma: mod,
		omega: omega,
		c: damp,
		dt: rate,
		singlegain: gain,
		smoothing: soften,
		togglefilters: 1,
		distortionmethod: dist,
		oversampling: 1,
		enableaudioinput: 0,
		audioinput: SinOsc.ar(90),
		gains1: gain1,
		gains2: gain2,
		freqs1: freqs1,
		qs1: q1,
		freqs2: freqs2,
		qs2: q2
	);

	// Apply panning and limiting
	sig = Pan2.ar(sig, pan);
	sig = Limiter.ar(sig);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Complex physical modeling synth with multiple resonators and distortion methods", category: "Sources/Special");
)