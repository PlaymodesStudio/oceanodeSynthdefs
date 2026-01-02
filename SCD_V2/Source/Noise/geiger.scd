(
~synthCreator.value("Geiger", {|n|
	var trigger, finalSig;
	var density, disorder;

	// Core parameters
	density = OceanodeParameterLag.ar(\hz, 60, n, 0, 20000, "vf", 1/30, true);
	disorder = OceanodeParameterLag.ar(\disorder, 0.5, n, 0, 1, "vf", 1/30, true);

	// Create progressively disordered pulses using a single Impulse with modulated timing
	// The key is to use different noise sources with increasing impact on the timing
	trigger = Impulse.ar(
		// Base frequency affected by increasingly chaotic modulation
		density * (
			// First modulation layer - subtle LFNoise1 (relatively smooth)
			1 + (LFNoise1.ar(density * 0.25) * disorder * 0.5) +
			// Second modulation layer - more erratic LFNoise0
			(LFNoise0.ar(density * 1) * disorder.squared * 1.5) +
			// Third modulation layer - completely random WhiteNoise (extreme jitter)
			(WhiteNoise.ar * disorder.cubed * 6) +
			// Fourth modulation layer - extreme spikes using Dust (creates occasional very long gaps)
			(Dust.ar(density * 0.25) * disorder.pow(4) * 10)
		)
	);

	// Pure impulses - just output the triggers directly
	finalSig = trigger;

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output to the specified bus
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Impulse generator with progressive timing disorder", category: "Source/Noise");
)