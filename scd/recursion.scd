// where did I leave my keys?
(
var n = 30, m = 5;
Ndef.clear(3);
Ndef.ar(\x, n);
Ndef(\y, { Splay.ar(Ndef.ar(\x, m, LFNoise1.kr(1/m).range(0, n - m - 1))).clip2 * 0.5 }).play;
Ndef(\x, {
	{
		var a = Ndef.ar(\x, 1, LFNoise0.kr(Rand()) * Rand() + Rand() * n);
		a + 0.1 * SinOsc.ar(ExpRand(0.2, 1000))
	} ! n
});
)

// where did I put my keys?
(
var n = 30, m = 5;
Ndef.clear(3);
Ndef.ar(\x, n);
Ndef(\y, { Splay.ar(Ndef.ar(\x, m, LFNoise1.kr(1/m).range(0, n - m - 1))).clip2 * 0.5 }).play;
Ndef(\x, {
	{
		var a = Ndef.ar(\x, 1, LFNoise0.kr(Rand()) * Rand() + Rand() * n);
		SinOsc.ar(ExpRand(0.2, 1000), a)
	} ! n
});
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\recursive2, {
    arg out=0;
    var amp = \amp.kr(0.5, 0.01);     // Overall amplitude (0.0 to 1.0)
    var spread = \spread.kr(1.0, 0.1); // Stereo spread (0.0 to 1.0) - higher spreads signals wider

    // Oscillator parameters
    var n = 30;  // number of oscillators
    var m = 5;   // number of output taps

    // Time-based controls
    var noiseRateLo = \noiselo.kr(0.1, 0.01);  // Slowest noise rate (0.01 to 5.0) - lower = smoother changes
    var noiseRateHi = \noisehi.kr(2.0, 0.01);  // Fastest noise rate (0.01 to 10.0) - higher = more chaotic
    var lagTime = \lag.kr(0.1, 0.01);          // Smoothing amount (0.01 to 1.0) - higher = smoother transitions

    // Frequency range controls
    var freqLo = \freqlo.kr(0.2, 0.01);    // Lowest possible frequency (0.1 to 20.0)
    var freqHi = \freqhi.kr(1000, 1);      // Highest possible frequency (20 to 2000)
    var freqMul = \freqmul.kr(1, 0.01);    // Frequency multiplier (0.1 to 10.0) - scales the entire range

    // Feedback controls
    var fbScale = \fbscale.kr(1.0, 0.01);   // Feedback intensity (0.0 to 2.0) - higher = more extreme modulation
    var fbOffset = \fboffset.kr(0.0, 0.01);  // Feedback offset (-1.0 to 1.0) - shifts the feedback phase

    // Protection/smoothing controls
    var leakDC = 0.995;    // DC leak coefficient (0.9 to 0.999) - higher removes more DC
    var lowpass = \lowpass.kr(20000, 1);       // Lowpass filter freq (100 to 20000) - lower removes more clicks
    var limiterLevel = 0.95;  // Limiter ceiling (0.5 to 1.0) - lower = more headroom

    var sig, output, limited;
    var fb;

    // Create initial feedback with DC filtering
    fb = LeakDC.ar(LocalIn.ar(n), leakDC);

    // Create n oscillators with smoothed selection
    sig = n.collect({
        var noiseRate = ExpRand(noiseRateLo, noiseRateHi);
        var randMul = Rand(0.0, 1.0);
        var randOffset = Rand(0.0, n);
        var index = (LFNoise0.kr(noiseRate) * randMul + randOffset).clip(0, n-1);
        var smoothIndex = Lag3.kr(index, lagTime);  // Smoother lag
        var a = (SelectX.ar(smoothIndex, fb) * fbScale + fbOffset);

        // Smooth the phase modulation
        var smoothPhase = Lag.ar(a, 0.001);
        var osc = SinOsc.ar(ExpRand(freqLo, freqHi) * freqMul, smoothPhase);

        // Filter each oscillator
        LPF.ar(osc, lowpass)
    });

    // Feed filtered signals back
    LocalOut.ar(LeakDC.ar(sig, leakDC));

    // Final output stage with smoothed selection
    output = m.collect({
        var readPos = LFNoise1.kr(1/m).range(0, n - m - 1);
        var smoothPos = Lag3.kr(readPos, lagTime * 2);  // Smoother lag
        var audioPos = K2A.ar(smoothPos);
        SelectX.ar(audioPos, sig)
    });

    // Final processing chain
    limited = output
        .collect({ |chan| LeakDC.ar(chan, leakDC) })  // Remove DC
        .collect({ |chan| LPF.ar(chan, lowpass) })    // Filter clicks
        .collect({ |chan| Limiter.ar(chan, limiterLevel, 0.01) });  // Soft limit

    Out.ar(out, Splay.ar(limited, spread) * amp);
}).writeDefFile(d);
)

 Example usage with different characters:
