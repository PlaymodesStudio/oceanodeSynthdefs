d = thisProcess.nowExecutingPath.dirname;

//adapted from Josh Mitchell work July 2020.

(
SynthDef(\abstractdrum, {
    arg out = 0;
    var t_gate, freq, amp, pan, att, dec, rel, position, ampSlope, decCoef, hiFreqSus;
    var freqarray, amparray, decarray, exciter, snd, env;

    // Named controls
    t_gate = \gate.kr(1);
    freq = \pitch.kr(60).midicps;
    amp = \amp.kr(1);
    att = \att.kr(0.001);
    dec = \dec.kr(0.01);
    rel = \rel.kr(1);
    position = \pos.kr(0.5);
    ampSlope = \ampslope.kr(3);
    decCoef = \deccoef.kr(0.15);
    hiFreqSus = \hifreqsus.kr(0);

    // Setting up arrays for Klank
    freqarray = Array.fill(8, {
        arg i = 1;
        (
            Array.fill((i + 1), {
                arg j;
                (j + 1).pow(2)
            }) +
            (i + 1).pow(2)
        ).sqrt
    });
    freqarray = freqarray.flatten/(2.sqrt);
    amparray = Array.fill(36, {
        arg i;
        if (freqarray[i] > 20000)
            { 0 }
            {
                sin(((i + 1) * pi) * position) *
                (ampSlope * (freqarray[i]).log2).dbamp
            }
    });
    amparray = amparray/ampSlope;
    decarray = Array.fill(36, {
        arg i;
        exp(-1 * i * decCoef) + hiFreqSus
    });
    decarray = decarray/decarray[0];

    // Envelope for gating
    env = EnvGen.kr(Env.asr(att, 1, rel), gate: t_gate);

    // Exciter (now retriggerable)
    exciter = Decay2.ar(
        in: T2A.ar(t_gate),
        attackTime: att,
        decayTime: dec,
        mul: 0.005); // This keeps the volume at a sane level

    // The actual sound-makey part
    snd = DynKlank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: exciter,
        freqscale: freq,
        decayscale: rel);

    // Output Stuff
    snd = Mix.ar(snd * amp * 2);
    snd = Limiter.ar(snd);
    snd = snd * env;

    Out.ar(out, snd!2);
}).writeDefFile(d);
)

// Example usage:
x = Synth(\abstractdrum);

// Trigger the abstract drum sound
x.set(\gate, 1);

// Change parameters and trigger again
x.set(\freq, 100, \pos, 0.7, \deccoef, 0.2, \gate, 1);

// Release the sound
x.set(\gate, 0);