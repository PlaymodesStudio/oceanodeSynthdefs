(
SynthDef(\flute13, {
	arg out=0;
	var numch=13;
	var pch = \pitch.kr(32!numch), ibreath = \ibreath.kr(0.09!numch),
	ifeedbk1 = \ifeedbk1.kr(0.4!numch), ifeedbk2 = \ifeedbk2.kr(0.4!numch), vibamp=\vibamp.kr(0.2!numch), vibfreq=\vibfreq.kr(5!numch), lpf=\lpf.kr(2000!numch);


	var noise=\noise.kr(1!numch);
	var levels=\levels.kr(1!numch);

    var kenv1, kenvibr, kvibr, sr, cr, block, poly, signalOut, ifqc, fdbckArray;
    var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
    sr = SampleRate.ir;
    cr = ControlRate.ir;
    block = cr.reciprocal;
    ifqc = pch.midicps;

    // create air flow and vibrato
    aflow1 = LFClipNoise.ar(sr!numch, noise);
    kvibr = SinOsc.ar(vibfreq, 0, 0.1 * vibamp);
    asum1 = (ibreath * aflow1) + noise + kvibr;
    afqc = ifqc.reciprocal - (asum1/20000) - (9/sr) + (ifqc/12000000) - block;
    fdbckArray = LocalIn.ar(numch);
    aflute1 = fdbckArray;
    asum2 = asum1 + (aflute1 * ifeedbk1);
    ax = DelayC.ar(asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - (asum1/ifqc/cr) + 0.001);
    apoly = ax - (ax.cubed);
    asum3 = apoly + (aflute1 * ifeedbk2);
	avalue = Sanitize.ar(LPF.ar(asum3, lpf));
    aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);
	LocalOut.ar(Sanitize.ar(aflute1)); //LocalOut.ar(Limiter.ar(aflute1,10)); doesnt blow but changes the sound
	signalOut = LeakDC.ar(avalue);
	signalOut = Limiter.ar(signalOut);
    Out.ar(out, signalOut * levels);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

stk