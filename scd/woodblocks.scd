// Basic woodblock using a few carefully tuned resonators
(
SynthDef(\woodblock, {
    arg out=0, freq=1000, amp=0.5, pan=0;
    var exciter, modes, sig;

    // Modal frequencies based on wooden material characteristics
    // Frequencies are roughly related by ratios: 1, 2.42, 4.49, 6.21, 9.14
    var modeFreqs = freq * [1, 2.42, 4.49, 6.21, 9.14];
    // Decay times get shorter for higher modes
    var modeDecays = [0.02, 0.015, 0.012, 0.01, 0.008];
    var modeAmps = [1, 0.5, 0.35, 0.2, 0.15];

    // Short impulse excitation
    exciter = Impulse.ar(0) * amp;

    // Bank of resonators
    modes = Mix.fill(modeFreqs.size, {|i|
        Ringz.ar(
            exciter,
            modeFreqs[i],
            modeDecays[i],  // decay time in seconds
            modeAmps[i]     // amplitude for each mode
        )
    });

    sig = modes * EnvGen.kr(Env.perc(0.001, 0.1), doneAction: 2);

    Out.ar(out, Pan2.ar(sig, pan));
}).play;
)

// More complex marimba/wooden bar with adjustable strike position
(
SynthDef(\woodenbar13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(60!nch).midicps,
        amp=\amp.kr(0.5!nch),
        strikePos=\strikepos.kr(0.425!nch),
        hardness=\hardness.kr(0.05!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var exciter, modes;
        var nModes = 6;  // increased number of modes for richer sound

        // Mode frequencies based on Euler-Bernoulli beam theory
        var modeFreqs = Array.fill(nModes, {|i|
            var n = i + 1;
            freq[chan] * ((n * pi).squared * (1 + 0.5 * 0.075 * (n * pi).squared)).sqrt
        });

        // Mode decay times
        var modeDecays = Array.fill(nModes, {|i|
            0.05 * exp(-0.4 * i)
        });

        // Strike position dependent amplitudes
        var modeAmps = Array.fill(nModes, {|i|
            sin(pi * (i + 1) * strikePos[chan])
        });

        // Exciter signal
        exciter = EnvGen.ar(
            Env.perc(0.0005, 0.01, curve: -4),
            levelScale: amp[chan],
            gate: gate[chan]
        ) * WhiteNoise.ar;

        // Mallet hardness filtering
        exciter = RLPF.ar(
            exciter,
            freq[chan] * (10 + (hardness[chan] * 20)),
            0.5
        );

        // Modal resonator bank
        modes = Mix.fill(nModes, {|i|
            Ringz.ar(
                exciter,
                modeFreqs[i],
                modeDecays[i],
                modeAmps[i]
            )
        });

        // Envelope
        modes * EnvGen.kr(
            Env.perc(0.001, 0.1),
            gate: gate[chan],
            doneAction: 0
        )
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\templeBlock, {
    arg out=0, freq=900, amp=0.5, pan=0;
    var exciter, modes, sig;
    var nModes = 2;

    // More inharmonic mode relationships for temple block character
    var modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62];
    var modeFreqs = modeRatios * freq;

    // Longer decay times for temple block's hollow resonance
    var modeDecays = Array.fill(nModes, {|i|
        0.1 * exp(-0.3 * i)
    });

    // Specific mode amplitudes for temple block character
    var modeAmps = [1, 0.7, 0.45, 0.35, 0.25, 0.15, 0.1, 0.05];

    // Sharp attack with slight noise component
    exciter = EnvGen.ar(
        Env.perc(0.0005, 0.01, curve: -4),
        levelScale: amp
    ) * (Impulse.ar(0) + (WhiteNoise.ar * 0.1));

    // Modal resonators
    modes = Mix.fill(nModes, {|i|
        Ringz.ar(
            exciter,
            modeFreqs[i],
            modeDecays[i],
            modeAmps[i]
        )
    });

    // Overall envelope with longer decay for temple block
    sig = modes * EnvGen.kr(Env.perc(0.001, 0.2), doneAction: 2);

    Out.ar(out, Pan2.ar(sig, pan));
}).play;
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\woodblock13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(48!nch).midicps,
    amp=\amp.kr(0.5!nch),
    strikePos=\strikepos.kr(0.93!nch),
    hardness=\hardness.kr(0.027!nch),
    thickness=\thickness.kr(0.95!nch),
    hollow=\hollow.kr(0.97!nch),
    decay=\decay.kr(1!nch),
    bright=\bright.kr(0.95!nch),
    gate=\gate.kr(0!nch);

    var sig;
    var nModes = 12;
    var modeRatios = [1, 1.47, 2.09, 2.56, 3.39, 4.08, 4.87, 5.62, 6.15, 7.23, 8.17, 9.32];

    // Generate per-channel signals
    sig = nch.collect({ |chan|
        var exciter, modes;
        var chanFreq = freq[chan];

        // Per-channel mode frequencies
        var modeFreqs = modeRatios.collect({ |ratio, i|
            chanFreq * ratio * (1 + (thickness[chan] * 0.1 * i))
        });

        // Per-channel decay times
        var modeDecays = Array.fill(nModes, {|i|
            var baseDecay = decay[chan] * (0.1 * exp(-0.25 * i));
            var hollowFactor = hollow[chan].linexp(0, 1, 1, 3);
            baseDecay * hollowFactor
        });

        // Per-channel amplitudes
        var modeAmps = Array.fill(nModes, {|i|
            var posAmp = sin(pi * (i + 1) * strikePos[chan]);
            var brightAmp = bright[chan].linexp(0, 1, 0.4, 1.5);
            posAmp * (brightAmp ** (-1 * i/4))
        });

        // Per-channel exciter
        exciter = Mix([
            EnvGen.ar(
                Env.perc(0.0001, 0.001, curve: -8),
                levelScale: amp[chan] * hardness[chan],
                gate: gate[chan]
            ) * Impulse.ar(0),

            EnvGen.ar(
                Env.perc(0.0005, 0.01, curve: -4),
                levelScale: amp[chan] * (1 - hardness[chan]),
                gate: gate[chan]
            ) * BPF.ar(WhiteNoise.ar, chanFreq * 2, 0.5),

            EnvGen.ar(
                Env.perc(0.0003, 0.003, curve: -6),
                levelScale: amp[chan] * hardness[chan] * 0.3,
                gate: gate[chan]
            ) * HPF.ar(BrownNoise.ar, 5000)
        ]);

        exciter = (exciter * (1 + (exciter * hardness[chan]))).clip2(1);

        // Per-channel modal bank
        modes = Mix.fill(nModes, {|i|
            var mode = Ringz.ar(
                exciter,
                modeFreqs[i] * LFNoise1.kr(10, 0.001, 1),
                modeDecays[i],
                modeAmps[i]
            );

            mode + (
                Ringz.ar(
                    mode,
                    modeFreqs.wrapAt(i+1),
                    modeDecays[i] * 0.5
                ) * 0.05
            )
        });

        // Per-channel processing
        modes = modes * (1 + (modes * 0.1 * hollow[chan])).clip2(1);

        LPF.ar(
            modes * EnvGen.kr(
                Env.perc(0.001, 0.2 * decay[chan], 1, -4),
                gate: gate[chan],
                doneAction: 0
            ),
            chanFreq * 20 * (1 - (hollow[chan] * 0.3))
        )
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)
