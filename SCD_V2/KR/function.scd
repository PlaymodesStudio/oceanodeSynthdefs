var d, scFunctionDir;

if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

scFunctionDir = d +/+ "/scFunction";
File.mkdir(d);
File.mkdir(scFunctionDir);

(1..16).do({|numChannels|
    var synthName = ("scFunction" ++ numChannels).asSymbol;

    SynthDef(synthName, {
        arg in=0, out=0;
        var input, output;
        input = In.ar(in, numChannels);
        output = input;  // Start with pass-through
        Out.ar(out, output);

    }).writeDefFile(scFunctionDir);

    // Progress indication
    if([1, 2, 4, 8, 16].includes(numChannels)) {
        ("Created: " ++ synthName ++ " (" ++ numChannels ++ " channels)").postln;
    };
});

"scFunction SynthDefs created successfully".postln;