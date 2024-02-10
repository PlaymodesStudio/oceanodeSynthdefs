
(
SynthDef.new(\buzz13, {
	arg out=0;
    var snd, buzz;
	var freq = VarLag.kr(\pitch.kr(28!13).midicps, 1/30);
	var noisef=VarLag.kr(\noise.kr(8210!13),1/30);
	var hif=VarLag.kr(\hif.kr(800!13),1/30);
	var levels=VarLag.kr(\levels.kr(0!13),1/30);
    snd = SinOsc.ar(freq);
    buzz = snd;
	buzz = buzz + (BPF.ar({ WhiteNoise.ar }, noisef, 0.3) * -20.dbamp);
    buzz = (buzz + 0.3).sign - buzz;
    buzz = buzz + DelayC.ar(buzz, 0.2, SinOsc.ar(0.3, [0, pi]).linlin(-1, 1, 0, 1) * 1e-3);
	snd = (snd * \distortion.kr(5!13)).tanh + (HPF.ar(buzz, hif) * -10.dbamp);
    snd = snd * levels * -15.dbamp;
    Out.ar(out, snd);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
