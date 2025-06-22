~synthCreator.value("Metro", {|n|
    var hz, reset, chance, duplicate, seed, reseed;
    var resetTrig, phase, trig, signal, normalChanceRand, seededChanceRand, instanceID, combinedReset;

    // ————— 1) parameters —————
    hz = OceanodeParameterLag.ar(
        \hz, 1, n,       // name, channels
        0.01, 60,        // min/max (Hz)
        "vf", 1/30,      // type="float", default=1/30 (≈0.033Hz)
        true             // lag enabled
    );

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

    seed = OceanodeParameter.kr(\seed, 0, 1, 0, 65536, "i"); // Single seed for all channels
    reseed = OceanodeParameter.ar(\reseed, 0, n, 0, 1, "vi").asArray.collect{|x| x > 0.5};

    // Create a unique instance ID using current time and random
    instanceID = (Date.localtime.rawSeconds * 1000 + 1000.rand).asInteger;

    // ————— 2) Combine reset and reseed - reseed forces a reset for timing sync —————
    // Fix: Handle arrays properly and convert to sum
    combinedReset = Trig.kr(
        A2K.kr(reset.asArray.sum) + A2K.kr(reseed.asArray.sum > 0), // Convert both to arrays first
        SampleDur.ir
    );

    // ————— 3) build a Phasor that resets its phase whenever combinedReset fires —————
    phase = Phasor.ar(
        K2A.ar(combinedReset),   // reset gate: forces phase back to "start" (=0)
        hz / SampleRate.ir,      // how much phase advances each sample
        0,                       // phase start
        1                        // phase end "wrap" (Phasor goes 0→1, then jumps back to 0)
    );

    // When phase < incr, that means we're in the first sample of each new cycle.
    trig = (phase < (hz / SampleRate.ir));

    // ————— 4) Generate normal random (truly random, each synth gets unique generator) —————
    normalChanceRand = Array.fill(n, {|i|
        // Use instance ID for unseeded mode to ensure different synths are different
        RandID.ir(instanceID + (i * 1000));
        TRand.ar(0.0, 1.0, trig.asArray[i]);
    });

    // ————— 5) Generate seeded random for chance - use seed + channel index —————
    seededChanceRand = Array.fill(n, {|i|
        // Use seed + channel index as random ID for related but different sequences per channel
        RandID.ir(seed + i); // Each channel gets seed+0, seed+1, seed+2, etc.
        // Reseed when seed changes OR when any reseed is triggered (synced with reset)
        RandSeed.kr(
            (seed > 0) * (Changed.kr(seed) + (reseed.asArray.sum > 0) + Impulse.kr(0)),
            (seed + i).max(1)
        );
        TRand.ar(0.0, 1.0, trig.asArray[i]);
    });

    // ————— 6) apply probabilistic "chance" and "duplicate" logic with seeding —————
    signal = Select.ar(duplicate, [
        // Individual mode: each channel gets its own random draw
        Array.fill(n, {|i|
            var chanceRand = Select.ar(
                (seed > 0), // If seed > 0, use seeded, else normal
                [normalChanceRand[i], seededChanceRand[i]]
            );
            trig.asArray[i] * (chanceRand < chance.asArray[i]);
        }),

        // Shared mode: one random draw, duped to all channels
        {
            var chanceRand = Select.ar(
                (seed > 0),
                [normalChanceRand[0], seededChanceRand[0]]
            );
            (trig.asArray[0] * (chanceRand < chance.asArray[0])).dup(n);
        }.value
    ]);

    // ————— 7) output —————
    Out.ar(OceanodeOutput.kr(\out), signal);
},
description: "Metro trigger generator with synchronized reset and reseed for consistent timing",
category: "Modulation/Trigger");