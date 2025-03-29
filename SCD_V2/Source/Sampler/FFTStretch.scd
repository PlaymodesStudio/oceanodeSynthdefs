(
~synthCreator.value("FFTStretch", {|n|
    var buf, pos, rate, levels, chain, fftBuf;
    var overlaps, fftSize;

    // Fixed values
    overlaps = 2;
    fftSize = 16384;

    // Controls
    buf = OceanodeBuffer.kr(\bufnum);
    pos = OceanodeParameterLag.ar(\position, 0, n, 0, 1, "vf", 1/30, true);
    rate = OceanodeParameterLag.ar(\rate, 1, n, 0.1, 10, "vf", 1/30, true);
    levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    
    // Calculate buffer position in frames
    pos = pos * BufFrames.kr(buf);
    
    // Create FFT buffer exactly as in the original
    fftBuf = LocalBuf(fftSize!overlaps);
    
    // Create FFT processing chain
    chain = BufFFTTrigger(fftBuf, 1/overlaps, [0,1], overlaps);
    chain = BufFFT_BufCopy(chain, buf, pos, rate * BufRateScale.kr(buf));
    chain = BufFFT(chain);
    chain = PV_Diffuser(chain, 1);
    chain = BufIFFT(chain, 0);
    
    // Mix and apply level
    chain = Mix.ar(chain) * 0.8 * levels;
    
    Out.ar(OceanodeOutput.kr(\out), chain);
}, description: "FFT-based time stretching sampler", category: "Source/Sampler");
)