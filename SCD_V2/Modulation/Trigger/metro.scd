~synthCreator.value("Metro", {|n|
    var hz, reset, chance, duplicate;
    var resetTrig, phase, trig, signal;

    // ————— 1) parameters —————
    hz = OceanodeParameterLag.ar(
        \hz, 1, n,       // name, channels
        0.01, 60,        // min/max (Hz)
        "vf", 1/30,      // type=“float”, default=1/30 (≈0.033Hz)
        true             // lag enabled
    );

    // Use Ar-rate here only so we can turn it into a Kr trigger below.
    // “vi” means integer; when you click it, it jumps 0→1 for exactly one control‐cycle.
    reset = OceanodeParameter.ar(
        \reset, 0, n,    // name, default=0, channels
        0, 1,            // min/max
        "vi"             // integer (i.e. a bang)
    );

    chance = OceanodeParameter.ar(
        \chance, 1, n,   // default = 1 (always pass)
        0, 1,            // min/max
        "vf"             // float
    );

    duplicate = OceanodeParameterDropdown.kr(
        \duplicate, 0, n,
        "Individual:Shared"
    );

    // ————— 2) turn “reset” into a single‐sample control trigger —————
    // Trig.kr sees the control‐rate param flip from ≤0 to >0, and makes one sample‐long gate.
    resetTrig = Trig.kr(reset, SampleDur.ir);

    // ————— 3) build a Phasor that resets its phase whenever resetTrig fires —————
    // increment = hz / SampleRate => one full cycle takes exactly (SampleRate/hz) samples.
    phase = Phasor.ar(
        resetTrig,           // reset gate: forces phase back to “start” (=0)
        hz / SampleRate.ir,   // how much phase advances each sample
        0,                    // phase start
        1                     // phase end “wrap” (Phasor goes 0→1, then jumps back to 0)
    );

    // When phase < incr, that means we’re in the first sample of each new cycle.
    // That single‐sample window is our “trig”.
    trig = (phase < (hz / SampleRate.ir));

    // ————— 4) apply your probabilistic “chance” and “duplicate” logic —————
    signal = Select.ar(duplicate, [
        // Individual mode: each channel gets its own random draw
        trig * (TRand.ar(0.0, 1.0, trig) < chance.at(0)),

        // Shared mode: one random draw, duped to all channels
        trig * (TRand.ar(0.0, 1.0, trig).at(0) < chance.at(0)).dup(n)
    ]);

    // ————— 5) output —————
    Out.ar(OceanodeOutput.kr(\out), signal);
},
description: "Metro trigger generator with an immediately‐resettable Phasor",
category: "Modulation/Trigger");
