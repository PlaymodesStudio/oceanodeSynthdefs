(
 SynthDef.new(\tb303, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!78).midicps;
	wave=\wavetype.kr(0!78);
	ctf=\cutoff.kr(48!78).midicps;
	res=\resonance.kr(0.2!78);
	sus=\sustain.kr(0!78);
	dec=\decay.kr(1!78);
	env=\envelope.kr(1000!78);
	gate=\trigger.kr(0!78);
	vol=\level.kr(0!78);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv),  Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
 SynthDef.new(\tb30313, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!13).midicps;
	wave=\wavetype.kr(0!13);
	ctf=\cutoff.kr(48!13).midicps;
	res=\resonance.kr(0.2!13);
	sus=\sustain.kr(0!13);
	dec=\decay.kr(1!13);
	env=\envelope.kr(1000!13);
	gate=\trigger.kr(0!13);
	vol=\level.kr(0!13);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
 SynthDef.new(\tb303mono, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!1).midicps;
	wave=\wavetype.kr(0!1);
	ctf=\cutoff.kr(48!1).midicps;
	res=\resonance.kr(0.2!1);
	sus=\sustain.kr(0!1);
	dec=\decay.kr(1!1);
	env=\envelope.kr(1000!1);
	gate=\trigger.kr(0!1);
	vol=\level.kr(0!1);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)