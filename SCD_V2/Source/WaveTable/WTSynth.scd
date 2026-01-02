(
~synthCreator.value("WTSynth", {|n|
    var buf, pos, amp, freq, sig;

    // Parameters
    buf = OceanodeParameter.ar(\bufnum, 0, n, 0, 100, "vi");
    pos = OceanodeParameterLag.ar(\wtpos8, 0, n, 0, 7, "vf", 1/30, true);
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);

    // Convert MIDI note to frequency ratio (2^((note-38)/12))
    freq = 2.pow((freq - 38) / 12);

    // Process each channel individually
    sig = n.collect { |i|
        var chan_sig;
        var chan_buf = buf[i];
        var chan_pos = pos[i];
        var chan_freq = freq[i];
        var chan_amp = amp[i];

        // Create 8 buffer players
        var sig1 = PlayBuf.ar(1, chan_buf, chan_freq, 1, 0, 1);
        var sig2 = PlayBuf.ar(1, chan_buf + 1, chan_freq, 1, 0, 1);
        var sig3 = PlayBuf.ar(1, chan_buf + 2, chan_freq, 1, 0, 1);
        var sig4 = PlayBuf.ar(1, chan_buf + 3, chan_freq, 1, 0, 1);
        var sig5 = PlayBuf.ar(1, chan_buf + 4, chan_freq, 1, 0, 1);
        var sig6 = PlayBuf.ar(1, chan_buf + 5, chan_freq, 1, 0, 1);
        var sig7 = PlayBuf.ar(1, chan_buf + 6, chan_freq, 1, 0, 1);
        var sig8 = PlayBuf.ar(1, chan_buf + 7, chan_freq, 1, 0, 1);

        // Crossfade between wavetables based on position
        chan_sig = SelectX.ar(
            chan_pos,
            [sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8]
        );

        // Apply amplitude
        chan_sig * chan_amp;
    };

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Advanced wavetable oscillator with 8 buffer interpolation", category: "Source/Wavetable");
)