// Smooth and clean
x = Synth(\recursiveOsc, [
    \noiseLo, 0.02,
    \noiseHi, 0.5,
    \lag, 0.3,
    \freqLo, 0.1,
    \freqHi, 400,
    \fbScale, 0.7,
    \leakDC, 0.995,
    \lowpass, 8000,
    \limit, 0.9
]);

// Fast but controlled
x = Synth(\recursiveOsc, [
    \noiseLo, 1.0,
    \noiseHi, 8.0,
    \lag, 0.05,
    \freqLo, 1.0,
    \freqHi, 2000,
    \fbScale, 1.5,
    \leakDC, 0.998,
    \lowpass, 10000,
    \limit, 0.85
]);

// Subtle and warm
x = Synth(\recursiveOsc, [
    \noiseLo, 0.1,
    \noiseHi, 1.0,
    \lag, 0.2,
    \freqLo, 20,
    \freqHi, 800,
    \fbScale, 0.5,
    \fbOffset, 0.2,
    \leakDC, 0.99,
    \lowpass, 6000,
    \limit, 0.95
]);

(
SynthDef(\recursive2, {
    // Main mix controls
    var amp = \amp.kr(0.5, 0.01);     // Overall amplitude (0.0 to 1.0)
    var spread = \spread.kr(1.0, 0.1); // Stereo spread (0.0 to 1.0) - higher spreads signals wider

    // Oscillator parameters
    var n = 30;  // number of oscillators
    var m = 5;   // number of output taps

    // Time-based controls
    var noiseRateLo = \noiselo.kr(0.1, 0.01);  // Slowest noise rate (0.01 to 5.0) - lower = smoother changes
    var noiseRateHi = \noisehi.kr(2.0, 0.01);  // Fastest noise rate (0.01 to 10.0) - higher = more chaotic
    var lagTime = \lag.kr(0.1, 0.01);          // Smoothing amount (0.01 to 1.0) - higher = smoother transitions

    // Frequency range controls
    var freqLo = \freqlo.kr(0.2, 0.01);    // Lowest possible frequency (0.1 to 20.0)
    var freqHi = \freqhi.kr(1000, 1);      // Highest possible frequency (20 to 2000)
    var freqMul = \freqmul.kr(1, 0.01);    // Frequency multiplier (0.1 to 10.0) - scales the entire range

    // Feedback controls
    var fbScale = \fbscale.kr(1.0, 0.01);   // Feedback intensity (0.0 to 2.0) - higher = more extreme modulation
    var fbOffset = \fboffset.kr(0.0, 0.01);  // Feedback offset (-1.0 to 1.0) - shifts the feedback phase

    // Protection/smoothing controls
    var leakDC = 0.995;    // DC leak coefficient (0.9 to 0.999) - higher removes more DC
    var lowpass = \lowpass.kr(12000, 1);       // Lowpass filter freq (100 to 20000) - lower removes more clicks
    var limiterLevel = 0.95;  // Limiter ceiling (0.5 to 1.0) - lower = more headroom

    var sig, output, limited;
    var fb;

    // Create initial feedback with DC filtering
    fb = LeakDC.ar(LocalIn.ar(n), leakDC);

    // Create n oscillators with smoothed selection
    sig = n.collect({
        var noiseRate = ExpRand(noiseRateLo, noiseRateHi);
        var randMul = Rand(0.0, 1.0);
        var randOffset = Rand(0.0, n);
        var index = (LFNoise0.kr(noiseRate) * randMul + randOffset).clip(0, n-1);
        var smoothIndex = Lag3.kr(index, lagTime);  // Smoother lag
        var a = (SelectX.ar(smoothIndex, fb) * fbScale + fbOffset);

        // Smooth the phase modulation
        var smoothPhase = Lag.ar(a, 0.001);
        var osc = SinOsc.ar(ExpRand(freqLo, freqHi) * freqMul, smoothPhase);

        // Filter each oscillator
        LPF.ar(osc, lowpass)
    });

    // Feed filtered signals back
    LocalOut.ar(LeakDC.ar(sig, leakDC));

    // Final output stage with smoothed selection
    output = m.collect({
        var readPos = LFNoise1.kr(1/m).range(0, n - m - 1);
        var smoothPos = Lag3.kr(readPos, lagTime * 2);  // Smoother lag
        var audioPos = K2A.ar(smoothPos);
        SelectX.ar(audioPos, sig)
    });

    // Final processing chain
    limited = output
        .collect({ |chan| LeakDC.ar(chan, leakDC) })  // Remove DC
        .collect({ |chan| LPF.ar(chan, lowpass) })    // Filter clicks
        .collect({ |chan| Limiter.ar(chan, limiterLevel, 0.01) });  // Soft limit

    Out.ar(0, Splay.ar(limited, spread) * amp);
}).writeDefFile(d);
)


