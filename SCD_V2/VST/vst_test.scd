// 1) First, search for available plugins
(
VSTPlugin.search(verbose: true);
)

VSTPlugin.clear

// 2) Define and add the SynthDef
(
SynthDef(\vstTest, {
    var processed = VSTPlugin.ar(nil, 2, id: \myVST);
    Out.ar(0, processed * 0.5);
}).add;
)

(
~synth = Synth(\vstTest);
~vst = VSTPluginController(~synth, \myVST);
//The name of my Reaktor plugin is "Reaktor 6 vst2"
~vst.open("Reaktor 6 vst2", action: {
    "Plugin loaded successfully!".postln;
    // Open the plugin editor window after loading
    ~vst.editor;
});
)

// 3) When Reaktor editor is opened, i load one of the complex ensembles (TRK-01, Polyplex, Kontour...) using the Reaktor context menu


// 4) Then i save current state as an FXP
(
~vst.writeProgram("~/myfxp.fxp".standardizePath);
"FXP saved!".postln;
)

// 5) At this point, i load any other ensemble, so that the reaktor state is changed strongly


// 6) I try to retrieve the previously saved fxp
(
~vst.readProgram("~/myfxp.fxp".standardizePath);
"FXP loaded!".postln;
)

// And after this, i receive the Error:
// ERROR: couldn't read program: fxProgram: too little data
// and Reaktor state wont be changed at all and my previously saved preset wont be loaded


// 7) Clean up
(
~synth.free;
~vst.close;
)
