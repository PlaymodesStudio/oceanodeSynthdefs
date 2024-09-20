d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\steeldrum, {
    arg out = 0;
    var t_gate, freq, amp, pan, att, dec, curve, filterHarmonic;
    var resFreqArray, resAmpArray, resDecArray, enva, envb, envc, snda, sndb, sndc, snd;

    // Named controls
    t_gate = \gate.kr(1);
    freq = \pitch.kr(60).midicps;
    amp = \amp.kr(0.1);
    pan = \pan.kr(0);
    att = \att.kr(0.01);
    dec = \dec.kr(1.5);
    curve = \curve.kr(-6);
    filterHarmonic = \harmonic.kr(6);

    // Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes:
    resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
    resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
    resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

    // Custom envelope shapes attempting to capture the apparent "bloom" of a note:
    enva = EnvGen.kr(Env.pairs([[0, 0], [att, 1], [(att + dec), 0]], curve), gate: t_gate);
    envb = EnvGen.kr(Env.pairs([[0, 0], [(att * 5), 0.25], [(att * 6), 0.75], [((att * 6) + (dec / 2)), 0]], curve), gate: t_gate);
    envc = EnvGen.kr(Env.pairs([[0, 0], [(att * 5), 0.1], [(att * 8), 0.5], [((att * 8) + (dec / 3)), 0]], curve), gate: t_gate);

    // Fundamental, octave up, and a bank of enharmonic resonators excited by a metallic sound:
    snda = SinOsc.ar(freq: freq, mul: enva);
    sndb = SinOsc.ar(freq: freq * 2.015, mul: envb);
    sndc = DynKlank.ar(
        specificationsArrayRef:
            Ref.new([
                resFreqArray * freq,
                resAmpArray,
                resDecArray * dec
            ]),
        input:
        LPF.ar(HPF.ar(CombN.ar(PinkNoise.ar(envc), 1/freq, 1/freq, -1), freq * 2), freq * filterHarmonic)
    );

    // Output stages with a tiny bit of compression to smooth things out:
    snd = Mix.ar([snda, sndb, sndc]) * (amp / 3);
    snd = Limiter.ar(snd, amp);

    Out.ar(out, Pan2.ar(snd, pan));
}).writeDefFile(d);
)

// Example usage:
x = Synth(\steeldrum);

// Trigger the steeldrum sound
x.set(\gate, 1);

// Change parameters and trigger again
x.set(\freq, 330, \amp, 0.2, \dec, 2, \gate, 1);

// Release the sound
x.set(\gate, 0);