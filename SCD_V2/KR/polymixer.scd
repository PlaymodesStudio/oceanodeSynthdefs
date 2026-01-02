// Updated polymixer.scd - Handle -1 as no input using Select
var d, polymixerDir;
if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};
polymixerDir = d +/+ "/polymixer";
File.mkdir(d);
File.mkdir(polymixerDir);
[1, 2, 4, 6, 21, 126].do({|numChannels|
    var synthName = ("polyMixerTrack" ++ numChannels).asSymbol;
    SynthDef(synthName, {
        arg in=0, out=0, mute=0, vuBus=(-1);
        var sig, level, masterLevel, vuSig, processedSig, inputSig, silentSig;
        var vuAttackTime, vuReleaseTime;

        // Create both possible inputs
        inputSig = In.ar(in, numChannels);  // Read from bus
        silentSig = Silent.ar(numChannels);  // Silent signal

        // Use gate to select: if in < 0, use silence; otherwise use input
        // Gate.ar keeps signal flowing when gate > 0, outputs 0 when gate <= 0
        sig = Gate.ar(inputSig, (in >= 0));

        // Level control (combined trackLevel * levelVecMultiplier from C++)
        level = NamedControl.kr(\level, Array.fill(numChannels, 0.75));

        // Master level control
        masterLevel = NamedControl.kr(\masterLevel, Array.fill(numChannels, 1.0));

        // VU meter attack/release parameters (in milliseconds, converted to seconds)
        vuAttackTime = NamedControl.kr(\vuAttackTime, 10.0) * 0.001;
        vuReleaseTime = NamedControl.kr(\vuReleaseTime, 300.0) * 0.001;

        // Apply per-channel track level with smooth lag
        processedSig = sig * level.lag(0.05);

        // Apply mute (1 = muted, 0 = not muted)
        processedSig = processedSig * (1 - mute);

        // VU meter measures HERE - BEFORE master level is applied
        vuSig = LagUD.kr(Amplitude.kr(processedSig), vuAttackTime, vuReleaseTime);

        // Output VU meter data (gate it so it only outputs when vuBus >= 0)
        Out.kr(vuBus, vuSig * (vuBus >= 0));

        // Apply per-channel master level with smooth lag AFTER VU measurement
        processedSig = processedSig * masterLevel.lag(0.05);

        // Audio output
        Out.ar(out, processedSig);
    }).writeDefFile(polymixerDir);

    if([1, 2, 4, 6, 21, 126].includes(numChannels)) {
        ("✅ Created: " ++ synthName ++ " (" ++ numChannels ++ " channels)").postln;
    };
});
("✅ PolyMixer SynthDefs created successfully").postln;
("• Track input uses Gate.ar to silence when in < 0").postln;
("• VU meters measure BEFORE master level").postln;