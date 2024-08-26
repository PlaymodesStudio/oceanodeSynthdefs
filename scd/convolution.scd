(
// Load IR from WAV file
~loadIR = { |server, path|
    Buffer.read(server, path);
};

SynthDef(\convolutionReverbSimple, { |out=0, irbufnum, burstFreq=1, sawFreq=80, framesize=2048, mix=0.5|
    var input, kernel, convolved, signal;

    // Input signal: short bursts of saw wave
    input = Saw.ar(sawFreq);

    // Read the IR buffer
    kernel = PlayBuf.ar(1, irbufnum, BufRateScale.kr(irbufnum), loop: 1);

    // Perform convolution
    convolved = Convolution.ar(input, kernel, framesize);

    // Mix dry and wet signals
    signal = XFade2.ar(input, convolved, mix * 2 - 1);

    // Output
    Out.ar(out, signal * 0.1);  // Reduced amplitude for safety
}).add;

// Usage
s.waitForBoot({
    ~irBuf = ~loadIR.(s, "/Users/santiagovilanova/Documents/SAMPLES/IR/EchoThiefImpulseResponseLibrary/Brutalism/NaturalSciences.wav");  // Replace with your IR file path
    s.sync;  // Ensure buffer is loaded

    ~reverbSynth = Synth(\convolutionReverbSimple, [
        \irbufnum, ~irBuf.bufnum,
        \burstFreq, 1,  // 1 burst per second
        \sawFreq, 80,   // 80 Hz saw wave
        \framesize, 2048,
        \mix, 0.5
    ]);
});
)

// To stop and clean up
(
~reverbSynth.free;
~irBuf.free;
)