(
SynthDef(\recursive2, {
    arg out=0;
    var amp = \amp.kr(0.5, 0.01);
    var spread = \spread.kr(1.0, 0.1);

    // Oscillator parameters
    var n = 30;
    var m = 5;

    // Time-based controls
    var noiseRateLo = \noiselo.kr(0.1, 0.01);
    var noiseRateHi = \noisehi.kr(2.0, 0.01);
    var lagTime = \lag.kr(0.1, 0.01);

    // Frequency range controls
    var freqLo = \freqlo.kr(0.2, 0.01);
    var freqHi = \freqhi.kr(1000, 1);
    var freqMul = \freqmul.kr(1, 0.01);

    // Auto-trigger when any range parameter changes
    var trig = Changed.kr(noiseRateLo) + Changed.kr(noiseRateHi) +
               Changed.kr(freqLo) + Changed.kr(freqHi);

    // Feedback controls
    var fbScale = \fbscale.kr(1.0, 0.01);
    var fbOffset = \fboffset.kr(0.0, 0.01);

    // Protection/smoothing controls
    var leakDC = 0.995;
    var lowpass = \lowpass.kr(12000, 1);
    var limiterLevel = 0.95;

    var sig, output, limited;
    var fb;

    // Create initial feedback with DC filtering
    fb = LeakDC.ar(LocalIn.ar(n), leakDC);

    // Create n oscillators with smoothed selection
    sig = n.collect({
        // Use parameter changes to trigger new random values
        var noiseRate = TExpRand.kr(noiseRateLo, noiseRateHi, trig);
        var randMul = TRand.kr(0.0, 1.0, trig);
        var randOffset = TRand.kr(0.0, n, trig);
        var freq = TExpRand.kr(freqLo, freqHi, trig);

        var index = (LFNoise0.kr(noiseRate) * randMul + randOffset).clip(0, n-1);
        var smoothIndex = Lag3.kr(index, lagTime);
        var a = (SelectX.ar(smoothIndex, fb) * fbScale + fbOffset);

        var smoothPhase = Lag.ar(a, 0.001);
        var osc = SinOsc.ar(freq * freqMul, smoothPhase);

        LPF.ar(osc, lowpass)
    });

    // Feed filtered signals back
    LocalOut.ar(LeakDC.ar(sig, leakDC));

    // Final output stage with smoothed selection
    output = m.collect({
        var readPos = LFNoise1.kr(1/m).range(0, n - m - 1);
        var smoothPos = Lag3.kr(readPos, lagTime * 2);
        var audioPos = K2A.ar(smoothPos);
        SelectX.ar(audioPos, sig)
    });

    // Final processing chain
    limited = output
        .collect({ |chan| LeakDC.ar(chan, leakDC) })
        .collect({ |chan| LPF.ar(chan, lowpass) })
        .collect({ |chan| Limiter.ar(chan, limiterLevel, 0.01) });

    Out.ar(out, Splay.ar(limited, spread) * amp);
}).writeDefFile(d);
)


