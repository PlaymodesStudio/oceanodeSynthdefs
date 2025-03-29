(
~synthCreator.value("FDNReverb", {|n|
    var input, output, delayTimes, delays, feedback, temp;
    var feedbackAmount, damping, mix, lpf, hpf;
    
    // Control parameters
    feedbackAmount = OceanodeParameterLag.ar(\feedback, 0.5, n, 0, 0.99, "vf", 1/30, true);
    damping = OceanodeParameterLag.ar(\damping, 0.1, n, 0, 1, "vf", 1/30, true);
    mix = OceanodeParameterLag.ar(\mix, 0.33, n, 0, 1, "vf", 1/30, true);
    lpf = OceanodeParameterLag.ar(\lowpass, 10000, n, 100, 20000, "vf", 1/30, true);
    hpf = OceanodeParameterLag.ar(\hipass, 20, n, 10, 5000, "vf", 1/30, true);
    
    // Input signal
    input = In.ar(OceanodeInput.kr(\in), n);
    
    // Process each channel individually
    output = n.collect { |i|
        var chan_input = input[i];
        var chan_feedback, chan_delays, chan_output;
        
        // Create unique delay times for this channel
        delayTimes = {Rand(0.01, 0.1)}!4;
        
        // Initial delays
        chan_delays = DelayC.ar(chan_input, 0.2, delayTimes);
        chan_feedback = Rotate2.ar(chan_delays[0], chan_delays[1], 0.23);
        chan_feedback = Rotate2.ar(chan_feedback[0], chan_delays[2], 0.23);
        chan_feedback = Rotate2.ar(chan_feedback[0], chan_delays[3], 0.23);
        
        // Feedback network
        16.do {
            temp = DelayC.ar(chan_feedback, 0.2, delayTimes);
            chan_feedback = (temp * feedbackAmount[i]) + (chan_input * 0.125);
            chan_feedback = Rotate2.ar(chan_feedback[0], chan_feedback[1], 0.23);
            chan_feedback = Rotate2.ar(chan_feedback[0], chan_feedback[1], 0.23);
        };
        
        // Apply filters
        chan_feedback = LPF.ar(chan_feedback, (1 - damping[i]) * 10000 + 1000); // Damping
        chan_feedback = LPF.ar(chan_feedback, lpf[i]); // User-controlled LPF
        chan_feedback = HPF.ar(chan_feedback, hpf[i]); // User-controlled HPF
        
        // Mix and output
        chan_output = Mix(chan_feedback) * 0.25;
        chan_output = LeakDC.ar(chan_output);
        
        // Mix dry and wet signals
        XFade2.ar(chan_input, chan_output, mix[i] * 2 - 1);
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), output);
    
}, description: "Feedback delay network reverb with rotating matrix", category: "Effect/Time/Reverb");
)