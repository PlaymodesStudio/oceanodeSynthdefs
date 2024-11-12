// Glass/Crystal material - characterized by very harmonic modes and long, clean decay
d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\glass13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(60!nch).midicps,
        amp=\amp.kr(0.5!nch),
        pos=\pos.kr(0.3!nch),
        size=\size.kr(1.0!nch),
        damping=\damping.kr(0.5!nch),
        gate=\gate.kr(0!nch);

    var sig = nch.collect({ |chan|
        var exciter, modes;
        var nModes = 6;
        var modeRatios = [1, 2.32, 4.25, 6.63, 9.38, 12.22];
        var baseDecay = 3.0 * size[chan] * (1 - damping[chan]);

        // Filtered noise burst for strike
        exciter = EnvGen.ar(
            Env.perc(0.0001, 0.001),
            gate: gate[chan]
        ) * HPF.ar(WhiteNoise.ar, 3000);

        // Modal synthesis
        modes = Mix.fill(nModes, {|i|
            var decay = baseDecay * exp(-0.5 * i);
            var modalAmp = exp(-0.5 * i) * sin(pi * pos[chan] * (i + 1));

            Ringz.ar(
                exciter,
                freq[chan] * modeRatios[i],
                decay,
                modalAmp
            )
        });

        // Envelope and output
        modes * amp[chan] * EnvGen.kr(
            Env.perc(0.001, baseDecay),
            gate: gate[chan],
            doneAction: 0
        )
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\bowedcrystal13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(60!nch, 1/30, fixedLag:true).midicps,
        amp=\amp.kr(0.83!nch, 1/30, fixedLag:true),
        bowPressure=\bowpressure.kr(0.5!nch, 1/30, fixedLag:true),
        bowPosition=\bowposition.kr(0.2!nch, 1/30, fixedLag:true),
        size=\size.kr(1.0!nch, 1/30, fixedLag:true),
        damping=\damping.kr(0.3!nch, 1/30, fixedLag:true),
        movement=\movement.kr(1!nch, 1/30, fixedLag:true);

    var sig = nch.collect({ |chan|
        var modes, bow;
        var nModes = 6;
        var modeRatios = [1, 2.32, 4.25, 6.63, 9.38, 12.22];

        // Bow excitation per channel
        bow = LPF.ar(
            WhiteNoise.ar(0.1) * bowPressure[chan].linexp(0, 1, 0.02, 0.1),
            freq[chan] * 2
        );

        // Frequency movement per channel
        bow = bow * SinOsc.ar(
            freq: freq[chan] * (1 + LFNoise2.kr(1, 0.001)),
            mul: 0.5,
            add: 0.5
        ) * movement[chan];



        // Modal resonator bank per channel
        modes = Mix.fill(nModes, {|i|
            var baseFreq = freq[chan] * modeRatios[i];
            var decayTime = size[chan] * (2.0 - (i * 0.1)) * (1 - damping[chan]);
            var posAmp = sin(pi * bowPosition[chan] * (i + 1));

            Ringz.ar(
                bow,
                baseFreq,
                decayTime,
                posAmp * (1.0 - (i * 0.1))
            )
        });



        // Shimmer per channel
        modes = modes + DelayC.ar(
            modes,
            0.02,
            LFNoise2.kr(0.1).range(0.01, 0.02)
        ) * 0.1;

        // Final channel output
        modes * amp[chan]
    });

    Out.ar(out, Limiter.ar(sig, 0.95));
}).writeDefFile(d);
)

// Metal plate - dense, inharmonic modes with bright resonance
(
SynthDef(\metalPlate, {
    arg out=0, freq=200, amp=0.5, pos=0.5, size=1.0, brightness=0.5;
    var exciter, modes, sig;
    var nModes = 12;
    // Inharmonic series based on plate physics
    var modeRatios = Array.fill(nModes, {|i|
        var n = i + 1;
        sqrt((n * pi).squared * (1 + 0.3 * (n * pi).squared))
    });

    exciter = EnvGen.ar(Env.perc(0.0001, 0.002)) *
        HPF.ar(WhiteNoise.ar * Impulse.ar(0), 2000);

    modes = Mix.fill(nModes, {|i|
        var decay = (0.05 + (size * 0.1)) * exp(-0.5 * i * (1 - brightness));
        var amp = exp(-0.7 * i) * sin(pi * pos * (i + 1));
        Ringz.ar(exciter, freq * modeRatios[i], decay, amp)
    });

    sig = modes * amp * EnvGen.kr(Env.perc(0.001, 0.1 + (size * 0.2)), doneAction: 2);
    Out.ar(out, sig!2);
}).play;
)

// Ceramic material - sharp attack, medium decay, mixed harmonicity
(
SynthDef(\ceramic, {
    arg out=0, freq=1000, amp=0.5, pos=0.5, hardness=0.997;
    var exciter, modes, sig;
    var nModes = 8;
    // Mix of harmonic and inharmonic modes
    var modeRatios = [1, 2.1, 3.93, 4.94, 6.49, 8.18, 9.64, 11.05];

    exciter = EnvGen.ar(Env.perc(0.0001, 0.001)) *
        (Impulse.ar(0) + (WhiteNoise.ar * 0.5 * (1-hardness)));

    modes = Mix.fill(nModes, {|i|
        var decay = 0.2 * exp(-0.3 * i);
        var amp = exp(-0.6 * i) * sin(pi * pos * (i + 1));
        Ringz.ar(exciter, freq * modeRatios[i], decay, amp)
    });

    sig = modes * amp * EnvGen.kr(Env.perc(0.001, 0.3), doneAction: 2);
    Out.ar(out, sig!2);
}).play;
)

// Stone/Granite - dense, very inharmonic with quick decay
(
SynthDef(\stone, {
    arg out=0, freq=800, amp=0.5, density=0.7, roughness=0.5;
    var exciter, modes, sig;
    var nModes = 10;
    // Very inharmonic series
    var modeRatios = Array.fill(nModes, {|i|
        var n = i + 1;
        n * (1 + (roughness * 0.1 * i))
    });

    exciter = EnvGen.ar(Env.perc(0.0001, 0.005)) *
        LPF.ar(WhiteNoise.ar, 8000) * Impulse.ar(0);

    modes = Mix.fill(nModes, {|i|
        var decay = 0.05 * exp(-0.8 * i * density);
        var amp = exp(-0.9 * i);
        Ringz.ar(exciter, freq * modeRatios[i], decay, amp)
    });

    sig = modes * amp * EnvGen.kr(Env.perc(0.001, 0.1), doneAction: 2);
    Out.ar(out, sig!2);
}).play;
)

// Plastic - fewer modes, less pure resonances
(
SynthDef(\plastic, {
    arg out=0, freq=800, amp=0.5, thickness=0.5, hardness=0.7;
    var exciter, modes, sig;
    var nModes = 5;
    // Slightly inharmonic modes
    var modeRatios = [1, 2.1, 3.8, 5.2, 6.9];

    exciter = EnvGen.ar(Env.perc(0.0001, 0.002)) *
        (Impulse.ar(0) + (PinkNoise.ar * 0.3 * (1-hardness)));

    modes = Mix.fill(nModes, {|i|
        var decay = 0.1 * exp(-1.0 * i) * thickness;
        var amp = exp(-0.8 * i);
        Ringz.ar(exciter, freq * modeRatios[i], decay, amp)
    });

    sig = LPF.ar(
        modes * amp * EnvGen.kr(Env.perc(0.001, 0.15), doneAction: 2),
        freq * 8
    );
    Out.ar(out, sig!2);
}).play;
)