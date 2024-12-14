NN.load(\ravemodel, "/Users/santiagovilanova/Documents/_OF/openFrameworks_GIT_PM/apps/Liceu/OceanodeScroller/bin/data/Supercollider/RAVE_MODELS/percussion.ts");

(
SynthDef(\rave, {
    arg in = 0, out = 0;
    var sig, amp;

    amp = \levels.kr(1!2, 1/30, fixedLag: true);

    sig = In.ar(in, 1);
    sig = NN(\ravemodel, \forward).ar(sig);
    Out.ar(out, sig * amp);
}).writeDefFile(d);
)

(
SynthDef(\rave, {
    arg in = 0, out = 0;
    var modelReady = \modelready.kr(0);
    var sig, amp;

    amp = \levels.kr(1!2, 1/30, fixedLag: true);

    sig = In.ar(in, 1);

    // Safely handle NN processing
    sig = Select.ar(modelReady, [
        sig, // Pass through when not ready
        SoftClipAmp.ar(  // Add safety clipping
            NN(\ravemodel, \forward).ar(sig)
        )
    ]);

    // Safety check the output
    sig = Select.ar(CheckBadValues.ar(sig), [
        sig,        // Good values
        DC.ar(0),   // Replace bad values with silence
    ]);

    Out.ar(out, sig * amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
// First get and print the SuperCollider support directory
~scSupportDir = Platform.userAppSupportDir;
("SuperCollider support dir:" + ~scSupportDir).postln;

// Create tmp directory if it doesn't exist
~tmpDir = ~scSupportDir +/+ "tmp";
File.mkdir(~tmpDir);
("Created tmp directory at:" + ~tmpDir).postln;

// Test if we can write a file
~testFile = ~tmpDir +/+ "test.txt";
f = File(~testFile, "w");
f.write("test");
f.close;
("Created test file at:" + ~testFile).postln;
)

(
// Test model file access
~modelPath = "/Users/santiagovilanova/Documents/_OF/openFrameworks_GIT_PM/apps/Liceu/OceanodeScroller/bin/data/Supercollider/RAVE_MODELS/percussion.ts";

// Check if file exists and is readable
f = File(~modelPath, "r");
if(f.isOpen) {
    "Model file exists and is readable".postln;
    f.close;
} {
    "Cannot open model file".postln;
};

// Print file size and permissions
~modelFile = PathName(~modelPath);
("File exists:" + File.exists(~modelPath)).postln;
("File size:" + File.size(~modelPath)).postln;

// Try to read first few bytes to verify it's not corrupted
if(File.exists(~modelPath)) {
    f = File(~modelPath, "rb");
    if(f.isOpen) {
        ~bytes = f.readAllString(100);  // Read first 100 bytes
        ("First bytes:" + ~bytes.ascii).postln;
        f.close;
    }
};
)