(
SynthDef(\recursive13, {
    arg out=0;
    var nch = 13;
    var amp = \amp.kr(0.5!nch, 0.01);

    // Oscillator parameters - multiply by 6 for 13 channel spread
	var n = (30 * (nch/2)).floor.asInteger;  // original 30 * 6
	var m = (5 * (nch/2)).floor.asInteger;   // original 5 * 6

    // Time-based controls (single value to preserve recursive structure)
    var noiseRateLo = \noiselo.kr(0.1, 0.01);
    var noiseRateHi = \noisehi.kr(2.0, 0.01);
    var lagTime = \lag.kr(0.1, 0.01);

    // Frequency range controls (single value)
    var freqLo = \freqlo.kr(0.2, 0.01);
    var freqHi = \freqhi.kr(1000, 1);
    var freqMul = \freqmul.kr(1, 0.01);

    // Feedback controls (single value)
    var fbScale = \fbscale.kr(1.0, 0.01);
    var fbOffset = \fboffset.kr(0.0, 0.01);

    // Protection/smoothing controls
    var leakDC = 0.995;
    var lowpass = \lowpass.kr(12000!nch, 1);  // 13 channel
    var limiterLevel = 0.95;

    var sig, output, limited;
    var fb,trig;

    // Create initial feedback with DC filtering
    fb = LeakDC.ar(LocalIn.ar(n), leakDC);

    // Auto-trigger when any range parameter changes
     trig = Changed.kr(noiseRateLo) + Changed.kr(noiseRateHi) +
               Changed.kr(freqLo) + Changed.kr(freqHi);

    // Create n oscillators with smoothed selection
    sig = n.collect({
        var noiseRate = TExpRand.kr(noiseRateLo, noiseRateHi, trig);
        var randMul = TRand.kr(0.0, 1.0, trig);
        var randOffset = TRand.kr(0.0, n, trig);
        var freq = TExpRand.kr(freqLo, freqHi, trig);
        var index = (LFNoise0.kr(noiseRate) * randMul + randOffset).clip(0, n-1);
        var smoothIndex = Lag3.kr(index, lagTime);
        var a = (SelectX.ar(smoothIndex, fb) * fbScale + fbOffset);
        var smoothPhase = Lag.ar(a, 0.001);
        var osc = SinOsc.ar(freq * freqMul, smoothPhase);
        LPF.ar(osc, lowpass[0])  // Use first lowpass value for initial filtering
    });

    // Feed filtered signals back
    LocalOut.ar(LeakDC.ar(sig, leakDC));

    // Final output stage with smoothed selection
    output = m.collect({
        var readPos = LFNoise1.kr(1/m).range(0, n - m - 1);
        var smoothPos = Lag3.kr(readPos, lagTime * 2);
        var audioPos = K2A.ar(smoothPos);
        SelectX.ar(audioPos, sig)
    });

    // Mix and distribute across 13 channels using SelectX
    limited = nch.collect({ |i|
        var pos = i * (m/nch);  // Calculate position in output array
        var selector = pos + LFNoise1.kr(0.1).range(0, m/nch);  // Add some movement
        var chan = SelectX.ar(selector, output);
        var processed = LeakDC.ar(chan, leakDC);
        processed = LPF.ar(processed, lowpass[i]);
        processed = Limiter.ar(processed, limiterLevel, 0.01);
        processed * amp[i]
    });

    Out.ar(out, limited);
}).writeDefFile(d);
)