d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\noisegate13, {
    arg out=0, in=0;
	var thresh=\threshdb.kr(60).neg, attack=\attack.kr(0.01), release=\release.kr(0.01);
    var snd = In.ar(in, 13);
    var amp = Amplitude.kr(snd);
    var gate = amp > thresh.dbamp;
    var env = EnvGen.kr(Env.asr(attack, 1, release), gate);
    snd = snd * env;
    Out.ar(out, snd);
}).writeDefFile(d);
)

