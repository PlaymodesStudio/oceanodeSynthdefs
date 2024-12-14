(
SynthDef(\additivecomb, {
    arg out=0;
    var numPartials = 256;
    var freq, inharmonicity, warpSpectrum, combOffset, combDensity, combPeak, combSkew;
    var ratios, freqs, amps, normalizedFreqs, warpedFreqs, phase, warpedPhase, sig;
    var modFreqs, modPhases, lfos;
    var nyquist, fade, limiter;

    // Base parameters
    freq = \pitch.kr(36, 1/30, fixedLag:true).midicps;
    inharmonicity = \inharmonicity.kr(0, 1/30, fixedLag:true);
    warpSpectrum = \warpspec.kr(0.5, 1/30, fixedLag:true);
    combOffset = \comboffset.kr(0, 1/30, fixedLag:true);
    combDensity = \combdensity.kr(0, 1/30, fixedLag:true);
    combPeak = \combpeak.kr(5, 1/30, fixedLag:true);
    combSkew = \combskew.kr(0.5, 1/30, fixedLag:true);

    // Generate harmonic series
    ratios = (1..numPartials);
    freqs = freq * ratios * (1 + (inharmonicity * ratios * ratios)).sqrt;

    // Frequency warping
    normalizedFreqs = (freqs / freqs[numPartials - 1]).clip(0, 1);
    warpedFreqs = Select.kr(
        normalizedFreqs > (1 - warpSpectrum),
        [
            0.5 * normalizedFreqs / (1 - warpSpectrum),
            0.5 * (1 + ((normalizedFreqs - (1 - warpSpectrum)) / warpSpectrum))
        ]
    );
    freqs = warpedFreqs * freqs[numPartials - 1];

    // Initialize amplitudes and apply spectral tilt
    amps = 1!numPartials;
    amps = amps * (ratios.log2 * \tiltperoctavedb.kr(-3, 1/30, fixedLag:true)).dbamp;

    // Apply comb filtering
    phase = freqs.log2 - freq.log2;
    phase = (phase * combDensity - combOffset).wrap(0, 1);
    warpedPhase = Select.kr(
        phase > combSkew,
        [
            0.5 * phase / combSkew,
            0.5 * (1 + ((phase - combSkew) / (1 - combSkew)))
        ]
    );
    amps = amps * (
        exp(combPeak.abs * (cos(warpedPhase * 2pi) - 1)) *
        (0.5 * (1 + cos(warpedPhase * 2pi)))
    );

    // Anti-aliasing limiter
    nyquist = SampleRate.ir / 2 - 2000;
    fade = nyquist - 1000;
    limiter = 1 - ((freqs.clip(fade, nyquist) - fade) * 0.001);
    amps = amps * limiter;

    // Generate and sum oscillators
    sig = SinOsc.ar(
        freq: freqs,
        phase: {Rand(0, 2pi)}!numPartials,
        mul: amps
    );

    // Sum odd/even partials with stereo spread
    sig = sig[0,2..].sum + ([-1,1] * sig[1,3..].sum);

    // Output processing
    sig = sig * -15.dbamp;
    sig = sig * \amp.kr(-5, 1/30, fixedLag:true).dbamp;
    sig = Limiter.ar(sig);
    sig = LeakDC.ar(sig);

    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\additivecombplus, {
    arg out=0;
    var numHarmonics = 32; // Reduced base harmonics since we'll multiply by sidebands
    var numSidebands = 7; // Number of sidebands per harmonic
    var numPartials = numHarmonics * numSidebands;

    // Base parameters
    var freq = \pitch.kr(36, 1/30, fixedLag:true).midicps;
    var inharmonicity = \inharmonicity.kr(0, 1/30, fixedLag:true);
    var warpSpectrum = \warpspec.kr(0.5, 1/30, fixedLag:true);
    var combOffset = \comboffset.kr(0, 1/30, fixedLag:true);
    var combDensity = \combdensity.kr(0, 1/30, fixedLag:true);
    var combPeak = \combpeak.kr(5, 1/30, fixedLag:true);
    var combSkew = \combskew.kr(0.5, 1/30, fixedLag:true);

    // New PADsynth and harmonic control parameters
    var bandwidth = \bw.kr(50, 1/30, fixedLag:true); // Bandwidth in Hz
    var bwScale = \bwscale.kr(1, 1/30, fixedLag:true); // How bandwidth scales with frequency
    var oddEven = \oddeven.kr(0, 1/30, fixedLag:true); // -1 to 1, balance of odd/even harmonics
    var stretch = \stretch.kr(1, 1/30, fixedLag:true); // Harmonic stretching factor
    var harmonicRatio = \hratio.kr(1, 1/30, fixedLag:true); // Harmonic series progression
    var sidebandAmp = \sidebandamp.kr(0.7, 1/30, fixedLag:true); // Relative sideband amplitude

    var harmonicNums, baseFreqs, allFreqs, baseAmps, allAmps;
    var normalizedFreqs, warpedFreqs, phase, warpedPhase;
    var oddEvenMask, bw_Hz, windowProfile;
    var sig;
    var nyquist = SampleRate.ir / 2 - 2000;
    var fade = nyquist - 1000;
    var limiter;

    // Generate base harmonic numbers
    harmonicNums = (1..numHarmonics);

    // Apply harmonic stretching and ratio
    baseFreqs = freq * (harmonicNums ** harmonicRatio) *
        (1 + (stretch * (harmonicNums - 1))) *
        (1 + (inharmonicity * harmonicNums * harmonicNums)).sqrt;

    // Generate sideband frequencies for each harmonic
    allFreqs = baseFreqs.collect({ |hfreq, i|
        var sidebandOffset = bandwidth * (1 + (bwScale * i));
        var sidebandRatios = Array.series(numSidebands, -1, 2/(numSidebands-1));
        hfreq + (sidebandRatios * sidebandOffset);
    }).flatten;

    // Initialize amplitudes
    baseAmps = 1!numHarmonics;

    // Apply spectral tilt
    baseAmps = baseAmps * (harmonicNums.log2 * \tiltperoctavedb.kr(-3, 1/30, fixedLag:true)).dbamp;

    // Generate gaussian-like window profile for sidebands
    windowProfile = { |x|
        exp((-2) * x * x);
    };

    // Apply window profile to sidebands
    allAmps = baseAmps.collect({ |amp, i|
        var sidebandAmps = Array.series(numSidebands, -1, 2/(numSidebands-1)).abs;
        sidebandAmps = sidebandAmps.collect(windowProfile);
        sidebandAmps = sidebandAmps * sidebandAmp * amp;
        sidebandAmps[numSidebands/2] = amp; // Restore central partial
        sidebandAmps;
    }).flatten;

    // Apply odd/even harmonic balance
    oddEvenMask = harmonicNums.collect({ |num, i|
        if(num.odd,
            1 + oddEven.max(0),
            1 + oddEven.neg.max(0)
        );
    });
    oddEvenMask = oddEvenMask.collect({ |amp| amp ! numSidebands }).flatten;
    allAmps = allAmps * oddEvenMask;

    // Apply frequency warping
    normalizedFreqs = (allFreqs / allFreqs[numPartials - 1]).clip(0, 1);
    warpedFreqs = Select.kr(
        normalizedFreqs > (1 - warpSpectrum),
        [
            0.5 * normalizedFreqs / (1 - warpSpectrum),
            0.5 * (1 + ((normalizedFreqs - (1 - warpSpectrum)) / warpSpectrum))
        ]
    );
    allFreqs = warpedFreqs * allFreqs[numPartials - 1];

    // Apply comb filtering
    phase = allFreqs.log2 - freq.log2;
    phase = (phase * combDensity - combOffset).wrap(0, 1);
    warpedPhase = Select.kr(
        phase > combSkew,
        [
            0.5 * phase / combSkew,
            0.5 * (1 + ((phase - combSkew) / (1 - combSkew)))
        ]
    );
    allAmps = allAmps * (
        exp(combPeak.abs * (cos(warpedPhase * 2pi) - 1)) *
        (0.5 * (1 + cos(warpedPhase * 2pi)))
    );

    // Anti-aliasing limiter
    limiter = 1 - ((allFreqs.clip(fade, nyquist) - fade) * 0.001);
    allAmps = allAmps * limiter;

    // Generate and sum oscillators
    sig = SinOsc.ar(
        freq: allFreqs,
        phase: {Rand(0, 2pi)}!numPartials,
        mul: allAmps
    );

    // Split odd/even partials for stereo spread
    sig = sig[0,2..].sum + ([-1,1] * sig[1,3..].sum);

    // Output processing
    sig = sig * -15.dbamp;
    sig = sig * \amp.kr(-5, 1/30, fixedLag:true).dbamp;
    sig = Limiter.ar(sig);
    sig = LeakDC.ar(sig);

    Out.ar(out, sig);
}).play();
)