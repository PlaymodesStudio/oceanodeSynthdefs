~synthCreator.value("ChannelRepeat", {|n|
    var inBus, in, repeat, out;

    // Oceanode-style bus input
    inBus = OceanodeInput.kr(\in);
    in    = In.ar(inBus, n);

    // Runtime repeat factor (1..64)
    repeat = OceanodeParameter.kr(\repeat, 2, 1, 1, 64, "i").max(1);

    // out[i] = in[floor(i / repeat)]
    out = Array.fill(n, { |i|
        var idx = (i / repeat).floor.clip(0, n-1);
        Select.ar(idx, in)
    });

    // Output the signals
    Out.ar(OceanodeOutput.kr(\out), out);
}, description: "Repeat each input channel across multiple output channels", category: "Routing");
