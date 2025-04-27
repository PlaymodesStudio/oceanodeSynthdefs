(
~synthCreator.value("Crash", {|n|
	var lodriver, hidriver, signal, cymbal;
	var locut, hicut, time, att, gate, levels;
	var loDriveLevel, hiDriveLevel, thwackLevel, shimmer;
	var hpf, curve, whiteNoise, pinkNoise;
	var timeEnv, shimmerEnv, initialEnv, midEnv, highEnv;

	// Control parameters - using vector capability
	locut = OceanodeParameterLag.ar(\locut, 4000, n, 200, 20000, "vf", 1/30, true);
	hicut = OceanodeParameterLag.ar(\hicut, 8000, n, 100, 20000, "vf", 1/30, true);
	time = OceanodeParameterLag.ar(\time, 1.2, 1, 0.1, 10, "vf", 1/30, true)[0]; // Using scalar time for consistency
	att = OceanodeParameterLag.ar(\excitation, 0.2, n, 0, 1, "vf", 1/30, true);
	loDriveLevel = OceanodeParameterLag.ar(\noiselo, 0.8, n, 0, 2, "vf", 1/30, true);
	hiDriveLevel = OceanodeParameterLag.ar(\noisehi, 1.0, n, 0, 2, "vf", 1/30, true);
	thwackLevel = OceanodeParameterLag.ar(\resolevel, 2.0, n, 0, 5, "vf", 1/30, true);
	shimmer = OceanodeParameterLag.ar(\shimmer, 0.9, n, 0, 1, "vf", 1/30, true);
	gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");

	// Add high-pass filter and curve control
	hpf = OceanodeParameterLag.ar(\hpf, 150, n, 20, 1000, "vf", 1/30, true);
	curve = OceanodeParameterLag.ar(\curve, -4, 1, -8, 8, "vf", 1/30, true)[0]; // Using scalar curve for consistency

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\amp, 0.1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Detect gate onset - ensure same trigger for all channels
	gate = Trig.kr(gate[0], 0.001); // Use first channel's gate to trigger all channels

	// Create envelope control signals - identical for all channels
	initialEnv = EnvGen.ar(Env.perc(0.001, time * 0.05, 1, curve), gate);
	midEnv = EnvGen.ar(Env.perc(0.01, time * 0.6, 1, curve), gate);
	highEnv = EnvGen.ar(Env.perc(0.005, time, 1, curve), gate);
	shimmerEnv = EnvGen.ar(Env.perc(0.1, time * 2, 1, curve), gate);

	// Create noise sources
	whiteNoise = WhiteNoise.ar(0.1);
	pinkNoise = PinkNoise.ar(0.1);

	// Create the initial hit transient - short bright noise burst
	lodriver = LPF.ar(whiteNoise, 8000) * initialEnv * att;

	// Create the body of the cymbal - filtered noise with different envelope shapes
	hidriver = HPF.ar(
		whiteNoise * hiDriveLevel,
		hicut
	) * midEnv;

	// High component - bright attack with faster decay
	lodriver = lodriver + LPF.ar(
		pinkNoise * loDriveLevel,
		locut
	) * highEnv;

	// Create the shimmer - modulated high frequencies that decay slower
	cymbal = HPF.ar(
		whiteNoise,
		5000
	) * shimmerEnv * thwackLevel * 0.1;

	// Mix all components
	signal = (lodriver + hidriver + cymbal) * levels;

	// Apply final high-pass filter to remove unwanted low frequencies
	signal = HPF.ar(signal, hpf);

	// Output
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Noise-based cymbal synthesizer without resonators", category: "Source/Percussion");
)