(
~synthCreator.value("CircularBufferFFT2", {|n|
	var input, circularBufs, writePos, output;
	var bufFrames, numActiveReaders, readerAmps;
	var bufferSize, maxReaders, fftSize, overlaps, fftBufs;
	var pos, levels;
	
	// Force 2 channels
	n = 2;
	
	// Parameters
	numActiveReaders = OceanodeParameter.ar(\numreaders, 4, n, 1, 8, "vf");
	pos = OceanodeParameter.ar(\pos, 0, n, 0, 1, "vf");
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Setup
	bufferSize = 20;  // 20 seconds buffer
	maxReaders = 8;  // Fixed number of maximum readers
	fftSize = 16384;
	overlaps = 2;
	
	// Create local buffers for each channel
	bufFrames = bufferSize * SampleRate.ir;
	circularBufs = n.collect { LocalBuf(bufFrames, 1).clear };
	
	// Multichannel input
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Write position
	writePos = Phasor.ar(0, 1, 0, bufFrames);
	
	// Write to buffers
	n.do { |i|
		BufWr.ar(input[i], circularBufs[i], writePos);
	};
	
	// Allocate local buffers for FFT processing
	fftBufs = n.collect { LocalBuf(fftSize!overlaps) };
	
	// Calculate amplitudes for each reader
	readerAmps = maxReaders.collect { |i|
		(i < numActiveReaders).lag(0.1)
	};
	
	// Read from buffers at multiple positions for each channel and apply FFT processing
	output = n.collect { |chan|
		Mix(
			maxReaders.collect { |i|
				var chain;
				var bufPos = pos * bufFrames;
				
				// Creating the chain with BufFFTTrigger
				chain = BufFFTTrigger(fftBufs[chan], 1/overlaps, (0..(overlaps-1)), overlaps);
				// Processing the FFT chain
				chain = BufFFT_BufCopy(chain, circularBufs[chan], bufPos, 1);
				chain = BufFFT(chain);
				chain = PV_Diffuser(chain, chain > -1);
				// IFFT and envelope
				BufIFFT(chain, 0) * 0.8 * readerAmps[i]
			}
		)
	};
	
	Out.ar(OceanodeOutput.kr(\out), output * levels);
	
}, description: "Circular buffer with FFT processing (2 channels only)", category: "Effect/Time/Looping");
)