d = thisProcess.nowExecutingPath.dirname;
(
SynthDef(\brushedcymbal13, {
    arg out=0;
    var nch=13;
    // Continuous control parameters
    var amp=\amp.kr(0.1!nch);
    var locut = \locut.kr(4000!nch);
    var hicut = \hicut.kr(8000!nch);
    var excitation = \excitation.kr(0.2!nch);
    var time = \time.kr(1.20!nch);
    var resolevel = \resolevel.kr(2.0!nch);
    var shimmer = \shimmer.kr(0.90!nch);
    var resonators = \resonum.kr(100!nch);  // Make resonators multichannel
    var trans = \transpose.kr(0!nch);
    var maxResonators = 100;  // Fixed maximum
    var sig = excitation.collect({ |exc, chan|
        var smoothExc = exc.lag(0.05);
        var freqs, lodriver, hidriver, res;
        var activeRes = resonators[chan].clip(0, maxResonators);
        // Generate base frequencies with transpose
        freqs = {exprand(300, 20000)}.dup(maxResonators) + trans[chan];
        // Noise drivers with per-channel cutoffs
        lodriver = LPF.ar(
            WhiteNoise.ar(0.1),
            smoothExc.linexp(0, 1, 200, locut[chan])
        );
        hidriver = HPF.ar(
            WhiteNoise.ar(0.05),
            smoothExc.linexp(0, 1, hicut[chan], 2000)
        );
        // Resonators with variable active count and per-channel shimmer
        res = Ringz.ar(
            (lodriver + hidriver) * smoothExc,
            freqs * Array.fill(maxResonators, { |i|
                1 + (shimmer[chan] * (i/maxResonators - 0.5))
            }),
            time[chan]
        );
        // Sum only active resonators
        res = Mix.fill(maxResonators, { |i|
            res[i] * (i < activeRes).asInteger
        }) * resolevel[chan];
        // Add high frequency emphasis based on shimmer
        res = res + HPF.ar(
            res * shimmer[chan],
            10000
        );
        res * amp * 0.1
    });
    Out.ar(out, sig);
}).writeDefFile(d);
)
// Test basic sound
x = Synth(\brushedcymbal);
// Test different settings per channel
x.set(
    \excitation, [0.3, 0.4],
    \resonum, [50, 80],
    \shimmer, [0.7, 0.9],
    \transpose, [0, 200]
);
// More dramatic stereo
x.set(
    \excitation, [0.5, 0.3],
    \time, [1.8, 1.2],
    \resonum, [30, 90],
    \transpose, [-100, 100]
);