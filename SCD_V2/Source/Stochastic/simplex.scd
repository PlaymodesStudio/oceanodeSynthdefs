// Perlin3-based synthesizer for Oceanode
(
~synthCreator.value("Perlin", {|n|
	var finalSig, offsetX, offsetY, offsetZ, freqScale;
	var hz, phase;

	// Perlin specific parameters
	offsetX = OceanodeParameterLag.ar(\offsetx, 31.4, n, -100, 100, "vf", 1/30, true);
	offsetY = OceanodeParameterLag.ar(\offsety, -62.8, n, -100, 100, "vf", 1/30, true);
	offsetZ = OceanodeParameterLag.ar(\offsetz, 17.6, n, -100, 100, "vf", 1/30, true);
	freqScale = OceanodeParameterLag.ar(\freqscale, 0.2, n, 0.01, 10, "vf", 1/30, true);

	// Frequency control in Hz
	hz = OceanodeParameterLag.ar(\hz, 440, n, 0.1, 20000, "vf", 1/30, true);

	// Use Phasor for continuous movement through noise space
	phase = Phasor.ar(0, hz * SampleDur.ir, 0, 1);

	// Use Perlin3 directly with the phase
	finalSig = Perlin3.ar(
		phase * freqScale + offsetX * 0.01,
		phase * freqScale + offsetY * 0.01,
		phase * freqScale + offsetZ * 0.01
	);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Perlin noise oscillator with 3D movement through noise space", category: "Source/Noise");
)