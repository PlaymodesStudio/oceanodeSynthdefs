d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\handpan13, {
    arg out=0;
    var nch=13;
	var chanSig;
    var freq=\pitch.kr(60!nch).midicps,
        amp=\amp.kr(0.5!nch),
        strikePos=\strikepos.kr(0.3!nch),
        strikeCurve=\strikecurve.kr(0.7!nch),
        coupling=\coupling.kr(0.93!nch),
        damping=\damping.kr(0.2!nch),
        stiffness=\stiffness.kr(0.7!nch),
        brightness=\brightness.kr(1.7!nch), //0 to 5
        decayTime=\decaytime.kr(3.4!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var exciter, modes, coupledModes, highModes;
        var nModes = 6;
        var nHighModes = 4;
        var modeRatios = [1, 2.0, 2.83, 3.91, 4.95, 6.12];
        var highRatios = [8.23, 9.87, 11.54, 13.21];
        var trig = gate[chan] > 0;

        var modeDecays = Array.fill(nModes, {|i|
            var baseDecay = decayTime[chan] * (1 - damping[chan]);
            baseDecay * exp(-0.3 * i)
        });

        exciter = Mix([
            EnvGen.ar(
                Env.perc(0.0005, 0.01),
                gate: trig,
                levelScale: 0.5
            ) * Mix([
                BPF.ar(WhiteNoise.ar(0.2), freq[chan] * 2, 0.5),
                HPF.ar(WhiteNoise.ar(0.1), 5000) * brightness[chan]
            ]),

            EnvGen.ar(
                Env.perc(0.001, 0.02),
                gate: trig,
                levelScale: 0.3
            ) * SinOsc.ar(freq[chan])
        ]);

        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * modeRatios[i];
            var inharmonicity = stiffness[chan] * i * 0.005;
            var decayTime = modeDecays[i];
            var posAmp = sin(pi * strikePos[chan] * (i + 1));

            DynKlank.ar(`[
                [
                    baseFreq * (1 + inharmonicity),
                    baseFreq * (1 + (inharmonicity * 1.1))
                ],
                [
                    posAmp * 0.3,
                    posAmp * 0.15
                ],
                [
                    decayTime,
                    decayTime * 0.8
                ]
            ], exciter) * 0.2;
        });

        highModes = Mix.fill(nHighModes, {|i|
            var baseFreq = freq[chan] * highRatios[i];
            var decay = decayTime[chan] * 0.5 * exp(-0.2 * i);
            var posAmp = sin(pi * strikePos[chan] * (i + 7)) * brightness[chan];

            DynKlank.ar(`[
                [baseFreq, baseFreq * 1.001],
                [posAmp * 0.1, posAmp * 0.05],
                [decay * 0.3, decay * 0.2]
            ], exciter) * 0.15;
        });

        coupledModes = Mix.fill(2, {|i|
            var couplingFreq = freq[chan] * [1.5, 2][i];
            var couplingAmp = coupling[chan] * 0.1 * (1 - (i * 0.3));

            DynKlank.ar(`[
                [couplingFreq],
                [couplingAmp],
                [modeDecays[0] * 0.3]
            ], modes);
        });

         chanSig = Mix([
            modes,
            highModes * brightness[chan],
            coupledModes * coupling[chan] * 0.3
        ]);

        chanSig = chanSig + (chanSig.abs * chanSig * 0.02);

        chanSig = BPeakEQ.ar(
            chanSig,
            freq[chan] * 2.5,
            0.7,
            2
        );

        chanSig = BHiShelf.ar(
            chanSig,
            5000,
            1,
            brightness[chan] * 6
        );

        chanSig = chanSig * EnvGen.ar(
            Env.new(
                levels: [0, 1, 0],
                times: [0.001, decayTime[chan]],
                curve: [-4, -4]
            ),
            gate: trig
        );

        chanSig = FreeVerb.ar(chanSig, 0.15, 0.6, 0.1);

        chanSig * amp[chan]
    });

	Out.ar(out, Sanitize.ar(Limiter.ar(sig, 0.95)));

}).writeDefFile(d);
)

// Create synth
x = Synth(\handpan13);

// Trigger specific channels
x.set(\gate, [1,0,1,0,1,0,1,0,1,0,1,0,1]);
