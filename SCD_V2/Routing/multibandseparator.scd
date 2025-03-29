(
~synthCreator.value("MultibandSeparator", {|n|
    var input, low, mid, high, lowFreq, highFreq;

    // Get input signal
    input = In.ar(OceanodeInput.kr(\in), n);
    input = LeakDC.ar(input);

    // Crossover frequency parameters
    lowFreq = OceanodeParameterLag.ar(\lowfreq, 300, n, 20, 1000, "vf", 1/30, true);
    highFreq = OceanodeParameterLag.ar(\highfreq, 3200, n, 1000, 8000, "vf", 1/30, true);

    // Split the signal into three bands using nested LPF/HPF for steeper rolloff
    low = LPF.ar(LPF.ar(input, lowFreq), lowFreq);

    // Mid band - bandpass using HPF and LPF
    mid = HPF.ar(HPF.ar(input, lowFreq), lowFreq);
    mid = LPF.ar(LPF.ar(mid, highFreq), highFreq);

    // High band
    high = HPF.ar(HPF.ar(input, highFreq), highFreq);

    // Apply level controls with natural curve
    low = low * OceanodeParameterLag.ar(\lowlevel, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    mid = mid * OceanodeParameterLag.ar(\midlevel, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    high = high * OceanodeParameterLag.ar(\highlevel, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Output each band to its own output bus
    Out.ar(OceanodeOutput.kr(\lowout), low);
    Out.ar(OceanodeOutput.kr(\midout), mid);
    Out.ar(OceanodeOutput.kr(\highout), high);

}, description: "Separates audio into low mid and high frequency bands", category: "Routing");
)