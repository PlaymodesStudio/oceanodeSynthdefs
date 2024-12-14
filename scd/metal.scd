(
SynthDef(\metal13, {
    arg out=0;
    var sig, exciter, modes;
    var numModes = 60;
    var nch = 13;

    // All control parameters as arrays
    var fundamental = \pitch.kr(60!nch).midicps;
    var strike = \strike.kr(0.05!nch);
    var hardness = \hardness.kr(0.15!nch);
    var harmony = \harmony.kr(0.0!nch);
    var t60 = \decay.kr(2.0!nch);
    var bright = \bright.kr(0.90!nch);
    var damp = \damp.kr(0.1!nch);
    var amp = \amp.kr(0.05!nch);
    var gate = \gate.kr(1!nch);
    var maxFreq = \maxfreq.kr(12000!nch);

    // Generate per-channel signals
    sig = nch.collect({ |chan|
        var chanModes, chanExciter, modeFreqs, modeAmps, modeDecays;
        var trig = gate[chan];  // Use gate directly for triggering

        // Generate new frequencies when triggered
        modeFreqs = Array.fill(numModes, { |i|
            var harmonicFreq = fundamental[chan] * (i + 1);
            var spreadFactor = i * harmony[chan] * 0.02;
            var inharmonicity = harmony[chan] * TRand.kr(1.0, 1.2, trig); // Use TRand for triggerable random
            var rawFreq = harmonicFreq * (1 + (spreadFactor * inharmonicity));
            min(rawFreq, maxFreq[chan])
        });

        // Amplitude distribution for this channel
        modeAmps = Array.fill(numModes, { |i|
            var harmonic = i + 1;
            var pos = strike[chan] * pi * harmonic;
            sin(pos) * (harmonic ** bright[chan].neg)
        });

        // Decay times for this channel
        modeDecays = Array.fill(numModes, { |i|
            var freq = modeFreqs[i];
            var freqScale = (1 / (freq ** 0.5));
            t60[chan] * freqScale * (1 - (damp[chan] * (i / numModes))) * 0.4
        });

        // Exciter for this channel - triggered
        chanExciter = EnvGen.ar(
            Env.perc(0.001, hardness[chan].linexp(0, 1, 0.001, 0.05)),
            trig
        ) * WhiteNoise.ar;

        // Resonator bank for this channel
        chanModes = DynKlank.ar(`[
            modeFreqs,
            modeAmps,
            modeDecays
        ], chanExciter);

        // Output envelope for this channel
        chanModes * EnvGen.ar(
            Env.perc(0.001, t60[chan] * 1.5, 1, -4),
            trig,
            amp[chan]
        )
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

// Create the synth
(
x = Synth(\metal13, [
    \pitch, Array.fill(13, {rrand(48, 72)}),
    \harmony, Array.series(13, 0, 0.08),
    \decay, Array.fill(13, {rrand(100, 400)}),
    \bright, Array.fill(13, {rrand(0.3, 0.9)}),
    \strike, Array.fill(13, {rrand(0.05, 0.3)}),
    \hardness, 0.15!13,
    \damp, 0.1!13,
    \amp, 0.05!13
]);
)

// Retrigger with new random frequencies
x.set(\gate, 1!13);

// Change harmony and retrigger - should get different frequency distributions
(
x.set(
    \harmony, Array.fill(13, {rrand(1.0, 1.90)}),
    \gate, 1!13
);
)