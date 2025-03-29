(
~synthCreator.value("Claves808", {|n|
	var amp, env, sig, gate, decayTime;
	
	// Parameters with appropriate ranges
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	decayTime = OceanodeParameter.ar(\decay, 0.1, n, 0.01, 1, "vf");
	
	// Envelope - using multichannel expansion
	// Changed to start at 0 instead of 1 to prevent auto-triggering
	env = EnvGen.ar(Env.new([0, 1, 0], [0.001, decayTime], [-4, -20]), gate);
	
	// Sound generation with multichannel expansion
	sig = SinOsc.ar(2500, pi/2) * env * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style claves with sine oscillator", category: "Source/Percussion/808");
)