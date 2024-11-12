d = thisProcess.nowExecutingPath.dirname;

(
File.mkdir(d ++ "/" ++ "Waveform");
(1..100).do({arg n;
    var numChan = n;
    SynthDef.new("Waveform" ++ (numChan).asSymbol, {
        arg in, out;
        var sig;
        var bufferSize = 512; // Smaller buffer - about 11ms at 48kHz
        var updateRate = 60;
		var localBuf;

        // Get input signal
        sig = In.ar(in, numChan);

        // Local buffer for sample storage
        localBuf = LocalBuf(bufferSize);

        // Continuously write audio into buffer
        RecordBuf.ar(sig, localBuf, loop: 1);

        // Read and output buffer content at updateRate
        Out.kr(out,
            BufRd.kr(
                numChannels: 1,
                bufnum: localBuf,
                phase: LFSaw.kr(updateRate).range(0, BufFrames.ir(localBuf)),
                loop: 1
            )
        );

    }).writeDefFile(d ++ "/Waveform");
})
)