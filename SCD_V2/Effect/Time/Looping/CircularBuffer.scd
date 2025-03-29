(
~synthCreator.value("CircularBuffer", {|n|
	var input, circularBufs, writePos, readPos, output;
	var bufFrames, bufferSize;
	var readerRates, readerOffsets, levels;

	// Parameters
	readerRates = OceanodeParameterLag.ar(\rate, 1, n, 0, 8, "vf", 1/30, true);
	readerOffsets = OceanodeParameterLag.ar(\offsetms, 0, n, 0, 20000, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Setup
	bufferSize = 20;  // 20 seconds buffer
	bufFrames = bufferSize * SampleRate.ir;

	// Create buffer for each channel
	circularBufs = n.collect { LocalBuf(bufFrames, 1).clear };

	// Multichannel input
	input = In.ar(OceanodeInput.kr(\in), n);

	// Individual processing for each channel
	output = n.collect { |chan|
		var writePosition, readPosition, offsetSamples;

		// Convert ms to samples
		offsetSamples = readerOffsets[chan] / 1000 * SampleRate.ir;

		// Individual write position for this channel
		writePosition = Phasor.ar(0, 1, 0, bufFrames);

		// Write input to buffer
		BufWr.ar(input[chan], circularBufs[chan], writePosition);

		// Calculate read position with offset and rate
		readPosition = (writePosition - offsetSamples + (Phasor.ar(0, readerRates[chan] - 1, 0, bufFrames))).wrap(0, bufFrames);

		// Read from buffer and apply level
		BufRd.ar(1, circularBufs[chan], readPosition, 1, 4) * levels[chan]
	};

	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Circular buffer with one reader per channel", category: "Effect/Time/Looping");
)