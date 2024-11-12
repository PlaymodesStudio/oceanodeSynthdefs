d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\gamelan13, {
    arg out=0;
    var nch=13;
	var chanSig;
    var freq=\pitch.kr(60!nch).midicps,
        amp=\amp.kr(0.95!nch),
        thickness=\thickness.kr(0.7!nch),
        damping=\damping.kr(0.3!nch),
        brightness=\brightness.kr(0.6!nch),
        mallet=\mallet.kr(0.5!nch),
        strikePos=\strikePos.kr(0.3!nch),
        detune=\detune.kr(4.0!nch),
        pairBalance=\pairbalance.kr(0.95!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var exciter, modes, pair;
        var nModes = 12;

        var modeRatios = [1, 3.37, 6.75, 10.53, 14.96, 19.97, 25.61, 31.84, 38.69, 46.15, 54.23, 62.94];
        var adjustedRatios = modeRatios * (1 + (thickness[chan] * [0, 0.01, 0.02, 0.035, 0.05, 0.07, 0.09, 0.11, 0.13, 0.15, 0.17, 0.19]));

        var modeDecays = Array.fill(nModes, {|i|
            exp(-0.5 * i) * (1 - damping[chan]) * 3
        });

        var modeAmps = Array.fill(nModes, {|i|
            var posAmp = sin(pi * strikePos[chan] * (i + 1));
            posAmp * exp(-1 * i * (1 - brightness[chan]))
        });

        exciter = EnvGen.ar(
            Env.perc(0.0001, 0.01),
            levelScale: amp[chan],
            gate: gate[chan]
        ) * Mix([
            Impulse.ar(0) * mallet[chan],
            HPF.ar(PinkNoise.ar, 500) * (1 - mallet[chan]) * 0.5
        ]);

        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * adjustedRatios[i];
            var partialAmp = modeAmps[i];

            DynKlank.ar(`[
                [baseFreq],
                [partialAmp],
                [modeDecays[i]]
            ], exciter) * (1/nModes)
        });

        pair = Mix.fill(nModes, {|i|
            var baseFreq = (freq[chan] + detune[chan]) * adjustedRatios[i];
            var partialAmp = modeAmps[i];

            DynKlank.ar(`[
                [baseFreq],
                [partialAmp],
                [modeDecays[i]]
            ], exciter) * (1/nModes)
        });

        chanSig = (modes * (1 - (pairBalance[chan] * 0.5))) + (pair * (pairBalance[chan] * 0.5));

        chanSig = chanSig + (chanSig.abs * chanSig * EnvGen.kr(Env.perc(0.0001, 0.01)) * 0.1);

        chanSig = chanSig + BPF.ar(
            chanSig,
            [freq[chan] * 0.5, freq[chan] * 0.75],
            0.1,
            0.1
        ).sum;

        Limiter.ar(chanSig * 2, 0.9)
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\gongageng13, {
    arg out=0;
	var chanSig;
    var nch=13;
    var freq=\pitch.kr(55!nch).midicps,
        amp=\amp.kr(0.5!nch),
        thickness=\thickness.kr(0.8!nch),
        damping=\damping.kr(0.2!nch),
        brightness=\brightness.kr(0.7!nch),
        mallet=\mallet.kr(0.3!nch),
        strikePos=\strikePos.kr(0.4!nch),
        shimmerSpeed=\shimmerspeed.kr(3!nch),
        shimmerDepth=\shimmerdepth.kr(0.3!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var exciter, modes;
        var nModes = 15;

        var modeRatios = [1, 2.1, 3.79, 5.13, 6.75, 8.21, 10.05, 11.98, 13.65, 15.71, 17.89, 20.15, 22.67, 25.34, 28.19];
        var adjustedRatios = modeRatios * (1 + (thickness[chan] * Array.series(nModes, 0, 0.02)));

        var modeDecays = Array.fill(nModes, {|i|
            (exp(-0.3 * i) * (1 - damping[chan]) * 8).clip(0.5, 10)
        });

        var modeAmps = Array.fill(nModes, {|i|
            var posAmp = sin(pi * strikePos[chan] * (i + 1));
            var shimmer = SinOsc.kr(
                shimmerSpeed[chan] * (i + 1) * 0.1,
                0,
                shimmerDepth[chan] * i/nModes
            ).range(1-shimmerDepth[chan], 1);
            posAmp * exp(-0.7 * i * (1 - brightness[chan])) * shimmer
        });

        exciter = EnvGen.ar(
            Env.perc(0.005, 0.1),
            levelScale: amp[chan],
            gate: gate[chan]
        ) * Mix([
            Impulse.ar(0) * mallet[chan] * 0.7,
            HPF.ar(PinkNoise.ar, 200) * (1 - mallet[chan])
        ]);

        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * adjustedRatios[i];
            var partialAmp = modeAmps[i];

            DynKlank.ar(`[
                [baseFreq],
                [partialAmp],
                [modeDecays[i]]
            ], exciter) * (1/nModes)
        });

        chanSig = modes * EnvGen.kr(
            Env([0, 1, 0.7, 0], [0.002, 0.2, 7], [-2, -1, -4]),
            gate: gate[chan]
        );

        chanSig = chanSig + Mix([
            BPF.ar(chanSig, freq[chan] * [0.5, 0.75, 1.5], 0.1, [0.1, 0.07, 0.05])
        ]);

        chanSig * amp[chan]
    });

    Out.ar(out, Limiter.ar(sig, 0.95));
}).writeDefFile(d);
)