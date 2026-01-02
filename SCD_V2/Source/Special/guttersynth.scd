(
~synthCreator.value("GutterSynth", {|n|
	var sig, freqs1, freqs2, pitch, pan;
	var mod, omega, damp, rate, gain, soften, gain1, gain2, q1, q2, dist;

	// Parameters - use control rate for GutterSynth inputs
	mod = OceanodeParameter.kr(\mod, 0.2, n, 0, 10, "vf");
	omega = OceanodeParameter.kr(\omega, 0.0002, n, 0.0001, 1, "vf");
	damp = OceanodeParameter.kr(\damp, 0.01, n, 0.0001, 1, "vf");
	rate = OceanodeParameter.kr(\rate, 0.03, n, 0, 5, "vf");
	gain = OceanodeParameter.kr(\gain, 1.4, n, 0, 4, "vf");
	soften = OceanodeParameter.kr(\soften, 1, n, 0, 5, "vf");
	gain1 = OceanodeParameter.kr(\gain1, 1.5, n, 0, 2, "vf");
	gain2 = OceanodeParameter.kr(\gain2, 1.5, n, 0, 2, "vf");
	dist = OceanodeParameterDropdown.kr(\distortionmethod, 1, n, "Method1:Method2:Method3:Method4:Method5");
	freqs1 = OceanodeParameter.kr(\freqs1, 20, n, 20, 2000, "vf");
	freqs2 = OceanodeParameter.kr(\freqs2, 25, n, 20, 2000, "vf");
	q1 = OceanodeParameter.kr(\q1, 10, n, 10, 1000, "vf");
	q2 = OceanodeParameter.kr(\q2, 10, n, 10, 1000, "vf");
	pan = OceanodeParameter.kr(\pan, 0, n, -1, 1, "vf");

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
}, description: "Complex physical modeling synth with multiple resonators and distortion methods", category: "Source/Special");
)