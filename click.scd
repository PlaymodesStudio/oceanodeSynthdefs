(//// click oscillator
SynthDef(\click, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!78);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)

(//// click oscillator
SynthDef(\click13, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!13);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)

(//// click oscillator
SynthDef(\clickmono, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!1);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)