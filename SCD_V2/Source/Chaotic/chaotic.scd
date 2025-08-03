(
~synthCreator.value("Chaotic", {|n|
	var sig, pitch, levels, type, param1, param2, param3, param4;
	var freq, chaotic_oscs;
	var p1_scaled, p2_scaled, p3_scaled, p4_scaled;

	// Parameters - all normalized 0-1
	pitch = OceanodeParameterLag.ar(\pitch, 48, n, 12, 120, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
	type = OceanodeParameterDropdown.kr(\type, 0, n, "Lorenz:Rossler:Henon:StandardMap:QuadraticMap:CuspMap");

	// Normalized control parameters
	param1 = OceanodeParameter.ar(\param1, 0.5, n, 0, 1, "vf");
	param2 = OceanodeParameter.ar(\param2, 0.5, n, 0, 1, "vf");
	param3 = OceanodeParameter.ar(\param3, 0.5, n, 0, 1, "vf");
	param4 = OceanodeParameter.ar(\param4, 0.5, n, 0, 1, "vf");

	// Convert pitch to base frequency
	freq = pitch.midicps;

	// Create array of chaotic oscillators with per-oscillator parameter scaling
	chaotic_oscs = [
		// Lorenz: sigma(0.1-50), rho(0.1-100), beta(0.1-20), freq_scale(0.001-2)
		LorenzL.ar(
			freq * param4.linlin(0, 1, 0.001, 2),
			param1.linlin(0, 1, 0.1, 50),      // sigma
			param2.linlin(0, 1, 0.1, 100),     // rho
			param3.linlin(0, 1, 0.1, 20),      // beta
			0.05, 0.1, 0, 0.1
		),

		// Rossler: a(0.1-2), b(0.1-2), c(0.1-20), freq_scale(0.001-2)
		RosslerL.ar(
			freq * param4.linlin(0, 1, 0.001, 2),
			param1.linlin(0, 1, 0.1, 2),       // a
			param2.linlin(0, 1, 0.1, 2),       // b
			param3.linlin(0, 1, 0.1, 20),      // c
			0.05, 0.1, 0, 0.1
		),

		// Henon: a(0.5-1.8), b(0.1-0.5)
		HenonL.ar(
			freq * param4.linlin(0, 1, 0.001, 10),
			param1.linlin(0, 1, 0.5, 1.8),     // a
			param2.linlin(0, 1, 0.1, 0.5),     // b
			0, 0
		),

		// Standard map: k(0-4), x0(-pi to pi)
		StandardL.ar(
			freq * param4.linlin(0, 1, 0.001, 10),
			param1.linlin(0, 1, 0, 4),         // k
			param2.linlin(0, 1, -pi, pi),      // x0
			0, 1
		),

		// Quadratic: a(0.5-4), b(-2 to 2), c(-1 to 1)
		QuadL.ar(
			freq * param4.linlin(0, 1, 0.001, 10),
			param1.linlin(0, 1, 0.5, 4),       // a
			param2.linlin(0, 1, -2, 2),        // b
			param3.linlin(0, 1, -1, 1),        // c
			0
		),

		// Cusp: a(0.5-2)
		CuspL.ar(
			freq * param4.linlin(0, 1, 0.001, 10),
			param1.linlin(0, 1, 0.5, 2),       // a
			0
		)
	];

	// Select which chaotic oscillator to use
	sig = Select.ar(type, chaotic_oscs);

	// Apply level control with natural dB scaling
	sig = sig * levels.lincurve(0, 1, 0, 1, 4);

	// Soft limiting to prevent extreme values
	sig = sig.tanh * 0.5;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Chaotic oscillators including Lorenz Rossler Chua and others", category: "Source/Chaotic");
)