(
SynthDef(\fbdronemod13, {
	arg out=0;
    var snd, duration;
	var nch=13;
	var winsz=\winsz.kr(0.03!nch);
	var prelpf=\prelpf.kr(110!nch).midicps;
	var rlpfmax = \rlpfmax.kr(130!nch).midicps;
	 var lfo = { |rate|
        Select.ar(
            ToggleFF.ar(Dust.ar(rate)),
            [LFNoise2.ar(rate).clip2, TRand.ar(-1, 1, Dust.ar(rate * 30))]
        );
    };
	var deltime=lfo.(\deltimemod.kr(0.5)).linlin(-1, 1, 0.0, 0.04) + (lfo.(16 ! 2).linlin(-1, 1, 0.0, 0.001));
	var rlpfmod=lfo.(\rlpfmod.kr(3)).linexp(-1, 1, 100, rlpfmax);
	var ampmod=lfo.(\ampmod.kr(3)).linexp(0, 1, 1, 10.dbamp);
	var psmod=2 ** lfo.(\psmod.kr(1));

    snd = Hasher.ar(Sweep.ar);
    snd = snd + LocalIn.ar(nch);
	snd = DelayC.ar(snd, 0.2, deltime);
    snd = LeakDC.ar(snd);
    snd = snd + (snd.reverse * -10.dbamp);
    snd = snd + PitchShift.ar(snd, winsz, psmod);
    snd = LPF.ar(snd, prelpf);
    snd = RLPF.ar(snd, rlpfmod);
    snd = snd * ampmod;
    snd = snd.tanh;
    LocalOut.ar(snd);
    snd = snd * \levels.kr(0.5!nch);
    Out.ar(out, snd);
}).writeDefFile(d);
)


(
SynthDef(\fbdrone13, {
	arg out=0;
	var nch=13;
    var snd;
	var deltime = \delpitch.kr(31!nch).midicps.reciprocal;
	var winsize=\winsz.kr(0.03!nch);
	var prelpf=\prelpf.kr(110!nch).midicps;
	var rlpf = \lpf.kr(100!nch).midicps;
	var preamp = \preamp.kr(1!nch);

    var lfo = { |rate|
        Select.ar(
            ToggleFF.ar(Dust.ar(rate)),
            [LFNoise2.ar(rate).clip2, TRand.ar(-1, 1, Dust.ar(rate * 30))]
        );
    };

	var pratio = 2 ** lfo.(\psratio.kr(1!nch));

	snd = Hasher.ar(Sweep.ar(0,1)!nch);
    snd = snd + LocalIn.ar(nch);
    snd = DelayC.ar(snd, 0.2, deltime);
    snd = LeakDC.ar(snd);
    snd = snd + (snd.reverse * -10.dbamp);
    snd = snd + PitchShift.ar(snd, winsize, pratio);
    snd = LPF.ar(snd, prelpf);
    snd = RLPF.ar(snd, rlpf);
    snd = snd * preamp;
    snd = snd.tanh;
    LocalOut.ar(snd);
	snd = snd * \levels.kr(0.5!nch);
    Out.ar(out, snd);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


