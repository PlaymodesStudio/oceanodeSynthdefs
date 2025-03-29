(
~synthCreator.value("SuperPulse", {|n|

	var pitch = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true),
        mix = OceanodeParameterLag.kr(\mix, 0.75, n, 0, 1, "vf", 1/30, true),
        detune = OceanodeParameterLag.kr(\detune, 0.75, n, 0, 1, "vf", 1/30, true),
        pw = OceanodeParameterLag.ar(\pw, 0.5, n, 0, 1, "vf", 1/30, true),
        levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4),

        // Additional modulation parameters
        tremRate = OceanodeParameterLag.kr(\tremf, 0, n, 0, 8, "vf", 1/30, true),
        tremAmount = OceanodeParameterLag.kr(\trema, 0, n, 0, 1, "vf", 1/30, true),
        vibRate = OceanodeParameterLag.kr(\vibf, 0, n, 0, 8, "vf", 1/30, true),
        vibAmount = OceanodeParameterLag.kr(\viba, 0, n, 0, 1, "vf", 1/30, true),

        // Processing variables
        trem, vib, freq, signals, detuneFactor, center,
        freqs1, freqs2, freqs3, freqs4, freqs5, freqs6, side, sig;

    var detuneCurve, centerGain, sideGain;

    // Apply vibrato and tremolo
    trem = 1 - ((SinOsc.ar(tremRate, 0, 1, 1) / 2) * tremAmount);
    vib = SinOsc.ar(vibRate, 0, vibAmount, 0);
    freq = (pitch + vib).midicps;

    // Detune curve function
    detuneCurve = { |x|
        (10028.7312891634*x.pow(11)) -
        (50818.8652045924*x.pow(10)) +
        (111363.4808729368*x.pow(9)) -
        (138150.6761080548*x.pow(8)) +
        (106649.6679158292*x.pow(7)) -
        (53046.9642751875*x.pow(6)) +
        (17019.9518580080*x.pow(5)) -
        (3425.0836591318*x.pow(4)) +
        (404.2703938388*x.pow(3)) -
        (24.1878824391*x.pow(2)) +
        (0.6717417634*x) +
        0.0030115596
    };

    // Gain functions
    centerGain = { |x| (-0.55366 * x) + 0.99785 };
    sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

    // Let SuperCollider handle the multichannel expansion automatically
    detuneFactor = freq * detuneCurve.(detune);
    center = LFPulse.ar(freq, 0, pw); // Central oscillator - PULSE wave

    freqs1 = freq - (detuneFactor * 0.11002313);
    freqs2 = freq - (detuneFactor * 0.06288439);
    freqs3 = freq - (detuneFactor * 0.01952356);
    freqs4 = freq + (detuneFactor * 0.01991221);
    freqs5 = freq + (detuneFactor * 0.06216538);
    freqs6 = freq + (detuneFactor * 0.10745242);

    // Using PULSE oscillators with pulse width
    side =
        LFPulse.ar(freqs1, Rand(0,2), pw) +
        LFPulse.ar(freqs2, Rand(0,2), pw) +
        LFPulse.ar(freqs3, Rand(0,2), pw) +
        LFPulse.ar(freqs4, Rand(0,2), pw) +
        LFPulse.ar(freqs5, Rand(0,2), pw) +
        LFPulse.ar(freqs6, Rand(0,2), pw);

    sig = (center * centerGain.(mix)) + (side * sideGain.(mix));
    signals = HPF.ar(sig, freq); // Apply high-pass filter

    signals = signals * levels * trem;

    // Output the signals
    Out.ar(OceanodeOutput.kr(\out), signals);
},
description: "Rich detuned superpulse with pulse width vibrato and tremolo modulation", category: "Source/Analog"
);
)