(
~synthCreator.value("CircularBufferFFT", {|n|
	var input, circularBufs, writePos, output;
	var bufFrames, numActiveReaders, readerAmps;
	var bufferSize, maxReaders, fftSize, overlaps;
	var pos, levels;
	
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
	
	// Calculate amplitudes for each reader
	readerAmps = maxReaders.collect { |i|
		(i < numActiveReaders).lag(0.1)
	};
	
	// Process each channel individually
	output = Array.fill(n, { |chan|
		// Create a mono synth for this channel
		var monoOutput;
		var bufPos = pos * bufFrames;
		var fftBuf = LocalBuf(fftSize!overlaps);
		var chain;
		
		// Process this single channel with FFT
		chain = BufFFTTrigger(fftBuf, 1/overlaps, (0..(overlaps-1)), overlaps);
		chain = BufFFT_BufCopy(chain, circularBufs[chan], bufPos, 1);
		chain = BufFFT(chain);
		chain = PV_Diffuser(chain, chain > -1);
		monoOutput = BufIFFT(chain, 0);
		
		// Apply amplitude scaling
		monoOutput * 0.8 * Mix(readerAmps);
	});
	
	Out.ar(OceanodeOutput.kr(\out), output * levels);
	
}, description: "Circular buffer with FFT processing for each channel", category: "Effect/Time/Looping");
)