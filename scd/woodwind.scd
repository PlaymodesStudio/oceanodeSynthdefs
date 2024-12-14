(
SynthDef(\woodwindMono, {
    arg out=0;
    var excitation, resonator, vibrato, output, formant;
    var env, breathEnv, reedOsc, noise;

    // Basic parameters
    var freq = \pitch.kr(38).midicps;
    var pressure = \pressure.kr(0.001);
    var reedStiff = \reedStiff.kr(0.7);
    var breathAmt = \breathAmt.kr(0.931);

    // Performance parameters
    var vibRate = \vibRate.kr(5);
    var vibDepth = \vibDepth.kr(0.1);
    var lipPos = \lipPos.kr(0.52);
    var filterFreq = \filterFreq.kr(1000);
    var resQ = \resQ.kr(0.68);

    // Nasal tone controls
    var nasality = \nasality.kr(2);    // 0-1 controls nasal character
    var nasalFreq = \nasalFreq.kr(1800); // Formant center frequency
    var nasalRes = \nasalRes.kr(0.98);    // Formant resonance

    // Level control
    var levels = \levels.kr(0.4, 1/30, fixedLag: true);

    // Breath envelope
    breathEnv = \breathenv.kr(1);

    // Add vibrato
    vibrato = SinOsc.kr(vibRate, 0, vibDepth * pressure);

    // Breath noise component
    noise = PinkNoise.ar(breathAmt) * \noiseamt.kr(0.01);

    // Reed oscillator with enhanced even harmonics for nasal character
    reedOsc = SinOsc.ar(freq * (1 + vibrato)) * pressure;
    reedOsc = reedOsc + (SinOsc.ar(freq * 2) * pressure * nasality * 0.5); // Add second harmonic
    reedOsc = (reedOsc * reedStiff).tanh;

    // Combine breath and reed oscillation
    excitation = (noise + reedOsc) * breathEnv;

    // Model the instrument body with enhanced nasal resonances
    resonator = DynKlank.ar(
        `[
            // Fundamental and harmonics with emphasis on nasal frequencies
            [freq, freq*2, freq*3, freq*4, freq*5],
            // Relative amplitudes with emphasis on nasal harmonics
            [1, 0.5 * (1 + nasality), 0.25, 0.125 * (1 + nasality), 0.0625],
            // Decay times
            [1, 0.8, 0.6, 0.4, 0.2] * resQ
        ],
        excitation
    );

    // Model the lip position effect
    resonator = RLPF.ar(
        resonator,
        filterFreq * (1 + (lipPos * 0.5)),
        resQ
    );

    // Add formant filtering for nasal character
    formant = BPF.ar(
        resonator,
        nasalFreq * (1 + (nasality * 0.5)), // Formant frequency shifts with nasality
        0.1 + (nasalRes * nasality)         // Resonance increases with nasality
    );

    // Mix original and formant-filtered signals based on nasality
    resonator = XFade2.ar(resonator, formant, (nasality * 2) - 1);

    // Additional nasal formant
    resonator = resonator + BPF.ar(
        resonator,
        2500 * (1 + (nasality * 0.3)), // Second formant
        0.1 + (nasalRes * nasality * 0.5)
    ) * nasality;

    // Apply envelope
    env = 1;

    // Final output with level control
    output = resonator * env * levels;

    // Filter out DC offset and very low frequencies
    output = HPF.ar(output, 20);

    Out.ar(out, output);
}).play;
)

(
SynthDef(\woodwind13, {
    arg out=0;
    var excitation, resonator, vibrato, output;
    var reedOsc, noise;

    // Basic parameters with 13-channel expansion
    var freq = \pitch.kr(58!13).midicps;

    // Performance parameters with expansion
    var pressure = \pressure.kr(0.21!13);
    var breathAmt = \breathAmt.kr(0.081!13);
    var nasality = \nasality.kr(4!13);
    var lipPos = \lipPos.kr(0.5!13);

    // Vibrato parameters
    var vibRate = \vibRate.kr(5!13);  // Single value
    var vibDepth = \vibDepth.kr(0.001!13);

    // Level control
    var levels = \levels.kr(0.5!13, 1/30, fixedLag: true);

    // Global parameters
    var reedStiff = \reedStiff.kr(0.97!13);
    var resQ = \resQ.kr(0.68);
    var nasalFreq = \nasalFreq.kr(1600!13);
    var nasalRes = \nasalRes.kr(0.987!13);

    // Add vibrato
    vibrato = SinOsc.kr(vibRate, 0, vibDepth);
    freq = freq * (1 + vibrato);

    // Optimize noise generation
    noise = PinkNoise.ar * breathAmt * 0.02;

    // Reed oscillator with vibrato
    reedOsc = SinOsc.ar(freq) * pressure * 0.01;
    reedOsc = (reedOsc * reedStiff).tanh;

    // Combine breath and reed
    excitation = noise + reedOsc;

    // Resonator with lip position influence
    resonator = DynKlank.ar(
        `[
            [1, 2, 3, 4, 5],
            [1, 0.5, 0.25, 0.125, 0.0625],
            [1, 0.8, 0.6, 0.4, 0.2] * resQ
        ],
        excitation,
        freq * (1 + (lipPos * 0.1))  // Lip position affects pitch slightly
    );

    // Enhanced formant filtering with nasalRes
    resonator = BPF.ar(
        resonator,
        nasalFreq * (1 + (lipPos * 0.2)),  // Lip position influences formant
        nasalRes * (0.1 + (nasality * 0.1))
    ) * nasality + resonator;

    // Secondary formant for enhanced nasal character
    resonator = resonator + BPF.ar(
        resonator,
        nasalFreq * 2.5,
        nasalRes * 0.5
    ) * (nasality * 0.3);

    // Final output
    output = resonator * levels;
    output = HPF.ar(output, 20);

    Out.ar(out, output);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
