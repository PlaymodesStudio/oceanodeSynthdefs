(
~synthCreator.value("SteelDrum", {|n|
	var t_gate, freq, amp, pan, att, dec, curve, filterHarmonic;
	var resFreqArray, resAmpArray, resDecArray, enva, envb, envc, snda, sndb, sndc, snd;

	// Parameters
	t_gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	freq = OceanodeParameter.ar(\pitch, 60, n, 24, 96, "vf").midicps;
	amp = OceanodeParameter.ar(\amp, 0.1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	pan = OceanodeParameter.ar(\pan, 0, n, -1, 1, "vf");
	att = OceanodeParameter.ar(\att, 0.01, n, 0.001, 0.5, "vf");
	dec = OceanodeParameter.ar(\dec, 1.5, n, 0.1, 5, "vf");
	curve = OceanodeParameter.ar(\curve, -6, n, -10, 0, "vf");
	filterHarmonic = OceanodeParameter.ar(\harmonic, 6, n, 1, 20, "vf");

	// Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes
	resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
	resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
	resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

	// Custom envelope shapes attempting to capture the apparent "bloom" of a note
	enva = EnvGen.kr(Env.pairs([[0, 0], [att, 1], [(att + dec), 0]], curve), gate: t_gate);
	envb = EnvGen.kr(Env.pairs([[0, 0], [(att * 5), 0.25], [(att * 6), 0.75], [((att * 6) + (dec / 2)), 0]], curve), gate: t_gate);
	envc = EnvGen.kr(Env.pairs([[0, 0], [(att * 5), 0.1], [(att * 8), 0.5], [((att * 8) + (dec / 3)), 0]], curve), gate: t_gate);

	// Fundamental, octave up, and a bank of enharmonic resonators excited by a metallic sound
	snda = SinOsc.ar(freq: freq, mul: enva);
	sndb = SinOsc.ar(freq: freq * 2.015, mul: envb);
	sndc = DynKlank.ar(
		specificationsArrayRef:
			Ref.new([
				resFreqArray * freq,
				resAmpArray,
				resDecArray * dec
			]),
		input:
		LPF.ar(HPF.ar(CombN.ar(PinkNoise.ar(envc), 1/freq, 1/freq, -1), freq * 2), freq * filterHarmonic)
	);

	// Output stages with a tiny bit of compression to smooth things out
	snd = Mix.ar([snda, sndb, sndc]) * (amp / 3);
	snd = Limiter.ar(snd, amp);

	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Physical model of a steel drum with resonant modes", category: "Source/PhysicalModelling");
)