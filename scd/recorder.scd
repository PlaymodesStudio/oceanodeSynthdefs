(
File.mkdir(d ++ "/" ++ "Recorder");
(1..100).do({arg n;
    var numChan = n;
    SynthDef.new("Recorder" ++ numChan.asSymbol, {
        arg in, buf;
        var input = In.ar(in, numChan);
        RecordBuf.ar(input, buf, 0, 1, 0, loop: 0);
    }, metadata: (name: "Recorder", type: "effect", numInputs: numChan, numBuffers: 1)).writeDefFile(d ++ "/Recorder");
})
)

d = thisProcess.nowExecutingPath.dirname;

Server.helpSourceDir // Opens folder with server docs

