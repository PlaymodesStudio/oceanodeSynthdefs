(
~synthCreator.value("Clap808", {|n|
	var amp, gate, atkenv, atk, decay, sum, denv, decayTime;
	
	// Parameters with appropriate ranges
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	decayTime = OceanodeParameter.ar(\decay, 6, n, 1, 16, "vf");
	
	// Envelopes - using multichannel expansion
	// Changed to start at 0 instead of 0.5 to prevent auto-triggering
	atkenv = EnvGen.ar(Env.new([0, 0.5, 1, 0], [0.001, 0.01, 0.3], [-4, -4, -160]), gate);
	
	// Replace Env.dadsr with a standard Env.perc to avoid auto-triggering
	denv = EnvGen.ar(Env.perc(0.026, decayTime, 1, -157), gate);
	
	// Sound generation - using multichannel expansion
	atk = WhiteNoise.ar * atkenv * 1.4;
	decay = WhiteNoise.ar * denv;
	
	// Mix and filter - using multichannel expansion
	sum = atk + decay * amp;
	sum = HPF.ar(sum, 500);
	sum = BPF.ar(sum, 1062, 0.5);
	sum = sum * 1.5;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), sum);
}, description: "808 style clap sound with attack and decay control", category: "Source/Percussion/808");
)