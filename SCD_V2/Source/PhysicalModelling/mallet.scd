(
~synthCreator.value("Mallet", {|n|
	var mode, pitch, t60, levels, gate, excite, lpf, sig, exciter;
	var ratios, amps, decays, input;

	// Mode selector as a dropdown parameter
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Trigg:Drone:Input");

	// Common parameters with lag for smooth transitions
	pitch = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	t60 = OceanodeParameterLag.ar(\t60, 2.5, n, 0.1, 10, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0.125, n, 0, 1, "vf", 1/30, true);

	// Mode-specific parameters
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	excite = OceanodeParameter.ar(\excite, 0.2, n, 0, 1, "vf");
	lpf = OceanodeParameter.ar(\lpf, 20000, n, 0, 20000, "vf");

	// Fixed resonator values
	ratios = [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421];
	amps = [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079];
	decays = [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047];

	// Input signal for the input-driven mode
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	sig = n.collect({ |chan|
		// Different exciter based on mode
		exciter = Select.ar(mode[chan], [
			// Mode 0: Triggered mallet hit
			WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate[chan]) * 0.25,

			// Mode 1: Continuous excitation (drone)
			WhiteNoise.ar() * 0.25 * excite[chan],

			// Mode 2: Input-driven
			input[chan] * 0.1
		]);

		// Resonator using DynKlank
		sig = DynKlank.ar(
			`[
				ratios,
				amps,
				decays * t60[chan]
			],
			exciter,
			freqscale: pitch[chan]
		);

		// Apply amplitude and output
		LPF.ar(sig * levels[chan], lpf[chan])
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(sig));

}, description: "Resonant mallet percussion with trigger gate drone and input modes", category: "Source/PhysicalModelling");
)
