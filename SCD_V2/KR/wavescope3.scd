var d, wavescope3Dir;

if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

wavescope3Dir = d +/+ "/wavescope3";
File.mkdir(d);
File.mkdir(wavescope3Dir);

~samplesPerChannel = 64;
~maxBufferSeconds = 5.0;

(1..16).do({|numChannels|
    var synthName = ("wavescope3_" ++ numChannels).asSymbol;

    SynthDef(synthName, {
        arg in, out, timeWindow = 0.01;
        var sig, sampleRate, bufferSize, writePhase, localBufs;
        var samplesForTimeWindow;

        sig = In.ar(in, numChannels);
        sampleRate = SampleRate.ir;
        bufferSize = (~maxBufferSeconds * sampleRate).asInteger;
        writePhase = Phasor.ar(0, 1, 0, bufferSize);
        localBufs = Array.fill(numChannels, { LocalBuf(bufferSize, 1) });

        samplesForTimeWindow = (timeWindow * sampleRate).clip(1, bufferSize);

        numChannels.do({|ch|
            RecordBuf.ar(sig[ch], localBufs[ch], writePhase, loop: 1);
        });

        numChannels.do({|ch|
    ~samplesPerChannel.do({|i|
        var lookbackRatio = i / (~samplesPerChannel - 1);
        var lookback = (1.0 - lookbackRatio) * samplesForTimeWindow;  // REVERSED
        var readPos = (writePhase - lookback) % bufferSize;
        var sample = BufRd.ar(1, localBufs[ch], readPos, loop: 1, interpolation: 1);
        var busIndex = out + (ch * ~samplesPerChannel) + i;
        Out.kr(busIndex, A2K.kr(sample));
    });
});

    }).writeDefFile(wavescope3Dir);

    if([1, 2, 4, 8, 16].includes(numChannels)) {
        ("✓ Created: " ++ synthName ++ " (variable time window)").postln;
    };
});

"✓ Wavescope3 SynthDefs created".postln;
"• 64 samples per channel".postln;
"• Variable time window: 0.001 to 1.0 seconds".postln;