// wavetable.scd
(
~synthCreator.value("Wavetable", {|n|
    var pitch, freq, wtpos, phase, detune, levels;
    var sig, bufLoc, chanLoc, numChans, oversample;
    var soundBuf, freqs, spreadAmts, detunedFreqs, detunedChanLocs;
    var voices, i;

    // Get buffer from input
    soundBuf = OceanodeBuffer.kr(\soundbuf);

    // Get number of channels from buffer (passed as parameter from scWavetableBuffer)
    numChans = \numchans.kr(1);

    // Parameters
    pitch = OceanodeParameterLag.ar(\pitch, 60, n, 0, 127, "vf", 1/30, true);
    wtpos = OceanodeParameterLag.ar(\wtpos, 0, n, 0, 1, "vf", 1/30, true);
    phase = OceanodeParameter.ar(\phase, 0, n, 0, 1, "vf");
    detune = OceanodeParameter.ar(\detune, 0, n, 0, 1, "vf");
    levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
    oversample = OceanodeParameterDropdown.kr(\oversample, 1, n, "None:2x:4x:8x:16x");

    // Calculate frequency from MIDI pitch
    freq = pitch.midicps;

    // Wavetable position (0-1) controls buf_loc
    bufLoc = wtpos;

    // Auto-calculate channel location based on frequency for anti-aliasing
    chanLoc = freq.abs.explin(20, SampleRate.ir/2, 0, numChans-1).clip(0, numChans-1) / numChans;

    // Create array of frequencies with detune spread
    freqs = freq.asArray;

    // Calculate detune spread for each voice
    spreadAmts = Array.fill(n, {|i|
        if(n > 1,
            (i / (n-1) * 2 - 1) * detune,  // Spread from -detune to +detune
            0
        );
    });

    // Apply detune (±1 semitone max)
    detunedFreqs = freqs * (2 ** (spreadAmts / 12));

    // Calculate channel location for each detuned frequency
    detunedChanLocs = detunedFreqs.abs.explin(20, SampleRate.ir/2, 0, numChans-1).clip(0, numChans-1) / numChans;

    // Create voices
    sig = OscOS3.ar(
        soundBuf,          // sound_buf
        -1,                // phase_buf (-1 = use internal sawtooth)
        detunedFreqs,      // freq (array of detuned frequencies)
        phase,             // phase
        0,                 // sync_trig
        256,               // buf_divs (standard Vital/Serum)
        bufLoc,            // buf_loc (wavetable position)
        numChans,          // num_chans
        detunedChanLocs,   // chan_loc (auto mipmap selection per voice)
        -1,                // phase_buf_divs (not used)
        0,                 // phase_buf_loc (not used)
        oversample         // oversample
    );

    // Apply level
    sig = sig * levels;

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Wavetable oscillator with morphing", category: "Source/Wavetable");
)