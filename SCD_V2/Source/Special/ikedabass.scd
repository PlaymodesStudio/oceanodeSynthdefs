(
~synthCreator.value("IkedaBass", {|n|
	var freq, amp, harmonic, iphase, snd;

	// Fixed phase offset
	iphase = pi/3;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
	harmonic = OceanodeParameter.ar(\harm, 8, n, 1, 20, "vf");

	// Generate sound using phase modulation technique
	// This creates a characteristic Ikeda-style bass sound
	snd = SinOsc.ar(
		freq: 0,
		phase: (Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi)
	) + SinOsc.ar(
		freq: 0,
		phase: (Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi)
	);
	
	// Apply amplitude
	snd = snd * amp;
	
	// Soft clipping for warmth
	snd = (snd/2).tanh;
	
	// Remove DC offset
	snd = LeakDC.ar(snd);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Ikeda-style bass synth using phase modulation technique", category: "Source/Special");
)