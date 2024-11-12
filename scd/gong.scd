(
SynthDef(\gongbell, {
    arg out=0, freq=180, amp=0.5,
        // Strike parameters
        force=0.5,        // strike force (nonlinear behavior increases with force)
        strikePos=0.3,    // normalized strike position
        mallet=0.95,       // mallet hardness
        // Gong characteristics
        size=0.90,         // overall size scaling
        shimmer=0.6,      // amount of high frequency shimmer
        edge=0.05,         // edge tone emphasis
        // Envelope
        sustainTime=15.0,  // duration before decay
        gate=1;

    var strike, modes, edge_modes, crash, sig;
    var nModes = 12;
    var nEdgeModes = 8;

    // Center frequencies for main modes (based on tam-tam measurements)
    var modeRatios = [1, 1.75, 2.31, 2.88, 3.67, 4.23, 5.15, 6.42, 7.88, 9.56, 11.23, 13.37];

    // Edge mode ratios (higher, more inharmonic)
    var edgeRatios = [4.76, 6.12, 7.54, 9.13, 11.02, 13.47, 15.89, 18.56];

    // Nonlinear frequency shift based on force (pitch glide effect)
    var freqShift = force.linexp(0, 1, 1, 0.7);

    // Initial strike sound
    strike = Mix([
        // Impact
        EnvGen.ar(
            Env.perc(0.001, 0.01, curve: -4),
            levelScale: force
        ) * WhiteNoise.ar,

        // Mallet thump
        EnvGen.ar(
            Env.perc(0.001, 0.05, curve: -4),
            levelScale: force * (1 - mallet)
        ) * BrownNoise.ar * 0.5
    ]);

    // Main gong modes
    modes = Mix.fill(nModes, {|i|
        var baseFreq = freq * modeRatios[i];
        var detuneAmt = force.linexp(0, 1, 0.001, 0.05); // More detuning with harder hits
        var detunedFreq = baseFreq * LFNoise2.kr(
            shimmer.linexp(0, 1, 0.1, 2),
            detuneAmt,
            1
        );
        var decay = size * (8 - (i * 0.4)).clip(0.5, 10);
        var amp = force.linlin(0, 1, 1, 3) * // Nonlinear amplitude response
                exp(-0.7 * i) *
                sin(pi * strikePos * (i + 1));

        // Frequency shift envelope for crash
        var freqEnv = EnvGen.kr(
            Env(
                [1, freqShift, 1],
                [0.1, sustainTime],
                [3, 1]
            )
        );

        Klank.ar(`[
            [detunedFreq * freqEnv],
            [amp],
            [decay]
        ], strike) * (1/nModes)
    });

    // Edge modes (higher frequencies, more chaotic)
    edge_modes = Mix.fill(nEdgeModes, {|i|
        var baseFreq = freq * edgeRatios[i];
        var decay = size * (3 - (i * 0.2)).clip(0.2, 5);
        var amp = edge * force *
                exp(-0.9 * i) *
                sin(pi * strikePos * (i + 1));

        Klank.ar(`[
            [baseFreq * (1 + LFNoise2.kr(1.5, 0.02 * force))],
            [amp],
            [decay]
        ], strike) * (1/nEdgeModes)
    });

    // Crash layer for very hard strikes
    crash = (force > 0.7).if({
        var crashNoise = PinkNoise.ar * Line.kr(1, 0, 0.2);
        var numCrashModes = 10;

        Mix.fill(numCrashModes, {|i|
            var crashFreq = freq * (i + 1) * LFNoise2.kr(2, 0.05, 1);
            var crashDecay = 0.1 + (0.1 * i);

            BPF.ar(
                crashNoise,
                crashFreq,
                0.3,
                force.linexp(0.7, 1, 0.0, 0.2) * exp(-0.3 * i)
            )
        })
    }, 0);

    // Mix all components
    sig = Mix([
        modes,
        edge_modes * edge,
        crash
    ]);

    // Add subtle distortion for harder strikes
    sig = (sig * (1 + (sig.abs * force * 0.2))).tanh;

    // Overall envelope
    sig = sig * EnvGen.kr(
        Env.asr(
            attackTime: 0.005,
            sustainLevel: 1,
            releaseTime: size * 5,
            curve: [-2, -4]
        ),
        gate: gate,
        doneAction: 2
    );

    // Output with stereo spread
    sig = Splay.ar(
        Array.fill(2, {|i|
            DelayC.ar(
                sig,
                0.01,
                LFNoise2.kr(0.1).range(0, 0.01)
            )
        }),
        0.4
    );

    Out.ar(out, Limiter.ar(sig * amp, 0.95));
}).play;
)

