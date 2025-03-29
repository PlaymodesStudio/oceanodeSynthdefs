(
~synthCreator.value("LPF", {|n|
    var input, filtered, dw;
    // Get input from source
    input = In.ar(OceanodeInput.kr(\in), n);
    // Apply high pass filter with frequency control
    filtered = LPF.ar(
        input,
        OceanodeParameterLag.ar(\freq, 1000, n, 20, 20000, "vf", 0.05, true)
    );

    // Get dry/wet parameter
    dw = OceanodeParameterLag.kr(\drywet, 1, n, 0, 1, "vf", 1/30, true);

    // Use XFade2 for equal-power crossfading
    // XFade2 expects a pan parameter from -1 to 1, so map dw from 0-1 to -1 to 1
    filtered = XFade2.ar(input, filtered, dw.linlin(0, 1, -1, 1));

    // Output filtered signal
    Out.ar(OceanodeOutput.kr(\out), filtered);
}, description: "Simple low pass filter", category: "Effect/Filter");
)