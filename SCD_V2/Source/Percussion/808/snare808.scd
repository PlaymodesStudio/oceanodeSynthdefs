(
~synthCreator.value("Snare808", {|n|
	var amp, gate, env1, env2, sig1, sig2, sig, decayTime, tone;
	
	// Parameters with appropriate ranges
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	decayTime = OceanodeParameter.ar(\decay, 0.3, n, 0.1, 1, "vf");
	tone = OceanodeParameter.ar(\tone, 0.5, n, 0, 1, "vf");
	
	// Envelopes - using multichannel expansion
	// Start at 0 to prevent auto-triggering
	env1 = EnvGen.ar(Env.new([0, 1, 0], [0.001, decayTime * 0.3], [-4, -12]), gate);
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.001, decayTime], [-4, -8]), gate);
	
	// Sound generation with multichannel expansion
	// Oscillator component (tone)
	sig1 = SinOsc.ar(180) * env1 * tone;
	
	// Noise component
	sig2 = WhiteNoise.ar * env2 * (1 - tone * 0.5);
	sig2 = HPF.ar(sig2, 1000);
	
	// Mix components
	sig = sig1 + sig2;
	sig = sig * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style snare with tone control", category: "Source/Percussion/808");
)