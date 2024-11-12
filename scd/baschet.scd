d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\cristalbaschet13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(48!nch, 1/30, fixedLag:true).midicps,
        amp=\amp.kr(0.25!nch, 1/30, fixedLag:true),
        rodPressure=\rodpressure.kr(0.5!nch, 1/30, fixedLag:true),
        rodPosition=\rodposition.kr(0.3!nch, 1/30, fixedLag:true),
        metalResonance=\metalres.kr(0.7!nch, 1/30, fixedLag:true),
        diffusion=\diffusion.kr(0.6!nch, 1/30, fixedLag:true),
        size=\size.kr(1.0!nch, 1/30, fixedLag:true);
	var chanSig;

    var sig = nch.collect({ |chan|
        var glass, metal, diffuser, friction;
        var nGlassModes = 5;
        var nMetalModes = 8;

        var glassRatios = [1, 2.756, 5.404, 8.933, 13.339];
        var glassDecays = Array.fill(nGlassModes, {|i|
            3 * size[chan] * exp(-0.5 * i);
        });

        var metalRatios = [1, 2.89, 4.95, 6.99, 9.53, 11.97, 14.88, 17.73];
        var metalDecays = Array.fill(nMetalModes, {|i|
            5 * size[chan] * exp(-0.3 * i);
        });

        // Friction excitation
        friction = LPF.ar(
            WhiteNoise.ar(0.1) * rodPressure[chan].linexp(0, 1, 0.02, 0.2),
            freq[chan] * 4
        );

        friction = friction * SinOsc.ar(
            freq: freq[chan] * (1 + LFNoise2.kr(1, 0.001)),
            mul: 0.5,
            add: 0.5
        );

        // Glass resonances
        glass = Mix.fill(nGlassModes, {|i|
            var baseFreq = freq[chan] * glassRatios[i];
            var posAmp = sin(pi * rodPosition[chan] * (i + 1));

            Ringz.ar(
                friction,
                baseFreq,
                glassDecays[i],
                posAmp * exp(-0.5 * i)
            )
        });

        // Metal resonances
        metal = Mix.fill(nMetalModes, {|i|
            var baseFreq = (freq[chan] * 0.5) * metalRatios[i];
            var decay = metalDecays[i] * metalResonance[chan];

            Ringz.ar(
                glass,
                baseFreq * LFNoise2.kr(0.1, 0.001, 1),
                decay,
                exp(-0.7 * i) * 0.5
            )
        });

        // Diffuser per channel
        diffuser = Mix.fill(4, {|i|
            var spreadFreq = freq[chan] * (1 + (i * 0.02 * diffusion[chan]));
            var spreadAmp = exp(-0.5 * i) * diffusion[chan];

            DelayC.ar(
                metal,
                0.05,
                LFNoise2.kr(
                    0.1 + (0.05 * i),
                    0.001,
                    0.002 + (0.001 * i)
                ),
                spreadAmp
            )
        });

        // Mix components
        chanSig = (glass * 0.3) + (metal * 0.4 * metalResonance[chan]) + (diffuser * 0.3);



        // Body resonance
        chanSig = chanSig + BPF.ar(
            chanSig,
            freq[chan] * 0.5,
            0.5,
            0.2
        );

        chanSig * amp[chan]
    });

    Out.ar(out, Limiter.ar(sig, 0.95));
}).writeDefFile(d);
)

