(
SynthDef(\brassmodel, {
    arg out=0;
    var lipFreq, lipTension, airPressure, tubeLength, brightness;
    var lipOsc, tubeResonance, tubeFilter, radiation, signal;

    // Control parameters with smoothing
    lipFreq = \pitch.kr(0, 1/30, fixedLag:true).midicps; // Base frequency
    lipTension = \tension.kr(0.61, 1/30, fixedLag:true).linexp(0, 1, 0.5, 4); // Lip tension
    airPressure = \pressure.kr(0.486, 1/30, fixedLag:true).linexp(0, 1, 0.1, 2); // Breath pressure
    tubeLength = \tubelength.kr(0.410, 1/30, fixedLag:true).linlin(0, 1, 0.5, 1.5); // Adjusts tube length
    brightness = \brightness.kr(0.95, 1/30, fixedLag:true); // Tone color

    // Lip model - self-oscillating system using feedback
    lipOsc = SinOscFB.ar(
        lipFreq * lipTension,
        airPressure * 2,
        airPressure
    );

    // Basic waveguide model for the tube resonance
    tubeResonance = CombL.ar(
        lipOsc,
        0.1,  // Max delay time
        1 / (lipFreq * tubeLength), // Actual delay time based on pitch
        3 * airPressure // Decay time varies with pressure
    );

    // Tube filtering - brass instruments act as lowpass filters
    tubeFilter = RLPF.ar(
        tubeResonance,
        lipFreq * (2 + (brightness * 6)), // Cutoff frequency
        0.3 + (0.6 * brightness) // Resonance
    );

    // Model radiation characteristics and horn effect
    radiation = HPF.ar(tubeFilter, 200); // High-pass to model radiation
    radiation = radiation + (radiation.clip2(0.1) * brightness); // Add subtle nonlinear brightness

    // Apply final shaping and level control
    signal = radiation * \levels.kr(0.5, 1/30, fixedLag:true);

    // Output
    Out.ar(out, signal);
}).play();
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\brass13, {
    arg out=0;
    var lipFreq, lipTension, airPressure, tubeLength, brightness;
    var lipOsc, tubeResonance, tubeFilter, radiation, signal;

    // Control parameters with multichannel expansion (13 channels)
    lipFreq = \pitch.kr(30!13, 1/30, fixedLag:true).midicps; // Base frequency array
    lipTension = \tension.kr(0.31!13, 1/30, fixedLag:true).linexp(0, 1, 0.5, 4); // Lip tension array
    airPressure = \pressure.kr(0.586!13, 1/30, fixedLag:true).linexp(0, 1, 0.1, 2); // Breath pressure array
    tubeLength = \tubelength.kr(1.10!13, 1/30, fixedLag:true).linlin(0, 1, 0.5, 1.5); // Tube length array
    brightness = \brightness.kr(0.95!13, 1/30, fixedLag:true); // Tone color array

    // Lip model - self-oscillating system using feedback
    lipOsc = SinOscFB.ar(
        lipFreq * lipTension,
        airPressure * 2,
        airPressure
    );

    // Basic waveguide model for the tube resonance
    tubeResonance = CombL.ar(
        lipOsc,
        0.1,  // Max delay time
        1 / (lipFreq * tubeLength), // Actual delay time based on pitch
        3 * airPressure // Decay time varies with pressure
    );

    // Tube filtering - brass instruments act as lowpass filters
    tubeFilter = RLPF.ar(
        tubeResonance,
        lipFreq * (2 + (brightness * 6)), // Cutoff frequency
        0.3 + (0.6 * brightness) // Resonance
    );

    // Model radiation characteristics and horn effect
    radiation = HPF.ar(tubeFilter, 200); // High-pass to model radiation
    radiation = radiation + (radiation.clip2(0.1) * brightness); // Add subtle nonlinear brightness

    // Apply final shaping and level control
    signal = radiation * \levels.kr(0.5!13, 1/30, fixedLag:true);

    // Output
    Out.ar(out, signal);
}).writeDefFile(d);
)