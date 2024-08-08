(
SynthDef(\circularbuffer13, {
    arg in = 0, out = 0;
    var numChannels = 13;
    var input, circularBufs, writePos, readPos, output;
    var bufFrames, numActiveReaders, readerAmps, readerRates, readerOffsets;
    var bufferSize = 20;  // 20 seconds buffer
    var maxReaders = 8;  // Fixed number of maximum readers

    // Create local buffers for each channel
    bufFrames = bufferSize * SampleRate.ir;
    circularBufs = numChannels.collect { LocalBuf(bufFrames, 1).clear };

    // Multichannel input
    input = In.ar(in, numChannels);

    // Control inputs for multiple readers
    numActiveReaders = \numreaders.kr(4);
    readerRates = \rate.kr(1!maxReaders);
    readerOffsets = \offsetms.kr(100!maxReaders, 1/30, fixedLag:true) / 1000 * SampleRate.ir;  // Convert ms to samples

    // Write position
    writePos = Phasor.ar(0, 1, 0, bufFrames);

    // Write to buffers
    numChannels.do { |i|
        BufWr.ar(input[i], circularBufs[i], writePos);
    };

    // Multiple read positions
    readPos = maxReaders.collect { |i|
        var phaseOffset = readerOffsets[i];
        var rate = readerRates[i];
        (writePos - phaseOffset + (Phasor.ar(0, rate - 1, 0, bufFrames))).wrap(0, bufFrames)
    };

    // Calculate amplitudes for each reader
    readerAmps = maxReaders.collect { |i|
        (i < numActiveReaders).lag(0.1)
    };

    // Read from buffers at multiple positions for each channel
    output = numChannels.collect { |chan|
        Mix(
            maxReaders.collect { |i|
                BufRd.ar(1, circularBufs[chan], readPos[i], 1, 4) * readerAmps[i]
            }
        )
    };

    Out.ar(out, output);
}).writeDefFile(d);
)


(
SynthDef(\circularbufferfft2, {
    arg in = 0, out = 0;
    var numChannels = 13;
    var input, circularBufs, writePos, output;
    var bufFrames, numActiveReaders, readerAmps;
    var bufferSize = 20;  // 20 seconds buffer
    var maxReaders = 8;  // Fixed number of maximum readers
    var fftSize = 16384, overlaps = 2;
    var fftBufs;

    // Create local buffers for each channel
    bufFrames = bufferSize * SampleRate.ir;
    circularBufs = numChannels.collect { LocalBuf(bufFrames, 1).clear };

    // Multichannel input
    input = In.ar(in, numChannels);

    // Control inputs for multiple readers
    numActiveReaders = \numreaders.kr(4);

    // Write position
    writePos = Phasor.ar(0, 1, 0, bufFrames);

    // Write to buffers
    numChannels.do { |i|
        BufWr.ar(input[i], circularBufs[i], writePos);
    };

    // Allocate local buffers for FFT processing
    fftBufs = numChannels.collect { LocalBuf(fftSize!overlaps) };

    // Calculate amplitudes for each reader
    readerAmps = maxReaders.collect { |i|
        (i < numActiveReaders).lag(0.1)
    };

    // Read from buffers at multiple positions for each channel and apply FFT processing
    output = numChannels.collect { |chan|
        Mix(
            maxReaders.collect { |i|
                var chain;
                var pos = \pos.kr(0!maxReaders)[i] * bufFrames;

                // Creating the chain with BufFFTTrigger
                chain = BufFFTTrigger(fftBufs[chan], 1/overlaps, (0..(overlaps-1)), overlaps);
                // Processing the FFT chain
                chain = BufFFT_BufCopy(chain, circularBufs[chan], pos, 1);
                chain = BufFFT(chain);
                chain = PV_Diffuser(chain, chain > -1);
                // IFFT and envelope
                BufIFFT(chain, 0) * 0.8 * readerAmps[i]
            }
        )
    };

    Out.ar(out, output);
}).writeDefFile(d);
)

// Example usage for stereo
x = Synth(\circularBufferFFTMultichannel, [\in, 0, \out, 0, \numChannels, 2, \numReaders, 4]);

// Example usage for quad
y = Synth(\circularBufferFFTMultichannel, [\in, 0, \out, 0, \numChannels, 4, \numReaders, 4]);

// Change positions for readers
x.set(\pos, [0, 0.25, 0.5, 0.75, 0, 0, 0, 0]);  // Set positions for all readers

// Change number of active readers
x.set(\numReaders, 6);

// Free the synths when done
x.free;
y.free;