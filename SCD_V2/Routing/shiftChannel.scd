(
~synthCreator.value("ShiftChannels", {|n|
    var signals, shiftedSignals, shift;

    // Get input signals
    signals = In.ar(OceanodeInput.kr(\in), n);

    // Get shift amount (normalized 0-1 value that scales to n channels)
    shift = OceanodeParameter.ar(\shift, 0, 1, 0, 1, "vf") * n;

    // Create shifted signals
    shiftedSignals = Array.fill(n, { |i|
        var baseIndex, nextIndex, frac, signal1, signal2, mixSig;

        // Calculate indices with wrap-around
        baseIndex = (i + shift.floor).mod(n);
        nextIndex = (baseIndex + 1).mod(n);

        // Calculate fractional part for crossfading
        frac = shift - shift.floor;

        // Use Select.ar to get signals at calculated indices
        signal1 = Select.ar(baseIndex, signals);
        signal2 = Select.ar(nextIndex, signals);

        // Crossfade between the two signals
        mixSig = XFade2.ar(signal1, signal2, frac * 2 - 1);
        mixSig;
    });

    // Output the shifted signals
    Out.ar(OceanodeOutput.kr(\out), shiftedSignals);
}, description: "Continuously shift audio channels using interpolation", category: "Routing");
)