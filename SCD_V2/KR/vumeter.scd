// vumeter.scd - Simple VU meter SynthDef
// Extracted EXACTLY from working polymixer.scd pattern

var d, vumeterDir;

if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

vumeterDir = d +/+ "/vumeter";
File.mkdir(d);
File.mkdir(vumeterDir);

(1..40).do({|numChannels|
    var synthName = ("vumeter" ++ numChannels).asSymbol;

    SynthDef(synthName, {
        arg in=0, out=0, vubus=(-1);
        var sig, vuSig;
        var vuattacktime, vureleasetime;

        // Input - read the specified number of channels
        sig = In.ar(in, numChannels);

        // VU meter attack/release parameters (in milliseconds, converted to seconds)
        vuattacktime = NamedControl.kr(\vuattacktime, 10.0) * 0.001;
        vureleasetime = NamedControl.kr(\vureleasetime, 300.0) * 0.001;

        // Professional VU meter with configurable attack/release
        // EXACTLY like polymixer: LagUD.kr(Amplitude.kr(sig))
        vuSig = LagUD.kr(Amplitude.kr(sig), vuattacktime, vureleasetime);

        // Output VU meter data - EXACTLY like polymixer
        Out.kr(vubus, vuSig);

        // Passthrough output - needed for graph connections
        Out.ar(out, sig);

    }).writeDefFile(vumeterDir);

    // Progress indication
    if([1, 2, 4, 8, 16].includes(numChannels)) {
        ("✅ Created: " ++ synthName ++ " (" ++ numChannels ++ " channels)").postln;
    };
});

("✅ VU Meter SynthDefs created successfully").postln;