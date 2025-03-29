(
~synthCreator.value("Brass", {|n|
	var lipFreq, lipTension, airPressure, tubeLength, brightness, levels;
	var lipOsc, tubeResonance, tubeFilter, radiation, signal;

	// Control parameters
	lipFreq = OceanodeParameterLag.ar(\pitch, 30, n, 12, 130, "vf", 1/30, true).midicps;
	lipTension = OceanodeParameterLag.ar(\tension, 0.1, n, 0, 1, "vf", 1/30, true).linexp(0, 1, 0.5, 4);
	airPressure = OceanodeParameterLag.ar(\pressure, 3.86, n, 0, 4, "vf", 1/30, true).linexp(0, 1, 0.1, 2);
	tubeLength = OceanodeParameterLag.ar(\tubelength, 1.10, n, 0.5, 1.5, "vf", 1/30, true);
	brightness = OceanodeParameterLag.ar(\brightness, 0.95, n, 0, 1, "vf", 1/30, true);

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Lip model - self-oscillating system using feedback
	lipOsc = SinOscFB.ar(
		lipFreq * lipTension,
		airPressure * 2,
		airPressure
	);

	// Basic waveguide model for the tube resonance
	tubeResonance = CombL.ar(
		lipOsc,
		0.1,  // Max delay time
		1 / (lipFreq * tubeLength), // Actual delay time based on pitch
		3 * airPressure // Decay time varies with pressure
	);

	// Tube filtering - brass instruments act as lowpass filters
	tubeFilter = RLPF.ar(
		tubeResonance,
		lipFreq * (2 + (brightness * 6)), // Cutoff frequency
		0.3 + (0.6 * brightness) // Resonance
	);

	// Model radiation characteristics and horn effect
	radiation = HPF.ar(tubeFilter, 200); // High-pass to model radiation
	radiation = radiation + (radiation.clip2(0.1) * brightness); // Add subtle nonlinear brightness

	// Apply final shaping and level control
	signal = radiation * levels;

	// Output
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Physical model of a brass instrument", category: "Source/PhysicalModelling");
)