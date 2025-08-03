(
SynthDef(\vst, {
	arg in, out;
	Out.ar(out, VSTPlugin.ar(In.ar(in, 2), 2));
}).writeDefFile(d);
)

// Mono VST SynthDef
(
SynthDef(\vstMono, {
    arg in=0, out=0;
    var input, output;
    input = In.ar(in, 1);
    output = VSTPlugin.ar(input, 1);
    Out.ar(out, output);
}).writeDefFile(d);
)

// Stereo VST SynthDef
(
SynthDef(\vstStereo, {
    arg in=0, out=0;
    var input, output;
    input = In.ar(in, 2);
    output = VSTPlugin.ar(input, 2);
    Out.ar(out, output);
}).writeDefFile(d);
)