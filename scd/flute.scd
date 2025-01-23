(
SynthDef(\flute13, {
	arg out=0;
	var numch=13;
	var pch = \pitch.kr(32!numch, 1/30, fixedLag:true), ibreath = \ibreath.kr(0.09!numch,1/30, fixedLag:true),
	ifeedbk1 = \ifeedbk1.kr(0.4!numch,1/30, fixedLag:true), ifeedbk2 = \ifeedbk2.kr(0.4!numch,1/30, fixedLag:true), vibamp=\vibamp.kr(0.2!numch,1/30, fixedLag:true), vibfreq=\vibfreq.kr(5!numch,1/30, fixedLag:true), lpf=\lpf.kr(2000!numch,1/30, fixedLag:true);


	var noise=\noise.kr(1!numch,1/30, fixedLag:true);
	var levels=\levels.kr(1!numch,1/30, fixedLag:true);

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



(
SynthDef(\flute2_13, {
    arg out=0;
    var numch=13;

    // Original flute parameters
    var pch, ibreath, ifeedbk1, ifeedbk2, vibamp, vibfreq, lpf;
    var noise, levels, lpf_exciter, q, poles, dcnoise;
    var softhard, sym, push, offset, polarity;
    var gate, atk, rel, curve;
    var sr, cr, block, minDelay, crossoverFreq, crossoverNote;
    var ifqc, exciter_env, exciter_noise, filterednoises;
    var hipos, hineg, sympos, symneg;
    var lowSignal, highSignal, hybridSignal;

    // Variables for the lowSignal function
    var fdbckArray, aflow1, asum1, afqc, aflute1, asum2, ax, asum3, avalue;
    var eventclippos, eventclipneg, clippedsigpos, clippedsigneg;
    var satpos, satneg, saturatedSignal, delayedSignal;

    // Variables for the highSignal function
    var source, vib, freq, res1, res2, res3, mixed;

    // Parameter assignments
    pch = \pitch.kr(24!numch);
    ibreath = \ibreath.kr(0.09!numch);
    ifeedbk1 = \ifeedbk1.kr(0.4!numch);
    ifeedbk2 = \ifeedbk2.kr(0.4!numch);
    vibamp = \vibamp.kr(0.2!numch);
    vibfreq = \vibfreq.kr(5!numch);
    lpf = \lpf.kr(2000!numch);
    noise = \noise.kr(1!numch);
    levels = \levels.kr(1!numch);

    lpf_exciter = \breath_lpf.kr(80!numch).midicps;
    q = \q.kr(1!numch);
    poles = \poles.kr(0!numch);
    dcnoise = \dcnoise.kr(0!numch);

    softhard = \softhard.kr(0.5!numch);
    sym = \sym.kr(0.5!numch);
    push = \push.kr(1!numch);
    offset = \offset.kr(0!numch);
    polarity = \polarity.kr(1!numch);
    gate = \gate.kr(1!numch);
    atk = \atk.kr(0.01!numch);
    rel = \rel.kr(0.1!numch);
    curve = \curve.kr(-4!numch);

    // System variables
    sr = SampleRate.ir;
    cr = ControlRate.ir;
    block = cr.reciprocal;
    minDelay = (64/sr);
    crossoverFreq = minDelay.reciprocal;
    crossoverNote = 78;

    ifqc = pch.midicps;
    exciter_env = EnvGen.kr(
        envelope: Env.asr(attackTime: atk, sustainLevel: 1, releaseTime: rel, curve: curve),
        gate: gate
    );

    exciter_noise = WhiteNoise.ar(numch) * ibreath;
    filterednoises = [
        OnePole.ar(exciter_noise, exp(-2pi * (lpf_exciter / sr))),
        RLPF.ar(exciter_noise, lpf_exciter, q)
    ];
    exciter_noise = Select.ar(poles, filterednoises);
    exciter_noise = XFade2.ar(DC.ar(ibreath), exciter_noise, dcnoise);
    exciter_noise = exciter_noise * exciter_env;

    hipos = softhard;
    hineg = softhard;
    sympos = sym + 1;
    symneg = sym.neg + 1;

    // Low frequency model
    fdbckArray = LocalIn.ar(numch);
    aflow1 = exciter_noise;
    asum1 = aflow1 + (SinOsc.ar(vibfreq, 0, 0.1 * vibamp) * exciter_env);
    afqc = ifqc.reciprocal - (asum1/20000) - (9/sr) + (ifqc/12000000) - block;
    aflute1 = fdbckArray;
    asum2 = asum1 + (aflute1 * push * polarity) + (offset * polarity);
    ax = DelayC.ar(asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - (asum1/ifqc/cr) + 0.001);

    eventclippos = Clip.kr(hipos, 0.00001, 0.99999) * sympos;
    eventclipneg = Clip.kr(hineg, 0.00001, 0.99999) * symneg;
    clippedsigpos = Clip.ar(ax, eventclippos.neg, eventclippos);
    clippedsigneg = Clip.ar(ax, eventclipneg.neg, eventclipneg);

    satpos = ((((eventclippos.neg)+sympos)*0.5) *
        SoftClipAmp.ar((((((eventclippos.neg)+sympos)*0.5).reciprocal) *
        (clippedsigpos.neg + ax)))) + clippedsigpos;

    satneg = ((((eventclipneg.neg)+symneg)*0.5) *
        SoftClipAmp.ar((((((eventclipneg.neg)+symneg)*0.5).reciprocal) *
        (clippedsigneg.neg + ax)))) + clippedsigneg;

    saturatedSignal = Select.ar((ax+1)/2, [satpos, satneg]);
    asum3 = saturatedSignal + (aflute1 * ifeedbk2);
    avalue = LPF.ar(asum3, lpf);
    delayedSignal = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);

    LocalOut.ar(delayedSignal);
    lowSignal = LeakDC.ar(avalue);

    // High frequency model
    source = exciter_noise;
    vib = SinOsc.ar(vibfreq, 0, vibamp * exciter_env);
    freq = ifqc + vib;

    res1 = Resonz.ar(source, freq, 0.01, 2);
    res2 = Resonz.ar(source, freq * 2, 0.02, 1);
    res3 = Resonz.ar(source, freq * 3, 0.03, 0.5);

    mixed = (res1 + res2 + res3) * 4;
    mixed = mixed * (1 + (mixed * push * polarity)) + (offset * polarity);

    eventclippos = Clip.kr(hipos, 0.00001, 0.99999) * sympos;
    eventclipneg = Clip.kr(hineg, 0.00001, 0.99999) * symneg;
    clippedsigpos = Clip.ar(mixed, eventclippos.neg, eventclippos);
    clippedsigneg = Clip.ar(mixed, eventclipneg.neg, eventclipneg);

    satpos = ((((eventclippos.neg)+sympos)*0.5) *
        SoftClipAmp.ar((((((eventclippos.neg)+sympos)*0.5).reciprocal) *
        (clippedsigpos.neg + mixed)))) + clippedsigpos;

    satneg = ((((eventclipneg.neg)+symneg)*0.5) *
        SoftClipAmp.ar((((((eventclipneg.neg)+symneg)*0.5).reciprocal) *
        (clippedsigneg.neg + mixed)))) + clippedsigneg;

    saturatedSignal = Select.ar((mixed+1)/2, [satpos, satneg]);
    highSignal = BPF.ar(saturatedSignal, [500, 1200, 2400], [0.1, 0.1, 0.1], [1, 0.5, 0.25]).sum;

    // Final mix
    hybridSignal = XFade2.ar(
        lowSignal,
        highSignal,
        (pch - crossoverNote).linlin(0, 12, -1, 1).clip(-1, 1)
    );

    hybridSignal = hybridSignal * levels;
    hybridSignal = Limiter.ar(hybridSignal);

    Out.ar(out, hybridSignal);
}).writeDefFile(d);
)