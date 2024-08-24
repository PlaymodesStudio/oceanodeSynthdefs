(
SynthDef(\realsnare2, {
    arg out=0;
	var gate=\gate.kr(0);
    var transient, resonance, snare;
    var sig;
    var transp=\transp.kr(139);
    var transpw=\transpw.kr(0.3);
    var env = EnvGen.kr(Env.perc(0, \finaldec.kr(0.7)), gate);

    transient = WhiteNoise.ar + Pulse.ar(transp, transpw);
    transient = HPF.ar(transient, \transhp.kr(120));
    transient = BPeakEQ.ar(transient, [300, 1000], 1, [1.1, 0.6]);
    transient = transient * EnvGen.kr(Env.perc(0, \transdec.kr(0.079)), gate) * \transdb.kr(3).dbamp;

    snare = BPeakEQ.ar(WhiteNoise.ar, 2000, 0, 6.3) * EnvGen.kr(Env.perc(0, \wnoisedec.kr(10.17)), gate) * \wnoisedb.kr(-3).dbamp;
    snare = HPF.ar(snare, \wnoisehp.kr(300));

    resonance = transient + LocalIn.ar(1);
    resonance = DelayC.ar(resonance, 0.4, 0.01152);
    resonance = HPF.ar(resonance, \resohp.kr(400));
    resonance = LPF.ar(resonance, \resolp.kr(3000));
    resonance = BPeakEQ.ar(resonance, \resofreq.kr(550), 1.3, \resodb.kr(-4.3));
    resonance = resonance * \resolength.kr(30.11).dbamp;
    LocalOut.ar(resonance);
    resonance = resonance * -4.5.dbamp;

    sig = transient + resonance + snare ! 2;
    sig = sig + JPverb.ar(sig * -20.dbamp).sum;
    sig = BPeakEQ.ar(sig, 900, 1, \finaleq.kr(2.5));
    sig = HPF.ar(sig, \finalhp.kr(150));
    sig = (sig * 1.6).tanh * 0.7;
    sig = sig * env;
    sig = sig * -10.dbamp;

    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
