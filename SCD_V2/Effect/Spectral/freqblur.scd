(
~synthCreator.value("FrequencyBlur", {|n|
    var signal, chain, blurred, result;
    var amount, spread, level, mix;
    var i, localChain, fftbuf;

    // Parameters
    amount = OceanodeParameter.ar(\amount, 0.5, n, 0, 1, "vf");
    spread = OceanodeParameter.ar(\spread, 0.5, n, 0.01, 1, "vf");
    level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");

    // Input signal
    signal = In.ar(OceanodeInput.kr(\in), n);

    // FFT processing
    chain = Array.fill(n, {|idx|
        fftbuf = LocalBuf(2048);
        localChain = FFT(fftbuf, signal[idx]);

        // Apply frequency domain blurring
        localChain = PV_MagSmear(localChain, spread * 100);
        localChain = PV_Diffuser(localChain, amount > LFNoise2.kr(0.2).range(0, 1));

        // Convert back to time domain
        IFFT(localChain);
    });

    // Combine channels if multichannel
    blurred = if(n > 1, {
        chain;
    }, {
        chain[0];
    });

    // Mix between dry and wet signals
    result = XFade2.ar(signal, blurred, mix * 2 - 1);

    // Apply level control
    result = result * level;

    Out.ar(OceanodeOutput.kr(\out), result);
}, description: "Blurs the frequency content of audio", category: "Effect/Spectral");
)