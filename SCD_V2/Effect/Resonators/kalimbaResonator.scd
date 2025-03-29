(
~synthCreator.value("KalimbaResonator", {|n|
    var pitch, level, lo, mid, hi, resoMix;
    var sig, input, send, mix;
    var snd, resonators, resonatorFreqs, resonatorAmps, resonatorDecays;
    var chanInput, wet, basicTone;

    // Parameters with lag for smooth transitions
    pitch = OceanodeParameter.kr(\pitch, 60, n, 0, 130, "vf").midicps;
    level = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    lo = OceanodeParameter.kr(\lo, 0.8, n, 0, 1, "vf");
    mid = OceanodeParameter.kr(\mid, 0.05, n, 0, 1, "vf");
    hi = OceanodeParameter.kr(\hi, 0.07, n, 0, 1, "vf");
    resoMix = OceanodeParameter.kr(\resomix, 0.1, n, 0, 1, "vf");
    
    // Mix and send parameters
    mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
    send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Input signal
    input = In.ar(OceanodeInput.kr(\in), n);

    // Generate signal for each channel
    snd = n.collect({ |chan|
        chanInput = input[chan] * send[chan];
        
        // Basic tone based on input
        basicTone = SinOsc.ar(pitch[chan]) * chanInput;

        // Resonators
        resonatorFreqs = [(pitch[chan]/2)*0.95, (pitch[chan]*5)*1.0, (pitch[chan]*8)*1.05];
        resonatorAmps = [-7.dbamp, 0.dbamp, 3.dbamp];
        resonatorDecays = [lo[chan], mid[chan], hi[chan]];
        resonators = DynKlank.ar(`[resonatorFreqs, resonatorAmps, resonatorDecays], chanInput);

        // Correct mix between basic tone and resonators
        wet = ((resonators*(1-resoMix[chan]))+(basicTone*resoMix[chan])) * level[chan] * 0.2;
        
        // Mix dry and wet signals
        XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
    });

    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), snd);

}, description: "Kalimba resonator effect that applies kalimba-like resonances to input audio", category: "Effect/Resonators");
)