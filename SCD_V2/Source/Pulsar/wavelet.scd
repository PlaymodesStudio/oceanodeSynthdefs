~synthCreator.value("Wavelet", {|n|
    var sig, shape, duration, trigger;
    var phase, wavelet, running;
    var minVal, maxVal, range;
    var triggerPulse;

    // Parameters
    trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");  // Changed to .ar
    duration = OceanodeParameterLag.ar(\duration, 50, n, 1, 200, "vf", 1/30, true);  // Duration in ms
    shape = OceanodeParameterLag.ar(\shape, 0.5, n, 0, 1, "vf", 1/30, true);         // 0: steep, 0.5: bell, 1: square
    minVal = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);          // Minimum value in range
    maxVal = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);           // Maximum value in range

    // Convert duration from ms to seconds
    duration = duration * 0.001;

    // Create a trigger pulse from level changes (0->1) at audio rate
    triggerPulse = Trig.ar(trigger, 0.001);

    // Create a ramp that goes from 0 to 1 over the duration
    phase = Sweep.ar(triggerPulse, 1/duration);

    // Detect when we're in an active cycle
    running = (phase < 1);

    // Latch the running state at audio rate
    running = Latch.ar(running, running);

    // Apply the latch to the phase - keep it at 1 when cycle is complete
    phase = phase.clip(0, 1);

    // Simple wavelet generation based on shape parameter
    wavelet = Select.ar(
        (shape * 10).clip(0, 9).round, // 10 discrete shapes, 0-9
        // Array of 10 different wavelet shapes from steep to square
        [
            // Shape 0: Very steep power curve (exponent 10)
            (phase < 0.5) * (phase * 2).pow(10) +
            (phase >= 0.5) * (1 - ((phase - 0.5) * 2)).pow(10),
            // Shape 1: Steep power curve (exponent 6)
            (phase < 0.5) * (phase * 2).pow(6) +
            (phase >= 0.5) * (1 - ((phase - 0.5) * 2)).pow(6),
            // Shape 2: Medium-steep power curve (exponent 4)
            (phase < 0.5) * (phase * 2).pow(4) +
            (phase >= 0.5) * (1 - ((phase - 0.5) * 2)).pow(4),
            // Shape 3: Gentle power curve (exponent 3)
            (phase < 0.5) * (phase * 2).pow(3) +
            (phase >= 0.5) * (1 - ((phase - 0.5) * 2)).pow(3),
            // Shape 4: Quadratic curve (power 2)
            (phase < 0.5) * (phase * 2).pow(2) +
            (phase >= 0.5) * (1 - ((phase - 0.5) * 2)).pow(2),
            // Shape 5: Bell curve (sine based)
            sin(phase * pi),
            // Shape 6: Blend of sine and trapezoid
            (phase < 0.3) * (phase / 0.3) +
            (phase >= 0.3) * (phase <= 0.7) * 1 +
            (phase > 0.7) * (1 - ((phase - 0.7) / 0.3)),
            // Shape 7: Trapezoid with steeper sides
            (phase < 0.2) * (phase / 0.2) +
            (phase >= 0.2) * (phase <= 0.8) * 1 +
            (phase > 0.8) * (1 - ((phase - 0.8) / 0.2)),
            // Shape 8: Near-square (trapezoid with very steep sides)
            (phase < 0.1) * (phase / 0.1) +
            (phase >= 0.1) * (phase <= 0.9) * 1 +
            (phase > 0.9) * (1 - ((phase - 0.9) / 0.1)),
            // Shape 9: Square-like (trapezoid with extremely steep sides)
            (phase < 0.05) * (phase / 0.05) +
            (phase >= 0.05) * (phase <= 0.95) * 1 +
            (phase > 0.95) * (1 - ((phase - 0.95) / 0.05))
        ]
    );

    // Gate the wavelet so it only outputs during the ramp
    wavelet = wavelet * running;

    // Adjust amplitude with natural curve
    sig = wavelet * OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Scale normalized signal (0-1) to the requested min-max range
    range = maxVal - minVal;
    sig = (sig * range) + minVal;

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Generates a single cycle wavelet with variable shape and amplitude range", category: "Source/Pulsar");