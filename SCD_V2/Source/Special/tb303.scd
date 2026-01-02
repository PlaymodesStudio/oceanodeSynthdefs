(
~synthCreator.value("TB303", {|n|
	var freq, wave, ctf, res, sus, dec, env, gate, vol;
	var filEnv, volEnv, waves, sig;

	// Parameters
	freq = OceanodeParameter.ar(\pitch, 36, n, 24, 96, "vf").midicps;
	wave = OceanodeParameterDropdown.kr(\wavetype, 0, n, "Saw:Pulse");
	ctf = OceanodeParameter.ar(\cutoff, 48, n, 1, 135, "vf").midicps;
	res = 1-(OceanodeParameter.ar(\resonance, 0.2, n, 0, 0.99, "vf"));
	sus = OceanodeParameter.ar(\sustain, 0, n, 0, 4, "vf");
	dec = OceanodeParameter.ar(\decay, 1, n, 0.01, 4, "vf");
	env = OceanodeParameter.ar(\envelope, 1000, n, 0, 5000, "vf");
	gate = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	gate = Trig.ar(gate, 0.001);
	vol = OceanodeParameter.ar(\level, 0, n, 0, 1, "vf");

	// Envelopes with explicit gate parameter for proper triggering
	volEnv = EnvGen.ar(Env.new([10e-10, 1, 1, 10e-10], [0.01, sus, dec], 'exp'), gate: gate);
	filEnv = EnvGen.ar(Env.new([10e-10, 1, 10e-10], [0.01, dec], 'exp'), gate: gate);

	// Oscillators
	waves = [
		Saw.ar(freq),
		Pulse.ar(freq, 0.5)
	];

	// Filter and output - apply envelopes separately
	sig = Select.ar(wave, waves) * volEnv;
	sig = RLPF.ar(sig, ctf + (filEnv * env), res) * vol;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "TB-303 bass synthesizer emulation with acid filter envelope", category: "Source/Special");
)
