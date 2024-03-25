(
SynthDef.new(\kickdrumc, {
    arg out=0;
    var snd, env, duration, velocity;
	var finalP = \pitch.kr(36).midicps;
	var env1 = \env1.kr(0.001);
	var env2 = \env2.kr(0.003);
	var env3 = \env3.kr(0.3);
	var clickf = \clickf.kr(8300);
	var gate=\gate.kr(1);
    duration = 1;
    velocity = duration.linlin(1, 0, 1, 0);


   snd = SinOsc.ar(
		finalP
		* (1 + (8 * EnvGen.ar(Env.perc(0, env1),gate) * velocity))
		* (1 + (8 * EnvGen.ar(Env.perc(0, env2),gate) * velocity))
		* (1 + (0.5 * EnvGen.ar(Env.perc(0, env3),gate) * velocity))
		* (0.1).midiratio
	);

	snd = snd * (1 + (EnvGen.ar(Env.perc(0, 0.3),gate) * velocity));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar(gate)), clickf, 0.3) * EnvGen.ar(Env.perc(0.001, 0.003),gate) * 1.dbamp * velocity);
	snd = snd.tanh;
	snd = snd * velocity.sqrt;
	snd = snd * EnvGen.ar(Env.perc(0.001, duration.min(0.6)),gate);
	snd = snd * -3.dbamp;

	Out.ar(out, snd);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;



