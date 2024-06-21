(
SynthDef.new(\bubblea, {
	arg out=0;
	var t_trig=\trig.kr(1), attack=\attack.kr(0.01), decay=\decay.kr(0.08), pitchcurvelen=\curve.kr(0.1), freq=\freq.kr(200), amp=\amp.kr(1);
	var pitch, son;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.003), t_trig);
	pitch = freq * EnvGen.ar(Env.new([0,0,1],[0,1]).exprange(1, 2.718), t_trig, timeScale: pitchcurvelen);
	son = SinOsc.ar(pitch);
	son = HPF.ar(son, 500) * amp;
	Out.ar(out, Pan2.ar(son, \pan.kr(0)));
}).writeDefFile(d);
)

(
SynthDef.new(\bubbleb,{
	arg out=0;
	var sig, env, senv, trig=\trig.kr(1);
	senv = EnvGen.ar(Env([1,1,0,0],[3/SampleRate.ir,0.0,1.0]),trig);
	sig = WhiteNoise.ar() * senv;
	env = EnvGen.ar(Env([0,1,1,0],[0.001]++((\dur.kr(0.1)-0.001)*[0.4,0.6])),trig);
	sig = TwoTube.ar(sig,\k.kr(0.2),0.999,1,2);
		sig = BPF.ar(
			sig,
		LFNoise1.kr({LFNoise1.kr(0.13).exprange(3,4)}!8).exprange(30,6000),
		LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(0.005, 0.1)
		);
		sig = sig * env * 10 * \amp.kr(1);
		sig = Pan2.ar(sig,\pan.kr(0));
	Out.ar(out,sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
