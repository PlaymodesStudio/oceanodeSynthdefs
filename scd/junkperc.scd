(
SynthDef(\junkperc2, {
	arg out=0;
    var curv, dev,rndms,attack, decay, snd, freqs, ratio, velocity, trigger;
	velocity = \velocity.kr(1);
    ratio = \ratio.kr(1);
    trigger = \trigger.kr(1);
	decay=\decay.kr(1);
	attack=\attack.kr(1);
	dev=\pdevratio.kr(1);
	curv= \curve.kr(-4);

	freqs=\pitches4.kr([60,67.5,76,130]).midicps;

	rndms=[TRand.kr(1,dev,trigger),TRand.kr(1,dev,trigger),TRand.kr(1,dev,trigger),TRand.kr(1,dev,trigger)];

	snd = SinOsc.ar((freqs*rndms)*ratio);
	snd = snd * EnvGen.kr(Env.perc(0.001*attack, ([0.1, 0.03, 0.04, 0.08] * 6 / ratio.squared)*decay, curve: curv), trigger);
    snd = snd * ({ Rand(0, -7) } ! snd.size).dbamp;
    snd = snd.sum;
    snd = snd * -6.dbamp;
    snd = snd * (1 + (SinOsc.ar(Hasher.kr(ratio).linexp(-1, 1, 1000, 4000)) * EnvGen.kr(Env.perc(0.001*attack, 0.3*decay, curve: curv), trigger) * velocity));
    snd = snd + (BPF.ar(WhiteNoise.ar, 1320 * ratio, 0.1) * EnvGen.kr(Env.perc(0.003*attack, 0.03*decay, curve: curv), trigger) * 3.dbamp);
    snd = snd * EnvGen.kr(Env([0, 1, 0.6, 0.9, Rand(0.1, 0.9), 1, 0], [0.001*attack, 0.003 * Rand(1, 2), 0.001 * Rand(1, 2), 0.01 * Rand(0.3, 1), 0.001, 1*decay], -4), trigger);
    snd = snd * (1 + (EnvGen.kr(Env.perc(0.001*attack, 0.03*decay, curve: curv), trigger) * 5));
    snd = snd * velocity.sqrt;
    snd = snd * Rand(1, 5);
    snd = snd.tanh;
    snd = snd + PitchShift.ar(snd, 0.07, Hasher.kr(ratio + 1.3).linexp(0, 1, 1, 2));
    snd = snd + PitchShift.ar(snd * -6.dbamp, 0.06, 0.7);
    snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio + 1) * 10).midiratio / 100, 0.1);
    snd = CombC.ar(snd, 0.2, (Hasher.kr(ratio + 1) * 20).midiratio / 100, 0.03);
    snd = Pan2.ar(snd, 0) + GVerb.ar(HPF.ar(snd, 200) * -14.dbamp, 3);
    snd = snd * EnvGen.kr(Env.perc(velocity.linlin(0, 1, 0.01, 0.001)*attack, 1*decay, curve: curv), trigger);
    snd = snd * -8.dbamp;
    snd = Limiter.ar(snd);
    Out.ar(out, snd);
}).writeDefFile(d);
)

x = Synth(\junkperc2);

x.set(\trigger, 0);
x.set(\trigger, 1);


d = thisProcess.nowExecutingPath.dirname;