(
SynthDef(\chineseGong, {
    arg out=0, freq=180, amp=0.25,
        // Strike parameters
        force=0.5,        // strike force (nonlinear behavior increases with force)
        strikePos=0.3,    // normalized strike position
        mallet=0.95,       // mallet hardness
        // Gong characteristics
        size=1.0,         // overall size scaling
        shimmer=0.6,      // amount of high frequency shimmer
        bloomTime=2.0,    // time for spectral diffusion
        bloomAmount=0,  // intensity of spectral bloom
        gate=1;

    var strike, modes, sig;
    var nModes = 12;
    var fundamentalEnv, bloomEnv, exciterEnv;

    // Center frequencies for main modes
    var modeRatios = [1, 1.75, 2.31, 2.88, 3.67, 4.23, 5.15, 6.42, 7.88, 9.56, 11.23, 13.37];

    // Bloom envelope - controls evolution of high frequency content
    bloomEnv = EnvGen.kr(
        Env.new(
            levels: [0, 0, bloomAmount],
            times: [0.1, bloomTime],
            curve: [0, 3]
        ),
        gate: gate
    );

    // Fundamental envelope - stronger at start, then decreases
    fundamentalEnv = EnvGen.kr(
        Env.new(
            levels: [1, 1, 0.3],
            times: [0.1, bloomTime],
            curve: [0, -2]
        ),
        gate: gate
    );

    // Initial strike
    strike = Mix([
        EnvGen.ar(
            Env.perc(0.001, 0.01, curve: -4),
            levelScale: force
        ) * WhiteNoise.ar,
        EnvGen.ar(
            Env.perc(0.001, 0.05, curve: -4),
            levelScale: force * (1 - mallet)
        ) * BrownNoise.ar * 0.5
    ]);

    // Exciter envelope for energy diffusion
    exciterEnv = EnvGen.kr(
        Env.new(
            levels: [1, 1, 4, 3, 2],
            times: [0.1, bloomTime * 0.2, bloomTime * 0.3, bloomTime * 0.5],
            curve: [0, 2, -1, -2]
        ),
        gate: gate
    );

    // Main resonant modes with spectral evolution
    modes = Mix.fill(nModes, {|i|
        var baseFreq = freq * modeRatios[i];
        var fundamentalAmp = fundamentalEnv * exp(-0.7 * i);
        var bloomAmp = bloomEnv * exp(-0.2 * i);
        var totalAmp = force * (fundamentalAmp + bloomAmp);

        // Each mode drives a cluster of frequencies
        var mode = Klank.ar(`[
            // Main frequency + overtones
            [
                baseFreq,
                baseFreq * (1 + (0.01 * LFNoise2.kr(0.2))),
                baseFreq * (1 + (0.02 * LFNoise2.kr(0.3)))
            ],
            // Amplitudes evolve with bloom
            [
                totalAmp,
                totalAmp * 0.5,
                totalAmp * 0.3
            ],
            // Decay times increase with force
            [
                3 * size * (1 + (force * 2)),
                2 * size * (1 + (force * 2)),
                1 * size * (1 + (force * 2))
            ]
        ], strike);

        // Add energy-driven high frequency content
        mode = mode + (
            // High frequency resonators excited by mode energy
            Ringz.ar(
                mode.abs * exciterEnv * bloomEnv,
                [
                    baseFreq * 2.78,
                    baseFreq * 4.39,
                    baseFreq * 6.26,
					baseFreq * 3.24,
                    baseFreq * 5.13,
                    baseFreq * 6.82

                ],
                [0.1, 0.07, 0.05]
            ).sum * 0.1
        );

        // Nonlinear feedback based on mode energy
        mode = mode + (
            HPF.ar(
                (mode * mode.abs * 0.3).clip2(1),
                baseFreq * 2
            ) * bloomEnv * 0.32
        );

        mode
    });

    // Add time-varying resonant filters driven by signal energy
    sig = modes + Mix.fill(6, {|i|
        var filterFreq = freq * (i + 3) * (1 + (bloomEnv * 2));
        var rq = 0.3 - (bloomEnv * 0.2);

        BPF.ar(
            modes * modes.abs * exciterEnv,
            filterFreq * LFNoise2.kr(0.1, 0.02, 1),
            rq,
            0.1
        )
    });

    // Overall envelope
    sig = sig * EnvGen.kr(
        Env.asr(
            attackTime: 0.005,
            sustainLevel: 1,
            releaseTime: size * 5,
            curve: [-2, -4]
        ),
        gate: gate,
        doneAction: 2
    );

    // Stereo spread increases with spectral content
    sig = Splay.ar(
        Array.fill(3, {|i|
            DelayC.ar(
                sig,
                0.02,
                LFNoise2.kr(0.1 + (bloomEnv * 0.5)).range(0, 0.02)
            )
        }),
        0.3 + (bloomEnv * 0.4)
    );

    Out.ar(out, Limiter.ar(sig * amp * 0.3, 0.95));
}).play;
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\chinesegong13, {
    arg out=0;
    var nch=13;
    var chanSig;
    var freq=\pitch.kr(36!nch).midicps,
        amp=\amp.kr(0.25!nch),
        force=\force.kr(0.95!nch),
        strikePos=\strikepos.kr(0.3!nch),
        mallet=\mallet.kr(0.5!nch),
        size=\size.kr(1.0!nch),
        shimmer=\shimmer.kr(0.6!nch),
        bloomTime=\bloomtime.kr(2.0!nch),
        bloomAmount=\bloomamount.kr(0.59997!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var strike, modes;
        var fundamentalEnv, bloomEnv, exciterEnv;
        var nModes = 12;
        var modeRatios = [1, 1.75, 2.31, 2.88, 3.67, 4.23, 5.15, 6.42, 7.88, 9.56, 11.23, 13.37];

        bloomEnv = EnvGen.kr(
            Env.new(
                levels: [0, 0, 0, bloomAmount[chan]],
                times: [0, 0.1, bloomTime[chan]],
                curve: [0, 0, 3]
            ),
            gate: gate[chan]
        );

        fundamentalEnv = EnvGen.kr(
            Env.new(
                levels: [0, 1, 1, 0.3],
                times: [0, 0.1, bloomTime[chan]],
                curve: [0, 0, -2]
            ),
            gate: gate[chan]
        );

        strike = Mix([
            EnvGen.ar(
                Env.perc(0.001, 0.01, curve: -4),
				levelScale: force[chan], gate: gate[chan]
            ) * WhiteNoise.ar,
            EnvGen.ar(
                Env.perc(0.001, 0.05, curve: -4),
                levelScale: force[chan] * (1 - mallet[chan]), gate: gate[chan]
            ) * BrownNoise.ar * 0.5
        ]);

        exciterEnv = EnvGen.kr(
            Env.new(
                levels: [0, 1, 1, 4, 3, 2],
                times: [0, 0.1, bloomTime[chan] * 0.2, bloomTime[chan] * 0.3, bloomTime[chan] * 0.5],
                curve: [0, 0, 2, -1, -2]
            ),
            gate: gate[chan]
        );

        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * modeRatios[i];
            var fundamentalAmp = fundamentalEnv * exp(-0.7 * i);
            var bloomAmp = bloomEnv * exp(-0.2 * i);
            var totalAmp = force[chan] * (fundamentalAmp + bloomAmp);

            var mode = DynKlank.ar(`[
                [
                    baseFreq,
                    baseFreq * (1 + (0.01 * LFNoise2.kr(0.2))),
                    baseFreq * (1 + (0.02 * LFNoise2.kr(0.3)))
                ],
                [
                    totalAmp,
                    totalAmp * 0.5,
                    totalAmp * 0.3
                ],
                [
                    3 * size[chan] * (1 + (force[chan] * 2)),
                    2 * size[chan] * (1 + (force[chan] * 2)),
                    1 * size[chan] * (1 + (force[chan] * 2))
                ]
            ], strike);

            mode = mode + (
                Ringz.ar(
                    mode.abs * exciterEnv * bloomEnv,
                    [
                        baseFreq * 2.78,
                        baseFreq * 4.39,
                        baseFreq * 6.26,
                        baseFreq * 3.24,
                        baseFreq * 5.13,
                        baseFreq * 6.82
                    ],
                    [0.1, 0.07, 0.05]
                ).sum * 0.1
            );

            mode = mode + (
                HPF.ar(
                    (mode * mode.abs * 0.3).clip2(1),
                    baseFreq * 2
                ) * bloomEnv * 0.32
            );

            mode
        });

        chanSig = modes + Mix.fill(6, {|i|
            var filterFreq = freq[chan] * (i + 3) * (1 + (bloomEnv * 2));
            var rq = 0.3 - (bloomEnv * 0.2);

            BPF.ar(
                modes * modes.abs * exciterEnv,
                filterFreq * LFNoise2.kr(0.1, 0.02, 1),
                rq,
                0.1
            )
        });

        chanSig = chanSig * EnvGen.kr(
            Env.new(
                levels: [0, 1, 1, 0],
                times: [0, 0.005, size[chan] * 5],
                curve: [-2, 0, -4]
            ),
            gate: gate[chan]
        );

        chanSig * amp[chan]
    });

    Out.ar(out, Limiter.ar(sig * 0.3, 0.95));
}).writeDefFile(d);
)

