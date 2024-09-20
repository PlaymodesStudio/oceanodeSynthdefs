(
SynthDef(\metalplate, {
    arg out = 0;
    var t_gate, freq, amp, rel, pan, crv, ratio, decCoef, xpos, ypos, thumpDec;
    var exciter, freqArray, ampArray, decArray, snd, env;

    // Named controls
    t_gate = \gate.kr(1);
    freq = \pitch.kr(60).midicps;
    amp = \amp.kr(0.5);
    rel = \rel.kr(2);
    crv = \crv.kr(0);
    ratio = \ratio.kr(1);
    decCoef = \deccoef.kr(0.31);
    xpos = \xpos.kr(0.5);
    ypos = \ypos.kr(0.5);
    thumpDec = \thumpdec.kr(0.75);

    // Envelope for gating
    env = EnvGen.kr(Env.asr(0.01, 1, rel, crv), gate: t_gate);

    // Frequencies
    freqArray = Array.fill2D(16, 16, {
        arg i, j;
        (i + 1).pow(2) + (ratio * (j + 1)).pow(2)
    });
    freqArray = freqArray/(freqArray[0][1]);
    freqArray = freqArray * freq;

    // Amplitudes
    ampArray = Array.fill2D(16, 16, {
        arg i, j;
        ((1 - ((freqArray[i][j] - 19000)/1000).tanh)/2) *
        sin(((i + 1) * pi) * xpos) *
        sin(((j + 1) * pi) * ypos)
    });

    // Decay Times
    decArray = Array.fill2D(16, 16, {
        arg i, j;
        (
            if (j == 0)
                { thumpDec }
                { 1 }
        ) *
        exp(-1 * (i + j) * decCoef)
    });

    // Hit the plate (now retriggerable)
    exciter = T2A.ar(t_gate);

    // The Plate
    snd = DynKlank.ar(
        specificationsArrayRef:
            Ref.new([freqArray.flatten, ampArray.flatten, decArray.flatten]),
        input: exciter,
        freqscale: 1,
        decayscale: rel
    );

    snd = Mix.ar(snd/7) * amp * env;
    snd = Limiter.ar(snd);

    Out.ar(out, snd!2);
}).add;
)

// Example usage:
x = Synth(\metalplate);

// Trigger the plate sound
x.set(\gate, 1);

// Change parameters and trigger again
x.set(\pitch, 84);
x.set(\rel, 10);

// Release the sound
x.set(\gate, 0);