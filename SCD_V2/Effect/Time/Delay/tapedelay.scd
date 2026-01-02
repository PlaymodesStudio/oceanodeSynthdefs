(
~synthCreator.value("TapeDelay", {|n|
	var input, sendVar, bufs, numChan, bufSize, writePos, write, readPos, read, time, sig;
	var loShelf, hiShelf, feedback, loGain, hiGain, mix, send;
	
	// Parameters
	loShelf = OceanodeParameter.ar(\loshlv, 300, n, 50, 1000, "vf");
	hiShelf = OceanodeParameter.ar(\hishlv, 1500, n, 1000, 10000, "vf");
	feedback = OceanodeParameter.ar(\fb, 0.5, n, 0, 0.99, "vf");
	loGain = OceanodeParameter.ar(\logain, 0, n, -12, 12, "vf");
	hiGain = OceanodeParameter.ar(\higain, 0, n, -12, 12, "vf");
	time = OceanodeParameterLag.ar(\time, 1, n, 0.1, 5, "vf", 0.4, true);
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input processing
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Process each channel independently
	sig = n.collect { |i|
		var chanInput, chanSend, chanBuf, chanWritePos, chanReadPos, chanRead, chanWrite, chanOut;
		
		chanInput = input[i];
		
		// Apply shelving filters to input with send parameter
		chanSend = chanInput * send[i];
		chanSend = BLowShelf.ar(chanSend, loShelf[i], 1, loGain[i]);
		chanSend = BHiShelf.ar(chanSend, hiShelf[i], 1, hiGain[i]);
		
		// Create local buffer for delay
		bufSize = SampleRate.ir * 10;  // 10 seconds maximum delay
		chanBuf = LocalBuf(bufSize, 1).clear;
		
		// Calculate write position
		chanWritePos = Phasor.ar(0.0, 1, 0.0, bufSize);
		
		// Calculate read position (half buffer offset for tape-style delay)
		chanReadPos = (chanWritePos - (SampleRate.ir * time[i])).wrap(0, bufSize);
		
		// Read from buffer
		chanRead = BufRd.ar(1, chanBuf, phase: chanReadPos, loop: 1, interpolation: 4);
		
		// Apply feedback and write to buffer
		chanSend = chanSend + (chanRead * feedback[i]);
		chanWrite = BufWr.ar(chanSend, chanBuf, chanWritePos, loop: 1);
		
		// Mix dry and wet signals
		XFade2.ar(chanInput, chanRead, mix[i] * 2 - 1);
	};
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Tape-style delay with shelving filters and feedback", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)