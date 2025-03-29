(
~synthCreator.value("Kickdrumc", {|n|
	var snd, env, duration, velocity, finalP, env1, env2, env3, clickf, gate, amp;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	finalP = OceanodeParameterLag.ar(\pitch, 36, n, 24, 60, "vf", 1/30, true).midicps;
	env1 = OceanodeParameter.ar(\env1, 0.001, n, 0.0001, 0.01, "vf");
	env2 = OceanodeParameter.ar(\env2, 0.003, n, 0.0001, 0.01, "vf");
	env3 = OceanodeParameter.ar(\env3, 0.3, n, 0.01, 1, "vf");
	clickf = OceanodeParameter.kr(\clickf, 8300, n, 1000, 15000, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Fixed duration and velocity calculation - same for all channels
	duration = 1;
	velocity = duration.linlin(1, 0, 1, 0);
	
	// Complex sine oscillator with multiple frequency modulations
	// Using multichannel expansion for independent processing per channel
	snd = SinOsc.ar(
		finalP
		* (1 + (8 * EnvGen.ar(Env.perc(0, env1), gate) * velocity))
		* (1 + (8 * EnvGen.ar(Env.perc(0, env2), gate) * velocity))
		* (1 + (0.5 * EnvGen.ar(Env.perc(0, env3), gate) * velocity))
		* (0.1).midiratio
	);
	
	// Apply amplitude envelope and add click - with multichannel expansion
	snd = snd * (1 + (EnvGen.ar(Env.perc(0, 0.3), gate) * velocity));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar(gate)), clickf, 0.3) * EnvGen.ar(Env.perc(0.001, 0.003), gate) * 1.dbamp * velocity);
	
	// Final processing - with multichannel expansion
	snd = snd.tanh;
	snd = snd * velocity.sqrt;
	snd = snd * EnvGen.ar(Env.perc(0.001, duration.min(0.6)), gate);
	snd = snd * -3.dbamp * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Kick drum with complex frequency modulation and click transient", category: "Source/Percussion");
)