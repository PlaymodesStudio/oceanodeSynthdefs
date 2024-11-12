// 13-Channel Marimba Modal Synthesis Implementation
// euler-bernoulli beam equations

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\marimba13, {
    arg out = 0;
    var freq = \pitch.kr(78!13).midicps,
        amp = \amp.kr(1!13),
        att = \att.kr(0.001!13),
        dec = \dec.kr(0.01!13),
        rel = \rel.kr(0.395!13),
        decCoef = \deccoef.kr(0.84!13),
        position = \position.kr(0.414!13),
        ampSlope = \ampslope.kr(3!13);

    var mallet, snd;
    var trig = Trig1.kr(\trigger.kr(0!13), 0.001);

    // Modal resonator bank for each channel
    snd = 13.collect({ arg chan;
        var freqs, amps, decs;

        // Calculate frequency ratios
        freqs = Array.fill(30, { arg i;
            var ratio = if(i <= 1) {
                Select.kr(i, [1.50561873, 2.49975267])
            } {
                i + 1.5
            } / 1.50561873;
            ratio * freq[chan];
        });

        // Calculate amplitudes
        amps = Array.fill(30, { arg i;
            var thisFreq = freqs[i];
            Select.kr(
                thisFreq <= 20000,
                [
                    0,
                    sin(((i + 1) * pi) * position[chan]) *
                    (ampSlope[chan] * (thisFreq/freq[chan]).log2).dbamp
                ]
            );
        });

        // Calculate decay times
        decs = Array.fill(30, { arg i;
            exp(-1 * i * decCoef[chan]) * rel[chan]
        });

        // Excitation signal for this channel
        mallet = Decay2.ar(
            in: K2A.ar(trig[chan]),
            attackTime: att[chan],
            decayTime: dec[chan],
            mul: 0.1
        );

        // Use DynKlank for dynamic resonator bank
        DynKlank.ar(
            specificationsArrayRef: Ref.new([
                freqs,    // frequencies are now at audio rate
                amps,     // amplitudes can be modulated
                decs     // decay times can be changed
            ]),
            input: mallet
        )
    });

    // Output processing
    snd = snd * amp;
    snd = Limiter.ar(snd);
    Out.ar(out, snd);
}).writeDefFile(d);
)