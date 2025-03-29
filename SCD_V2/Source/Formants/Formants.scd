(
~synthCreator.value("Formants", {|n|
    var freq, amp, vibratoSpeed, vibratoDepth, vibrato, vowel, in;
    var formantData, snd;
    
    // Control parameters with multichannel expansion
    freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 128, "vf", 1/30, true).midicps;
    amp = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    vibratoSpeed = OceanodeParameterLag.ar(\vibf, 6, n, 0.1, 16, "vf", 1/30, true);
    vibratoDepth = OceanodeParameterLag.ar(\viba, 4, n, 0.1, 16, "vf", 1/30, true);
    vowel = OceanodeParameterLag.ar(\vowel, 0, n, 0, 4, "vf", 1/30, true);
    
    // Generate vibrato and input signal
    vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
    in = Saw.ar(freq + vibrato);
    
    // Define formant data for each vowel (freq, bw, mul)
    formantData = [
        [ // va
            [600, 0.1, 1], [1040, 0.067307692307692, 0.44668359215096],
            [2250, 0.048888888888889, 0.35481338923358], [2450, 0.048979591836735, 0.35481338923358],
            [2750, 0.047272727272727, 0.1]
        ],
        [ // ve
            [400, 0.1, 1], [1620, 0.049382716049383, 0.25118864315096],
            [2400, 0.041666666666667, 0.35481338923358], [2800, 0.042857142857143, 0.25118864315096],
            [3100, 0.038709677419355, 0.12589254117942]
        ],
        [ // vi
            [250, 0.24, 1], [1750, 0.051428571428571, 0.031622776601684],
            [2600, 0.038461538461538, 0.15848931924611], [3050, 0.039344262295082, 0.079432823472428],
            [3340, 0.035928143712575, 0.03981071705535]
        ],
        [ // vo
            [400, 0.1, 1], [750, 0.10666666666667, 0.28183829312645],
            [2400, 0.041666666666667, 0.089125093813375], [2600, 0.046153846153846, 0.1],
            [2900, 0.041379310344828, 0.01]
        ],
        [ // vu
            [350, 0.11428571428571, 1], [600, 0.13333333333333, 0.1],
            [2400, 0.041666666666667, 0.025118864315096], [2675, 0.044859813084112, 0.03981071705535],
            [2950, 0.040677966101695, 0.015848931924611]
        ]
    ];
    
    // Process each channel
    snd = n.collect { |chan|
        var channelIn, channelSnd, formantSet;
        
        channelIn = in[chan];
        formantSet = SelectX.kr(vowel[chan], formantData);
        
        // Apply each formant filter to the input
        channelSnd = formantSet.collect { |formant|
            BBandPass.ar(channelIn, formant[0], formant[1]) * formant[2]
        }.sum;
        
        channelSnd * amp[chan];
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), snd);
    
}, description: "Formant synthesizer with vowel control", category: "Source/Formants");
)