(
~synthCreator.value("SamplerSync", {|n|
    var t, rates, rate, ratefreq, freq, freqs, ratenorm, signal, fq, buf, bucle, start, end, gain, ph, offset, segdur, playmode, loopmodes;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
    fq = OceanodeParameter.kr(\freq, 1, n, 0.1, 10, "vf");
    bucle = OceanodeParameter.kr(\loop, 0, n, 0, 1, "vi");
    start = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf") * BufFrames.kr(buf);
    end = OceanodeParameter.ar(\endpos, 1, n, 0, 1, "vf") * BufFrames.kr(buf);
    offset = OceanodeParameter.ar(\offset, 0, n, -1, 1, "vf");
    playmode = OceanodeParameterDropdown.kr(\playmode, 0, n, "Frequency-based:Sample-rate-based");
    
    // Calculate timing parameters
    segdur = (end - start) / SampleRate.ir;
    ratefreq = (end - start) * fq / SampleRate.ir;
    ratenorm = BufRateScale.kr(buf) * fq;
    
    // Define rate options based on play mode
    rates = [
        ratefreq,    // Frequency-based rate
        ratenorm     // Sample-rate-based rate
    ];
    
    // Define frequency options based on play mode
    freqs = [
        fq,                  // Direct frequency
        (1.0 / segdur) * fq  // Segment duration-based frequency
    ];
    
    // Select based on play mode
    freq = Select.kr(playmode, freqs);
    rate = Select.kr(playmode, rates);
    offset = offset * (end - start);
    
    // Define loop modes
    loopmodes = [
        Wrap.ar(Sweep.ar(t, freq).linlin(0, 1, start, end) + offset, start, end),
        Wrap.ar(Phasor.ar(t, rate, start, end) + offset, start, end)
    ];
    
    // Select loop mode based on loop parameter
    ph = Select.ar(bucle, loopmodes);
    
    // Read from buffer
    signal = BufRd.ar(1, buf, ph, bucle, 0) * gain;
    
    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Sampler with frequency synchronization capabilities", category: "Source/Sampler");
)