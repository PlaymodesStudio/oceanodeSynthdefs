(
~synthCreator.value("FMFormant", {|n|
    var amp, k, formants, bufnum, offset5, freqs, bws, amps;
    var vibrato, mod, quotient, xfades, evenCar, oddCar, sig;
    var vowel, freq, index, vibratoSpeed, vibratoDepth;
    
    // Main parameters with lag for smooth transitions
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    vowel = OceanodeParameterLag.ar(\vowel, 0, n, 0, 3.9999, "vf", 1/30, true);
    index = OceanodeParameterLag.ar(\fmindex, 1.44, n, 0.001, 32, "vf", 1/30, true);
    vibratoSpeed = OceanodeParameterLag.ar(\vibf, 6, n, 0.1, 16, "vf", 1/30, true);
    vibratoDepth = OceanodeParameterLag.ar(\viba, 4, n, 0.1, 16, "vf", 1/30, true);
    
    // Collect formant data for vowels
    k = "IEAOU".collectAs({ |chr| ("tenor" ++ chr).asSymbol }, Array);
    formants = k.collect { |id| FormantTable.at(id) };
    formants = formants.flop.collect(_.flop).flat;
    bufnum = LocalBuf(75, 1).set(formants);
    
    // Apply vibrato to frequency
    vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
    freq = freq + vibrato;
    
    offset5 = Array.series(5, 0, 5);
    
    // Generate the FM formant synthesis
    sig = n.collect { |i|
        var ch_freqs = BufRd.kr(1, bufnum, vowel + offset5, loop: 0);
        var ch_bws = BufRd.kr(1, bufnum, vowel + (offset5 + 25), loop: 0);
        var ch_amps = BufRd.kr(1, bufnum, vowel + (offset5 + 50), loop: 0);
        
        mod = SinOsc.ar(freq);
        mod = mod * index * ch_bws;
        
        quotient = ch_freqs / freq;
        xfades = quotient.fold(0, 1);
        evenCar = SinOsc.ar(quotient.round(2) * freq, mod);
        oddCar = SinOsc.ar(((quotient + 1).round(2) - 1) * freq, mod);
        
        XFade2.ar(evenCar, oddCar, xfades * 2 - 1, ch_amps).sum * amp;
    };
    
    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "FM-based formant synthesizer with vowel control", category: "Source/Formants");
)