// Create synth
x = Synth(\chinesegong13);

// Trigger one channel
x.set(\gate, [0] ++ (0!12));

// Trigger multiple channels
x.set(\gate, [1,1,1,0,1,0,1,0,1,0,1,0,1]);

// Trigger same channels again after a while
x.set(\gate, [1,0,1,0,1,0,1,0,1,0,1,0,1]);

// Different pattern
x.set(\gate, [1,1,0,0,1,1,0,0,1,1,0,0,1]);

(
(
SynthDef(\chinesegong13, {
    arg out=0;
    var nch=2;

    // Parameters with multichannel expansion
    var freq = \pitch.kr(36!nch).midicps;
    var amp = \amp.kr(0.25!nch);
    var force = \force.kr(1.95!nch);
    var strikePos = \strikepos.kr(0.5!nch);
    var mallet = \mallet.kr(0.5!nch);
    var size = \size.kr(1.0!nch);
    var shimmer = \shimmer.kr(0.90006!nch);
    var bloomTime = \bloomtime.kr(2.0!nch);
    var bloomAmount = \bloomamount.kr(1!nch);
    var gate = \gate.kr(1!nch);

    var modeRatios = [1, 1.75, 2.31, 2.88, 3.67, 4.23, 5.15, 6.42, 7.88, 9.56, 11.23, 13.37];
    var nModes = 12;

    var sig = nch.collect({ |chan|
        var strike, modes;
        var fundamentalEnv, bloomEnv, exciterEnv;

        bloomEnv = EnvGen.ar(
            Env.new(
                levels: [0, 0, 0, bloomAmount[chan]],
                times: [0, 0.1, bloomTime[chan]],
                curve: [0, 0, 1.5]
            ),
            gate: gate[chan]
        );

        fundamentalEnv = EnvGen.ar(
            Env.new(
                levels: [0, 1, 1, 0.3],
                times: [0, 0.1, bloomTime[chan]],
                curve: [0, 0, -2]
            ),
            gate: gate[chan]
        );

        strike = Mix([
            EnvGen.ar(
                Env.perc(0.001, 0.01, curve: -4),
                levelScale: force[chan], gate: gate[chan]
            ) * WhiteNoise.ar,
            EnvGen.ar(
                Env.perc(0.001, 0.05, curve: -4),
                levelScale: force[chan] * (1 - mallet[chan]), gate: gate[chan]
            ) * BrownNoise.ar * 0.5
        ]);

        exciterEnv = EnvGen.ar(
            Env.new(
                levels: [0, 1, 1, 4, 3, 2],
                times: [0, 0.1, bloomTime[chan] * 0.2, bloomTime[chan] * 0.3, bloomTime[chan] * 0.5],
                curve: [0, 0, 2, -1, -2]
            ),
            gate: gate[chan]
        );

        // Modal synthesis with more metallic character
        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * modeRatios[i];
            var fundamentalAmp = fundamentalEnv * exp(-0.7 * i);
            var bloomAmp = bloomEnv * exp(-0.2 * i);
            var totalAmp = force[chan] * (fundamentalAmp + bloomAmp);
            var decayTime = size[chan] * (1 + (force[chan] * 2));

            // Main resonator bank with detuned partials
            DynKlank.ar(`[
                // Frequencies with slight detuning
                [
                    baseFreq,
                    baseFreq * 1.001 + (baseFreq * 0.02 * LFNoise2.ar(0.02)),
                    baseFreq * 0.999 + (baseFreq * 0.02 * LFNoise2.ar(0.015))
                ],
                // Amplitudes
                [
                    totalAmp,
                    totalAmp * 0.5,
                    totalAmp * 0.3
                ],
                // Decay times
                [
                    decayTime,
                    decayTime * 0.9,
                    decayTime * 0.8
                ]
            ], strike) +

            // Additional inharmonic resonators
            DynKlank.ar(`[
                [
                    baseFreq * 2.1,
                    baseFreq * 3.98,
                    baseFreq * 5.33
                ] + (baseFreq * 0.015 * LFNoise2.ar(0.1 ! 3)),
                [
                    totalAmp * 0.3,
                    totalAmp * 0.2,
                    totalAmp * 0.1
                ],
                [
                    decayTime * 0.5,
                    decayTime * 0.4,
                    decayTime * 0.3
                ]
            ], strike * 0.5);
        });

        // Add nonlinear processing for more metallicness
        modes = modes + (
            Ringz.ar(
                modes.abs * exciterEnv * bloomEnv,
                freq[chan] * [2.78, 4.39, 6.26]*4,
                [0.1, 0.07, 0.05]*4
            ).sum * 0.21
        );

        // Bloom processing
        modes = modes + Mix.fill(6, {|i|
            var filterFreq = freq[chan] * (i + 3) * (1 + (bloomEnv * 2));
            var rq = 0.3 - (bloomEnv * 0.2);

            BPF.ar(
                modes * modes.abs * exciterEnv,
                filterFreq * LFNoise2.ar(0.1).range(0.98, 2.02),
                rq,
                0.1
            )
        });

        // Final envelope
        modes = modes * EnvGen.ar(
            Env.new(
                levels: [0, 1, 1, 0],
                times: [0, 0.005, size[chan] * 5],
                curve: [-2, 0, -1]
            ),
            gate: gate[chan]
        );

        modes * amp[chan]
    });

    Out.ar(out, Limiter.ar(sig * 0.3, 0.95));
}).play();
)
)