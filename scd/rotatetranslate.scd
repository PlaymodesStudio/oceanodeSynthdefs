(
SynthDef(\rotatetranslate, {
    arg in, out=0;
    var rotate=\rotate.kr(0), x=\x.kr(0), y=\y.kr(0), scale=\scale.kr(1!2);
    var sig, rotatedSig, angle;

    // Input signal (stereo)
    sig = In.ar(in, 2);

    // Convert rotation to radians (negative for clockwise rotation)
    angle = rotate * 2pi.neg;

    // Apply rotation using polar coordinates
    rotatedSig = [
        (sig[0].squared + sig[1].squared).sqrt, // Calculate radius
        sig[1].atan2(sig[0]) // Calculate angle
    ];

    // Add rotation angle and convert back to Cartesian coordinates
    rotatedSig = [
        rotatedSig[0] * cos(rotatedSig[1] + angle),
        rotatedSig[0] * sin(rotatedSig[1] + angle)
    ];

    // Apply translation
    rotatedSig = [
        rotatedSig[0] + x,
        rotatedSig[1] + y
    ];

    // Apply scaling
    rotatedSig = rotatedSig * scale;

    // Ensure the signal is within a reasonable range
    rotatedSig = rotatedSig.clip2(1);

    // Output the processed signal
    Out.ar(out, rotatedSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


// Example usage:
// Create a bus for the input signal
~inputBus = Bus.audio(s, 2);

// Create the main synth (your Lissajous generator) outputting to the input bus
~mainSynth = Synth(\lissajous2, [\out, ~inputBus]);

// Create the effect synth
~effectSynth = Synth(\rotatetranslate, [\in, ~inputBus, \out, 0], addAction: \addAfter, target: ~mainSynth);

// Function to create a scope for visualization
(
~createScope = {
    var scope = Stethoscope.new(s, 2, view: Window.new("Rotated/Translated Lissajous", Rect(200, 200, 500, 500)).front);
    scope.style = 2;  // XY mode
    scope.xZoom = 1;
    scope.yZoom = 1;
    scope
};
)

// Create the scope
~scope = ~createScope.value;

// Manipulate the effect in real-time
~effectSynth.set(\rotate, 0.25);  // Rotate by 90 degrees
~effectSynth.set(\x, 0.2, \y, -0.1);  // Translate

// Clean up
~mainSynth.free;
~effectSynth.free;
~scope.free;
~inputBus.free;