(
SynthDef(\cristalBaschetroar, {
    arg out=0, freq=100, amp=0.25,
        // Rod parameters
        rodPressure=0.5,    // wet finger pressure
        rodPosition=0.3,    // playing position on rod
        // Resonator parameters
        metalResonance=0.7, // amount of metal plate resonance
        diffusion=0.6,      // flame diffuser spread
        size=1.0,          // overall size scaling
        roar=0.20,          // amount of nonlinear behavior (0-1)
        gate=1;

    var glass, metal, diffuser, sig;
    var nGlassModes = 5;
    var nMetalModes = 8;

    // Glass rod modes (more pure/harmonic)
    var glassRatios = [1, 2.756, 5.404, 8.933, 13.339];
    var glassDecays = Array.fill(nGlassModes, {|i|
        3 * size * exp(-0.5 * i);
    });

    // Metal resonator modes (more inharmonic)
    var metalRatios = [1, 2.89, 4.95, 6.99, 9.53, 11.97, 14.88, 17.73];
    var metalDecays = Array.fill(nMetalModes, {|i|
        5 * size * exp(-0.3 * i);
    });

    // Enhanced friction excitation with roar-dependent nonlinearity
    var friction = LPF.ar(
        WhiteNoise.ar(0.1) * rodPressure.linexp(0, 1, 0.02, 0.2),
        freq * 4
    );

    // Add characteristic stick-slip behavior
    friction = friction * SinOsc.ar(
        freq: freq * (1 + LFNoise2.kr(1, 0.001)),
        mul: 0.5,
        add: 0.5
    );

    // Add subtle additional excitation components when roaring
    friction = friction + (
        SinOsc.ar(
            freq * [1, 1.5, 2] * LFNoise2.kr(3, 0.01, 1),
            mul: roar * rodPressure * 0.1
        ).sum
    );

    // Glass rod resonances
    glass = Mix.fill(nGlassModes, {|i|
        var baseFreq = freq * glassRatios[i];
        var posAmp = sin(pi * rodPosition * (i + 1));

        Ringz.ar(
            friction,
            baseFreq * (1 + (roar * rodPressure * LFNoise2.kr(0.2, 0.01))),
            glassDecays[i],
            posAmp * exp(-0.5 * i)
        )
    });

    // Add subtle nonlinear behavior to glass when roaring
    glass = glass + (
        (glass * roar * rodPressure * 0.3).clip2(0.5) *
        roar.linexp(0, 1, 0.001, 0.3)
    );

    // Metal resonator plate with feedback for roaring
    metal = Mix.fill(nMetalModes, {|i|
        var baseFreq = (freq * 0.5) * metalRatios[i];
        var decay = metalDecays[i] * metalResonance;
        var feedback = LocalIn.ar(1);

        var resonator = Ringz.ar(
            glass + (feedback * roar * 0.2),
            baseFreq * LFNoise2.kr(0.1, 0.001, 1),
            decay,
            exp(-0.7 * i) * 0.5
        );

        LocalOut.ar(resonator * roar * metalResonance * 0.1);
        resonator
    });

    // Flame-shaped diffuser simulation
    diffuser = Mix.fill(4, {|i|
        var spreadFreq = freq * (1 + (i * 0.02 * diffusion));
        var spreadAmp = exp(-0.5 * i) * diffusion;

        // Multiple delay lines with subtle modulation
        DelayC.ar(
            metal,
            0.05,
            LFNoise2.kr(
                0.1 + (0.05 * i),
                0.001,
                0.002 + (0.001 * i)
            ),
            spreadAmp
        )
    });

    // Mix direct and diffused sound
    sig = (glass * 0.3) + (metal * 0.4 * metalResonance) + (diffuser * 0.3);

    // Add roar-dependent body resonances
    sig = sig + (
        BPF.ar(
            sig,
            freq * [0.5, 0.75, 1.5] * (1 + (roar * LFNoise2.kr(0.2, 0.1))),
            0.5,
            0.2 * roar.linexp(0, 1, 0.001, 1)
        ).sum
    );

    // Overall envelope
    sig = sig * EnvGen.kr(
        envelope: Env.asr(0.1, 1, 3),
        gate: gate,
        doneAction: 2
    );

    // Stereo spreading based on diffusion
    sig = Splay.ar(
        Array.fill(4, {|i|
            DelayC.ar(
                sig,
                0.05,
                LFNoise2.kr(0.05 + (0.01 * i), 0.001, 0.002),
                1/4
            )
        }),
        diffusion * 0.5
    );

    Out.ar(out, Limiter.ar(sig * amp));
}).play;
)

