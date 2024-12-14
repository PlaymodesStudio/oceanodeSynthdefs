(
SynthDef(\asymParSat13, {
    arg out=0, in=0;
    var sym, softhard, satpos, satneg, hipos, hineg, sympos, symneg, inputsig,
        eventclippos, eventclipneg, clippedsigpos, clippedsigneg, finalsig,
        satarray, dry, wet;

    // Parameters
    var inputGain = \inputgain.kr(1!13);
    softhard = \softhard.kr(0.5!13);
    sym = \sym.kr(0.5!13);
    var mix = \mix.kr(1!13);

    // Input stage
    inputsig = In.ar(in, 13);
    dry = inputsig;
    inputsig = inputsig * inputGain;

    // Saturation calculations
    hipos = softhard;
    hineg = softhard;
    sympos = sym + 1;
    symneg = sym.neg + 1;

    eventclippos = Clip.kr(hipos, 0.00001, 0.99999) * sympos;
    eventclipneg = Clip.kr(hineg, 0.00001, 0.99999) * symneg;
    clippedsigpos = Clip.ar(inputsig, eventclippos.neg, eventclippos);
    clippedsigneg = Clip.ar(inputsig, eventclipneg.neg, eventclipneg);

    satpos = ((((eventclippos.neg) + sympos) * 0.5) *
             SoftClipAmp.ar((((((eventclippos.neg) + sympos) * 0.5).reciprocal) *
             (clippedsigpos.neg + inputsig)))) + clippedsigpos;

    satneg = ((((eventclipneg.neg) + symneg) * 0.5) *
             SoftClipAmp.ar((((((eventclipneg.neg) + symneg) * 0.5).reciprocal) *
             (clippedsigneg.neg + inputsig)))) + clippedsigneg;

    satarray = [satpos, satneg];
    wet = Select.ar((inputsig + 1) / 2, satarray);

    // Mix dry and wet signals
    finalsig = XFade2.ar(dry, wet, mix * 2 - 1);

    Out.ar(out, finalsig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
