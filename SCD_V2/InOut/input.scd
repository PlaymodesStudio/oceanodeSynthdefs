(
~synthCreator.value("Input", {|n, variables|
    var startChan, inputSignal, gain;

    // Start channel parameter
    startChan = OceanodeParameter.kr(\chan, 0, 1, 0, 48, "i");

    // Gain parameter with lag for smooth level changes
    gain = OceanodeParameterLag.ar(\gain, 1, 1, 0, 2, "vf", 1/30, true);

    // Create array of consecutive channel indices
    inputSignal = Array.fill(n, {|i|
        SoundIn.ar(startChan + i);
    });

    // Apply signal conditioning
    inputSignal = LeakDC.ar(Limiter.ar(Sanitize.ar(inputSignal)));

    // Apply gain
    inputSignal = inputSignal * gain;

    // Output to bus
    Out.ar(OceanodeOutput.kr(\out), inputSignal);

}, description: "Captures audio from system inputs", category: "InOut");
)