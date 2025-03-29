(
~synthCreator.value("Maracas808", {|n|
	var amp, gate, env, sig, decayTime;
	
	// Parameters with appropriate ranges
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	decayTime = OceanodeParameter.ar(\decay, 0.07, n, 0.01, 0.5, "vf");
	
	// Envelope - using multichannel expansion
	// Changed to start at 0 instead of 0.3 to prevent auto-triggering
	env = EnvGen.ar(Env.new([0, 1, 0], [0.001, decayTime], [-4, -250]), gate);
	
	// Sound generation with multichannel expansion
	sig = WhiteNoise.ar * env * amp;
	sig = HPF.ar(sig, 5500);
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style maracas with filtered noise", category: "Source/Percussion/808");
)