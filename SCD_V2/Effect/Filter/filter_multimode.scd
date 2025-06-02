(
~synthCreator.value("MultimodeFilter", {|n|
    var input, filtered, freq, res, filterType, drywet;
    // Get input from source
    input = In.ar(OceanodeInput.kr(\in), n);
    // Control parameters
    freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 127, "vf", 0.05, true).midicps;
    res = 1-(OceanodeParameterLag.ar(\q, 0, n, 0, 0.99999, "vf"));
    filterType = OceanodeParameterDropdown.ar(\type, 0, n, "LowPass:HighPass:BandPass:BandReject:PeakEQ:Moog:Resonator:Formant");
    // Use Select.ar with integer filter type to conditionally process only the selected filter
    filtered = Select.ar(filterType, [
        RLPF.ar(input, freq, res),              // Resonant Low Pass Filter
        RHPF.ar(input, freq, res),              // Resonant High Pass Filter
        BPF.ar(input, freq, res),               // Band Pass Filter
        BRF.ar(input, freq, res),               // Band Reject Filter
        BPeakEQ.ar(input, freq, 1, res * 12),   // Peak EQ
        MoogFF.ar(input, freq, (1-res) * 4),    // Moog Filter
        Resonz.ar(input, freq, res),            // Resonator
        Formlet.ar(input, freq, 0.005, (1-res) * 0.1) // Formant Filter
    ]);

    // Use XFade2 for equal-power crossfading between dry and wet signals
    // XFade2 expects a pan value from -1 to 1, so map drywet from 0-1 to -1 to 1
    drywet = OceanodeParameterLag.ar(\drywet, 1, n, 0, 1, "vf", 1/30, true);
    filtered = XFade2.ar(input, filtered, drywet.linlin(0, 1, -1, 1));

    // Output filtered signal
    Out.ar(OceanodeOutput.kr(\out), filtered);
}, description: "Multimode filter with various filter types", category: "Effect/Filter");
)