(
    SynthDef(\tapedelay1, {
        var in, send, buf, numChan, bufSize, writePos, write, readPos, read, time, sig;

        in = Saw.ar({LFNoise0.kr(0.25, 24, 72).round.lag(0.4).midicps}!4)
        * Decay2.ar(Impulse.ar(0.25), 0.5, 2)
        * -18.dbamp;
        in = in.sum;

        send = BLowShelf.ar(in, \loShlv.kr(300), 1, -6);
        send = BHiShelf.ar(send, \hiShlv.kr(1500), 1, -6);

        numChan = 1;
        bufSize = (s.sampleRate * 10);
        buf = LocalBuf(bufSize, numChan);
        //buf = Buffer.alloc(s, max, numChan);
        buf.clear;

        //time = (10 / \time.kr(2)).lag(0.4).round;
        time = (5 / \time.kr(1)).lag(0.4);
        writePos = Phasor.ar(0.0, time, 0.0, bufSize).poll;

        readPos = (writePos + (bufSize * 0.5)).wrap(0, bufSize).poll;
        read = BufRd.ar(numChan, buf, phase: readPos, loop: 1, interpolation: 4);

        send = send + (read * \fb.kr(0.5));

        write = IBufWr.ar(inputArray: [send], bufnum: buf, phase: writePos, loop: 1.0);

        sig = in + read;
        sig = sig!2;
        Out.ar(0, sig);
}).play();
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\tapedelay13, {
    arg in=0, out=0;
    var input, send, bufs, numChan, bufSize, writePos, write, readPos, read, time, sig;
	var loShelf = \loshlv.kr(300!13);
    var hiShelf = \hishlv.kr(1500!13);
    var feedback = \fb.kr(0.5!13);
	var loGain = \logain.kr(0!13);  // 0 dB = no effect
	var hiGain = \higain.kr(0!13);  // 0 dB = no effect

    // Get input from 13 channels
    input = In.ar(in, 13);

    // Process each channel with its own parameters
    numChan = 13;
    bufSize = (s.sampleRate * 10).asInteger;

    // Create 13 separate buffers
    bufs = Array.fill(numChan, { LocalBuf(bufSize, 1).clear });

    // Parameter arrays for 13 channels
    time = (5 / \time.kr(1!13)).lag(0.4);


    // Apply shelving filters
    send = Array.fill(13, {|i|
    var ch = BLowShelf.ar(input[i], loShelf[i], 1, loGain[i]);
    ch = BHiShelf.ar(ch, hiShelf[i], 1, hiGain[i]);
    ch;
});

    // Create separate phase positions for each channel
    writePos = Array.fill(13, {|i|
        Phasor.ar(0.0, time[i], 0.0, bufSize);
    });

    readPos = Array.fill(13, {|i|
        (writePos[i] + (bufSize * 0.5)).wrap(0, bufSize);
    });

    // Read from buffer - removed miprange parameter
    read = Array.fill(13, {|i|
        BufRd.ar(1, bufs[i], phase: readPos[i], loop: 1, interpolation: 4);
    });

    // Mix input with feedback
    send = Array.fill(13, {|i|
        send[i] + (read[i] * feedback[i]);
    });

    // Write to buffer - removed loop parameter
    write = Array.fill(13, {|i|
        BufWr.ar(send[i], bufs[i], writePos[i]);
    });

    // Create output signal (original + delay)
    sig = Array.fill(13, {|i|
        input[i] + read[i];
    });

    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\tapedelay, {
	arg in=0, out=0;

        var send, buf, numChan, bufSize, writePos, write, readPos, read, time, sig;
		var loGain = \logain.kr(0);  // 0 dB = no effect
	var hiGain = \higain.kr(0);  // 0 dB = no effect
        in = In.ar(in, 1);
        send = BLowShelf.ar(in, \loshlv.kr(300), 1, loGain);
        send = BHiShelf.ar(send, \hishlv.kr(1500), 1, hiGain);
        numChan = 1;
        bufSize = (s.sampleRate * 10);
        buf = LocalBuf(bufSize, numChan);
        //buf = Buffer.alloc(s, max, numChan);
        buf.clear;
        //time = (10 / \time.kr(2)).lag(0.4).round;
        time = (5 / \time.kr(1)).lag(0.4);
        writePos = Phasor.ar(0.0, time, 0.0, bufSize).poll;
        readPos = (writePos + (bufSize * 0.5)).wrap(0, bufSize).poll;
        read = BufRd.ar(numChan, buf, phase: readPos, loop: 1, interpolation: 4);
        send = send + (read * \fb.kr(0.5));
        write = IBufWr.ar(inputArray: [send], bufnum: buf, phase: writePos);
        sig = in + read;
        Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\feedtape, {
	arg in=0, out=0;

        var send, buf, numChan, bufSize, writePos, write, readPos, read, time, sig;

        in = In.ar(in, 1);
	send =in;
        numChan = 1;
        bufSize = (s.sampleRate * 10);
        buf = LocalBuf(bufSize, numChan);
        buf.clear;
        time = \time.kr(1).lag(0.4);
        writePos = Phasor.ar(0.0, time, 0.0, bufSize).poll;
        readPos = (writePos + (bufSize * 0.5)).wrap(0, bufSize).poll;
        read = BufRd.ar(numChan, buf, phase: readPos, loop: 1, interpolation: 4);
        send = send + read;
        write = IBufWr.ar(inputArray: [send], bufnum: buf, phase: writePos);
        sig = in + read;
        Out.ar(out, sig);
}).writeDefFile(d);
)