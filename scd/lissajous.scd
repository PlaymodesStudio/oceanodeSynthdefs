(
SynthDef(\lissajous2, {
    arg out=0;
    var p, waves, pulsew, finalSig, fm, fmp, fma, phase;
    var sawOsc, triOsc, pulseOsc, phasor;
    var pow, bipow, shapedSig;
    var mapPow;

    // Input parameters
    p = \pitch.kr(36!2);
    pulsew = \pw.kr(0.5!2);
    phase = \phase.kr(0!2);
    pow = \pow.kr(0!2);
    bipow = \bipow.kr(0!2);

    // Mapping function for pow and bipow
    mapPow = { |x|
        var minExp = 1/32, maxExp = 32;
        Select.kr(x >= 0,
            [
                // For x < 0: map -1 to 0 to 1/32 to 1
                minExp.pow(1 - x.abs),
                // For x >= 0: map 0 to 1 to 1 to 32
                maxExp.pow(x)
            ]
        );
    };
    pow = mapPow.(pow);
    bipow = mapPow.(bipow);

    // FM
    fmp = \fmpitch.kr(48!2);
    fma = \fmamp.kr(0!2);
    fm = SinOsc.ar(fmp.midicps, 0) * fma;

    // Phasor for custom oscillators
    phasor = phase + Phasor.ar(0, (p + fm).midicps / SampleRate.ir, 0, 1);

    // Custom oscillators with phase control
    sawOsc = (phasor * 2) - 1;
    triOsc = (phasor * 4 - 1).fold2(1);
    pulseOsc = (phasor < pulsew) * 2 - 1;

    waves = [
        sawOsc,
        triOsc,
        pulseOsc,
        SinOsc.ar(0, phasor * 2pi)
    ];

    finalSig = SelectX.ar(\type.kr(1!2) * (waves.size - 1), waves);

    // Apply pow and bipow
    shapedSig = finalSig.sign * (finalSig.abs ** bipow);
    shapedSig = shapedSig.sign * (shapedSig.abs ** pow);

    finalSig = shapedSig * (\levels.kr(1!2, 1/30, fixedLag: true));

    Out.ar(out, finalSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

// Make sure the SynthDef is already loaded on the server

// Function to create synth and plot Lissajous figure in real-time
~plotRealtimeLissajous = {
    var synth, scope;

    // Create the synth
    synth = Synth(\lissajous2, [
        out: 0,
        pitch: [60, 65],  // Adjust frequencies for interesting Lissajous patterns
        type: [0, 1],     // Different waveforms for X and Y
        pow: 0,
        bipow: 0,
        levels: 1
    ]);

    // Create a real-time scope
    scope = Stethoscope.new(Server.default, 2, view: Window.new("Lissajous Figure", Rect(200, 200, 500, 500)).front);

    // Configure the scope for XY (Lissajous) mode
    scope.style = 2;  // 2 is XY mode
    scope.xZoom = 5;  // Adjust zoom levels as needed
    scope.yZoom = 5;

    // Return the synth and scope for later manipulation or cleanup
    [synth, scope]
};

// Run the plotting function
~synth_and_scope = ~plotRealtimeLissajous.value;

// You can now manipulate the synth in real-time
~synth_and_scope[0].set(\pitch, [44, 58]);
~synth_and_scope[0].set(\type, [0.75, 0.75]);
~synth_and_scope[0].set(\pow, [0, -0.0]);
~synth_and_scope[0].set(\bipow, [0.0, -0.0]);

// To stop and clean up
~synth_and_scope[0].free;  // Free the synth
~synth_and_scope[1].free;  // Close the scope window

