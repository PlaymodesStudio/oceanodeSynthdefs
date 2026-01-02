(
SynthDef(\vst, {
	arg in, out;
	Out.ar(out, VSTPlugin.ar(In.ar(in, 2), 2));
}).writeDefFile(d);
)

// Mono VST SynthDef
(
SynthDef(\vstMono, {
    arg in=0, out=0, mix=1.0;
    var input, output, wetSignal;
    input = In.ar(in, 1);
    wetSignal = VSTPlugin.ar(input, 1);
    // Mix between dry (input) and wet (processed) signal
    // mix=0: 100% dry (bypass), mix=1: 100% wet (fully processed)
    output = XFade2.ar(input, wetSignal, mix * 2 - 1);
    Out.ar(out, output);
}).writeDefFile(d);
)

// Stereo VST SynthDef
(
SynthDef(\vstStereo, {
    arg in=0, out=0, mix=1.0;
    var input, output, wetSignal;
    input = In.ar(in, 2);
    wetSignal = VSTPlugin.ar(input, 2);
    // Mix between dry (input) and wet (processed) signal
    // mix=0: 100% dry (bypass), mix=1: 100% wet (fully processed)
    output = XFade2.ar(input, wetSignal, mix * 2 - 1);
    Out.ar(out, output);
}).writeDefFile(d);
)