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

    var freqarray, amparray, decarray, mallet, snd;
    // Detect rising edge of trigger signal
    var trig = Trig1.kr(\trigger.kr(1!13), 0.001);

    // Generate arrays for each channel
    freqarray = 13.collect({ arg chan;
        Array.fill(30, { arg i;
            if(i <= 1) {
                [1.50561873, 2.49975267][i]
            } {
                i + 1.5
            }
        }) / 1.50561873 // Normalize to fundamental
    });

    // Amplitude array with position-dependent excitation for each channel
    amparray = 13.collect({ arg chan;
        Array.fill(30, { arg i;
            var fundamental = freq[chan];
            var thisFreq = freqarray[chan][i] * fundamental;
            var freqTest = BinaryOpUGen.new('<=', thisFreq, 20000);
            Select.kr(freqTest, [
                0,
                sin(((i + 1) * pi) * position[chan]) *
                (ampSlope[chan] * (thisFreq/fundamental).log2).dbamp
            ])
        });
    });

    // Exponential decay times array for each channel
    decarray = 13.collect({ arg chan;
        Array.fill(30, { arg i;
            exp(-1 * i * decCoef[chan])
        });
    });

    // Excitation signal per channel
    mallet = Decay2.ar(
        in: K2A.ar(trig), // Convert control rate trigger to audio rate
        attackTime: att,
        decayTime: dec,
        mul: 0.1
    );

    // Modal resonator bank for each channel
    snd = 13.collect({ arg chan;
        Klank.ar(
            specificationsArrayRef: Ref.new([
                freqarray[chan],
                amparray[chan],
                decarray[chan]
            ]),
            input: mallet[chan],
            freqscale: freq[chan],
            decayscale: rel[chan]
        )
    });

    // Output processing
    snd = snd * amp;
    snd = Limiter.ar(snd);
    Out.ar(out, snd);
}).writeDefFile(d);
)