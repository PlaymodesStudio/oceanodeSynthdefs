var d, wavescopeDir;

if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

wavescopeDir = d +/+ "/wavescope2";
File.mkdir(d);
File.mkdir(wavescopeDir);

~samplesPerFrame = 64;
~bufferSize = 256;

[1, 2, 4, 6, 8, 16, 21, 32, 64, 126].do({|numChannels|
    var synthName = ("wavescope_realtime" ++ numChannels).asSymbol;

    SynthDef(synthName, {
        arg in, out, refreshRate = 60;
        var sig, buffers, writePos;

        sig = In.ar(in, numChannels);
        writePos = Phasor.ar(0, 1, 0, ~bufferSize, 0);
        buffers = Array.fill(numChannels, { LocalBuf(~bufferSize) });

        numChannels.do({|ch|
            BufWr.ar(sig[ch], buffers[ch], writePos);
        });

        // Output to individual control buses (channel-major order)
        numChannels.do({|ch|
            ~samplesPerFrame.do({|i|
                var lookbackRatio = i / (~samplesPerFrame - 1);
                var lookback = (1.0 - lookbackRatio) * (~samplesPerFrame - 1);
                var offset = (writePos - lookback) % ~bufferSize;
                var sample = BufRd.ar(1, buffers[ch], offset, loop: 1, interpolation: 1);
                var busIndex = out + (ch * ~samplesPerFrame) + i;
                Out.kr(busIndex, A2K.kr(sample));
            });
        });

    }).writeDefFile(wavescopeDir);

    if([1, 2, 4, 6, 8, 16, 21, 32, 64, 126].includes(numChannels)) {
        ("✓ Created: " ++ synthName).postln;
    };
});

"✓ Wavescope2 SynthDefs created".postln;