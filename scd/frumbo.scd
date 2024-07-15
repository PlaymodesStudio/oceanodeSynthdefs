(
SynthDef(\frumbo13, {
    arg out=0;
    var freq=\pitch.kr(24!13).midicps,
    amp=\levels.kr(0.5!13, 1/30, fixedLag: true),
    gate=\gate.kr(1!13),
    attack=\attack.kr(0.01!13),
    decay=\ampdec.kr(0.2!13),
    sustain=\ampsus.kr(0.5!13),
    release=\amprel.kr(0.1!13),
    pitchStartMult=\penvratio.kr(4!13),
    pitchEnvTime=\penvtime.kr(0.05!13),
    filterStartFreq=\filtstart.kr(130!13).midicps,
    filterEndFreq=\filtend.kr(36!13).midicps,
    filterEnvTime=\filtenvtime.kr(0.1!13),
    filterRes=\filtres.kr(0.5!13),
    fmp=\fmpitch.kr(48!13, 1/30, fixedLag: true),
    fmStart=\fmstart.kr(100!13, 1/30, fixedLag: true),
    fmEnd=\fmEnd.kr(100!13, 1/30, fixedLag: true),
    fmEnvTime=\fmenvtime.kr(0.1!13, 1/30, fixedLag: true),
    filterType=\filttype.kr(0!13); // 0: LP, 1: BP, 2: HP

    var sig, env, fm, fmEnv, pitchEnv, filterEnv, filteredSig;

    // Pitch envelope
    pitchEnv = EnvGen.kr(
        Env([0, freq * pitchStartMult, freq, freq], [0, pitchEnvTime, 0.01], \exp),
        gate
    );

    // Filter envelope
    filterEnv = EnvGen.kr(
        Env([0, filterStartFreq, filterEndFreq, filterEndFreq], [0, filterEnvTime, 0.01], \exp),
        gate
    );

    // FM envelope
    fmEnv = EnvGen.kr(
        Env([0, fmStart, fmEnd, 0], [0, fmEnvTime, 0.01], \exp),
        gate
    );

    fm = SinOsc.ar(fmp.midicps, 0) * fmEnv;

    // Amplitude envelope
    env = EnvGen.kr(
        Env([0, 0, 1, sustain, 0], [0, attack, decay, release], -4),
        gate
    );

    // Main oscillator
    sig = Squine.ar(pitchEnv + fm, \clip.kr(0!13, 1/30, fixedLag: true), \skew.kr(1!13, 1/30, fixedLag: true));

    // Filter with envelope and type selection
    filteredSig = Select.ar(filterType,
        [
            RLPF.ar(sig, filterEnv, filterRes),  // Low Pass
            BPF.ar(sig, filterEnv, filterRes),   // Band Pass
            RHPF.ar(sig, filterEnv, filterRes)   // High Pass
        ]
    );

    // Apply envelope and amplitude
    sig = filteredSig * env * amp;
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;