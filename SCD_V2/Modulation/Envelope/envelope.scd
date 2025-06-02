(
~synthCreator.value("Envelope", {|n|
	var type, gate, att, dec, sus, rel, curv, lev, hold, peak, sig;

	// Parameters using OceanodeParameter
	type = OceanodeParameterDropdown.kr(\type, 0, n, "ADSR:ASR:Perc:Triangle:Sine:Linen:Cutoff");
	gate = OceanodeParameterLag.ar(\gate, 0, n, 0, 1, "vi");
	att = OceanodeParameterLag.ar(\att, 10, n, 0, 1000, "vf") / 1000.0;
	dec = OceanodeParameterLag.ar(\dec, 100, n, 0, 5000, "vf") / 1000.0;
	sus = OceanodeParameterLag.ar(\sus, 0.5, n, 0, 1, "vf");
	rel = OceanodeParameterLag.ar(\rel, 500, n, 0, 10000, "vf") / 1000.0;
	hold = OceanodeParameterLag.ar(\hold, 1000, n, 0, 10000, "vf") / 1000.0;
	peak = OceanodeParameterLag.ar(\peak, 1, n, 0, 1, "vf");
	curv = OceanodeParameterLag.ar(\curve, -4, n, -10, 10, "vf");
	lev = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);

	// Define envelopes based on type
	sig = Select.ar(type, [
		// ADSR envelope - explicitly define for proper behavior
		EnvGen.ar(
			Env([0, peak, peak * sus, 0], [att, dec, rel], curv, 2),
			gate,
			levelScale: lev,
			doneAction: 0
		),

		// ASR envelope
		EnvGen.ar(
			Env([0, peak, 0], [att, rel], curv, 1),
			gate,
			levelScale: lev,
			doneAction: 0
		),

		// Percussive envelope
		EnvGen.ar(
			Env.perc(att, rel, peak, curv),
			Trig.kr(gate, 0.001),
			levelScale: lev,
			doneAction: 0
		),

		// Triangle envelope
		EnvGen.ar(
			Env.triangle(att + rel, peak),
			Trig.kr(gate, 0.001),
			levelScale: lev,
			doneAction: 0
		),

		// Sine envelope
		EnvGen.ar(
			Env.sine(att + rel, peak),
			Trig.kr(gate, 0.001),
			levelScale: lev,
			doneAction: 0
		),

		// Linen envelope
		EnvGen.ar(
			Env.linen(att, hold, rel, peak, curv),
			Trig.kr(gate, 0.001),
			levelScale: lev,
			doneAction: 0
		),

		// Cutoff envelope
		EnvGen.ar(
			Env([peak, 0], [rel], curv),
			gate,
			levelScale: lev,
			doneAction: 0
		)
	]);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Envelope generator with multiple envelope types", category: "Modulation/Envelope");
)