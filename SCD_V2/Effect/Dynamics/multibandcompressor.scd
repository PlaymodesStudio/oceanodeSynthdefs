(
~synthCreator.value("MultiBandCompressor", {|n|
	var sigIn, compressor, bands, comp, freqs, sigs;
    var attack1, attack2, attack3, attack4, attack5;
    var release1, release2, release3, release4, release5;
    var threshold1, threshold2, threshold3, threshold4, threshold5;
    var ratio1, ratio2, ratio3, ratio4, ratio5;
    var gain1, gain2, gain3, gain4, gain5;
    var lowFreq, lowMidFreq, midFreq, highMidFreq;
    var masterGain, mix;

    // Input signal
    sigIn = In.ar(OceanodeInput.kr(\in), n);

    // Crossover frequencies
    lowFreq = OceanodeParameter.kr(\lowfreq, 150, n, 20, 500, "f");
    lowMidFreq = OceanodeParameter.kr(\lowmidfreq, 500, n, 100, 1500, "f");
    midFreq = OceanodeParameter.kr(\midfreq, 1500, n, 500, 5000, "f");
    highMidFreq = OceanodeParameter.kr(\highmidfreq, 5000, n, 2000, 10000, "f");

    // Band 1 (Low) parameters
    attack1 = OceanodeParameter.kr(\lowattack, 0.01, n, 0.001, 0.2, "f");
    release1 = OceanodeParameter.kr(\lowrelease, 0.1, n, 0.01, 0.5, "f");
    threshold1 = OceanodeParameter.kr(\lowthresh, -12, n, -60, 0, "f");
    ratio1 = OceanodeParameter.kr(\lowratio, 4, n, 1, 20, "f");
    gain1 = OceanodeParameter.kr(\lowgain, 1, n, 0, 2, "f");

    // Band 2 (Low-Mid) parameters
    attack2 = OceanodeParameter.kr(\lowmidattack, 0.01, n, 0.001, 0.2, "f");
    release2 = OceanodeParameter.kr(\lowmidrelease, 0.1, n, 0.01, 0.5, "f");
    threshold2 = OceanodeParameter.kr(\lowmidthresh, -12, n, -60, 0, "f");
    ratio2 = OceanodeParameter.kr(\lowmidratio, 4, n, 1, 20, "f");
    gain2 = OceanodeParameter.kr(\lowmidgain, 1, n, 0, 2, "f");

    // Band 3 (Mid) parameters
    attack3 = OceanodeParameter.kr(\midattack, 0.01, n, 0.001, 0.2, "f");
    release3 = OceanodeParameter.kr(\midrelease, 0.1, n, 0.01, 0.5, "f");
    threshold3 = OceanodeParameter.kr(\midthresh, -12, n, -60, 0, "f");
    ratio3 = OceanodeParameter.kr(\midratio, 4, n, 1, 20, "f");
    gain3 = OceanodeParameter.kr(\midgain, 1, n, 0, 2, "f");

    // Band 4 (High-Mid) parameters
    attack4 = OceanodeParameter.kr(\highmidattack, 0.01, n, 0.001, 0.2, "f");
    release4 = OceanodeParameter.kr(\highmidrelease, 0.1, n, 0.01, 0.5, "f");
    threshold4 = OceanodeParameter.kr(\highmidthresh, -12, n, -60, 0, "f");
    ratio4 = OceanodeParameter.kr(\highmidratio, 4, n, 1, 20, "f");
    gain4 = OceanodeParameter.kr(\highmidgain, 1, n, 0, 2, "f");

    // Band 5 (High) parameters
    attack5 = OceanodeParameter.kr(\highattack, 0.01, n, 0.001, 0.2, "f");
    release5 = OceanodeParameter.kr(\highrelease, 0.1, n, 0.01, 0.5, "f");
    threshold5 = OceanodeParameter.kr(\highthresh, -12, n, -60, 0, "f");
    ratio5 = OceanodeParameter.kr(\highratio, 4, n, 1, 20, "f");
    gain5 = OceanodeParameter.kr(\highgain, 1, n, 0, 2, "f");

    // Master gain and mix controls
    masterGain = OceanodeParameter.kr(\mastergain, 1, n, 0, 2, "f");
    mix = OceanodeParameter.kr(\mix, 1, n, 0, 1, "f");

    // Compressor function
    compressor = { |snd, attack, release, threshold, ratio|
        var amplitudeDb, gainDb;
        amplitudeDb = Amplitude.ar(snd, attack, release).ampdb;
        gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
        snd * gainDb.dbamp;
    };

    // Create frequency bands using cascaded filters
    freqs = [lowFreq, lowMidFreq, midFreq, highMidFreq];
    sigs = [sigIn] ++ freqs.reverse.collect{|freq, i| LPF.ar(LPF.ar(sigIn, freq), freq) };
    bands = (freqs.size.collect{|i| sigs[i] - sigs[i + 1] } ++ [sigs.last]).reverse;

    // Apply compression to each band
    comp = [
        compressor.(bands[0], attack1, release1, threshold1, ratio1) * gain1,
        compressor.(bands[1], attack2, release2, threshold2, ratio2) * gain2,
        compressor.(bands[2], attack3, release3, threshold3, ratio3) * gain3,
        compressor.(bands[3], attack4, release4, threshold4, ratio4) * gain4,
        compressor.(bands[4], attack5, release5, threshold5, ratio5) * gain5
    ];

    // Mix between dry and wet signal
    sigIn = XFade2.ar(sigIn, comp.sum, (mix * 2) - 1) * masterGain.lincurve(0, 1, 0, 1, 4);

    // Output the processed signal
    Out.ar(OceanodeOutput.kr(\out), sigIn);

}, description: "Five band compressor with independent controls for each frequency range", category: "Effect/Dynamics");
)