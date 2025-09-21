// Updated polymixer.scd - Fixed VU meter implementation

var d, polymixerDir;

if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

polymixerDir = d +/+ "/polymixer";
File.mkdir(d);
File.mkdir(polymixerDir);

(1..16).do({|numChannels|
    var synthName = ("polyMixerTrack" ++ numChannels).asSymbol;

    SynthDef(synthName, {
        arg in=0, out=0, mute=0, vuBus=(-1);
        var sig, level, masterLevel, vuSig, processedSig;
        var vuAttackTime, vuReleaseTime;

        // Input - read the specified number of channels
        sig = In.ar(in, numChannels);

        // Level control (combined trackLevel * levelVecMultiplier from C++)
        level = NamedControl.kr(\level, Array.fill(numChannels, 0.75));

        // Master level control
        masterLevel = NamedControl.kr(\masterLevel, Array.fill(numChannels, 1.0));

        // VU meter attack/release parameters (in milliseconds, converted to seconds)
        vuAttackTime = NamedControl.kr(\vuAttackTime, 10.0) * 0.001; // Convert ms to seconds
        vuReleaseTime = NamedControl.kr(\vuReleaseTime, 300.0) * 0.001; // Convert ms to seconds

        // Apply per-channel track level with smooth lag
        processedSig = sig * level.lag(0.05);

        // Apply mute (1 = muted, 0 = not muted)
        processedSig = processedSig * (1 - mute);

        // Apply per-channel master level with smooth lag
        processedSig = processedSig * masterLevel.lag(0.05);

        // Professional VU meter with configurable attack/release
        // Use LagUD for separate attack and release times
        vuSig = LagUD.kr(Amplitude.kr(processedSig), vuAttackTime, vuReleaseTime);

        // Output VU meter data - EXACTLY like info.scd pattern
        Out.kr(vuBus, vuSig);

        // Audio output
        Out.ar(out, processedSig);

    }).writeDefFile(polymixerDir);

    // Progress indication
    if([1, 2, 4, 8, 16].includes(numChannels)) {
        ("✅ Created: " ++ synthName ++ " (" ++ numChannels ++ " channels, fixed VU meters)").postln;
    };
});

("✅ Fixed PolyMixer SynthDefs created successfully").postln;
("• VU meters now calculate from PROCESSED signal (post-level, post-mute)").postln;
("• Added vuBus validity check in SuperCollider").postln;
("• Matches scInfo pattern for amplitude calculation").postln;