/*
Based on the example at
http://www.mcld.co.uk/cymbalsynthesis/
published 2008 by Dan Stowell

*/


(
SynthDef(\cymbalpad13, {
    arg out = 0;

    // Named controls with multichannel expansion (13 channels)
    var locut = \locut.kr(20000!13);  // Low cut frequency for each channel
    var hicut = \hicut.kr(10000!13);  // High cut frequency for each channel
    var hi = \hi.kr(1!13);            // High frequency driver level for each channel
    var lo = \lo.kr(1!13);            // Low frequency driver level for each channel
    var level = \level.kr(0.1!13);    // Amplitude level for each channel

    var lodriver, hidriver, freqs, res, sig;

    // Process each channel
    sig = Array.fill(13, {|i|
        var channelSig;

        // Low and high frequency drivers
        lodriver = LPF.ar(WhiteNoise.ar(0.1), locut[i]);
        hidriver = HPF.ar(WhiteNoise.ar(0.1), hicut[i]);

        // Frequency array for resonators
        freqs = {exprand(300, 20000)}.dup(100);

        // Resonator processing
        res = Ringz.ar((lodriver * lo[i]) + (hidriver * hi[i]), freqs).mean;

        // Mix low and high frequency drivers with resonator output
        channelSig = ((res * 1) + (lodriver * lo[i] * 2));

        // Apply level control to the channel
        channelSig * level[i];
    });

    // Output each channel separately
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

